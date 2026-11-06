#!/usr/bin/env python3
"""touchdown_x.py -- where a landing run's main gear touched down on the runway, and where it stopped.

    touchdown_x.py RUN_DIR [FLIGHTS_DIR]

RUN_DIR holds driver.out and logs/yaGPC2.log.  FLIGHTS_DIR is discretePanel/examples/flights (only for importing
fd13_propagator; default: the sibling checkout of this file).  Prints X (along the runway heading from the KSC15 or KSC33
threshold) and Y (to the right) in feet, for the first LEFT MAIN gear touchdown and for the last state sample (stopped).

METHOD (written by Mac-integrate, 2026-11-05, reproduces its run5c 2,756 ft; the Linux session that produced the earlier
2,230 / 2,632 / 2,730 ft figures never saved its own, ledger #320 / 2026-11-05 conversation):
  - position: the "vehdyn-state:" lines of RUN_DIR/logs/yaGPC2.log (truth, M50, ft and ft/s, every 10 s plus the last);
    touchdown time t from driver.out;
  - M50 -> Earth-fixed: fd13_propagator.pass_rnp(2011, 136) (vehdyn.c's own matrix), then Rz(PASS_EARTH_RATE * (gmt - 136*86400));
  - touchdown point: cubic Hermite between the two 10 s samples that bracket t, in Earth-fixed position and velocity;
  - runway: the lat/lon/azimuth of KSC15 and KSC33 in tools/sites/ksc-navaids.txt, WGS-84 ECEF, local East/North.
A crude gmst + fixed 0.70 deg rotation (deorbit_target.to_earth) is NOT good enough: it put P1's stop 36 kft off the runway.
Cross-check: Win11 run5b, Mac run5c and Linux P1 all come out within 20 ft of the centerline (Y).
"""
import sys,re,math
import os; sys.path.insert(0,sys.argv[2] if len(sys.argv)>2 else os.path.join(os.path.dirname(os.path.abspath(__file__)),"..","..","discretePanel","examples","flights"))
import fd13_propagator as P
RNP=P.pass_rnp(2011,136); W=P.PASS_EARTH_RATE; day=136
pat=re.compile(r'^vehdyn-state: t=(\S+) gmt=(\S+) r_ft=(\S+) (\S+) (\S+) v_fts=(\S+) (\S+) (\S+)')
rows=[list(map(float,m.groups())) for m in (pat.match(l) for l in open(sys.argv[1]+'/logs/yaGPC2.log',errors='replace')) if m]
txt=open(sys.argv[1]+'/driver.out',errors='replace').read()
td=float(re.search(r'LEFT MAIN gear TOUCHDOWN at t=([\d.]+)',txt).group(1))
def fixed(row):
    g=row[1]; a=W*(g-day*86400.0); c,s=math.cos(a),math.sin(a)
    r=[sum(RNP[i][j]*row[2+j] for j in range(3)) for i in range(3)]
    v=[sum(RNP[i][j]*row[5+j] for j in range(3)) for i in range(3)]
    p=[c*r[0]+s*r[1],-s*r[0]+c*r[1],r[2]]
    q=[c*v[0]+s*v[1],-s*v[0]+c*v[1],v[2]]
    q=[q[0]+W*p[1],q[1]-W*p[0],q[2]]
    return p,q
def ecef(lat,lon,hft):
    a=6378137.0/0.3048; e2=0.00669437999014
    n=a/math.sqrt(1-e2*math.sin(lat)**2)
    return [(n+hft)*math.cos(lat)*math.cos(lon),(n+hft)*math.cos(lat)*math.sin(lon),(n*(1-e2)+hft)*math.sin(lat)]
def enu(lat,lon,d):
    e=[-math.sin(lon),math.cos(lon),0]; n=[-math.sin(lat)*math.cos(lon),-math.sin(lat)*math.sin(lon),math.cos(lat)]
    return sum(a*b for a,b in zip(e,d)),sum(a*b for a,b in zip(n,d))
RW={'KSC15':(0.49973583221435547,-1.4085865020751953,8.3,2.6178817749023438),'KSC33':(0.49911224842071533,-1.4081783294677734,8.3,5.7594738006591797)}
def where(p):
    out={}
    for n,(lat,lon,h,az) in RW.items():
        o=ecef(lat,lon,h); E,N=enu(lat,lon,[a-b for a,b in zip(p,o)])
        out[n]=(E*math.sin(az)+N*math.cos(az),E*math.cos(az)-N*math.sin(az))
    return out
# before touchdown sample and after, with the speed at both, to bracket
a=max((r for r in rows if r[0]<=td),key=lambda r:r[0]); b=min((r for r in rows if r[0]>td),key=lambda r:r[0])
pa,va=fixed(a); pb,vb=fixed(b)
dt=b[0]-a[0]; u=(td-a[0])/dt
# Hermite in Earth-fixed
h=[(2*u**3-3*u**2+1)*pa[i]+(u**3-2*u**2+u)*dt*va[i]+(-2*u**3+3*u**2)*pb[i]+(u**3-u**2)*dt*vb[i] for i in range(3)]
print('touchdown t %.2f GMT %.1f samples t %.1f, %.1f, speed there %.0f %.0f kt'%(td,a[1]+td-a[0],a[0],b[0],math.dist(va,[0,0,0])*0.5925,math.dist(vb,[0,0,0])*0.5925))
for n,(x,y) in where(h).items(): print(' touchdown from %s threshold: X %+.0f ft, Y %+.0f ft'%(n,x,y))
for n,(x,y) in where(fixed(rows[-1])[0]).items(): print(' final (stopped) from %s: X %+.0f ft, Y %+.0f ft'%(n,x,y))