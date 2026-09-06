"""Combine per-phase link products into one memory image per configuration.

The composition is the flight one, from ap101Utils.mcconfigs: the IPL set
(phases 10, 2, 13, 3) loads first, then the configuration's GRT row -- MFB
column, then PGM columns -- each phase overlaying what is already there."""
import json, io, os, struct, sys
T=os.environ.get("DASS_TREE", os.path.expanduser("~/pass-build/OI340700")); M=os.path.expanduser("~/workspace/PFS/mafgen")
IPL=(10,2,13,3)
ROW={"SSW":(), "G16":(3,4), "G2":(3,5), "G3":(3,6), "S2":(14,15),
     "P9":(9,12), "G8":(3,7), "G9":(3,8,18)}
SIZE=330394; FILL=0xC6C6
def phase(n):
    p="%s/phase/PHASE%02d"%(T,n)
    ob=io.open(p+".fcm","rb").read()
    return (list(struct.unpack(">%dH"%(len(ob)//2), ob)),
            json.load(io.open(p+".sym.json"))["sections"])
cache={}
def load(n):
    if n not in cache: cache[n]=phase(n)
    return cache[n]
def build(cfg):
    img=[FILL]*SIZE; smap={}
    order=list(IPL)
    for n in ROW[cfg]:
        if n in order: order.remove(n)      # MFB column replaces the IPL's
        order.append(n)
    for n in order:
        m,secs=load(n)
        for e in secs:
            a,z=e["address"],e["size"]
            if z<=0 or a+z>SIZE or a+z>len(m): continue
            # A section reached through a MAP card is DEFINED by this phase but
            # not re-emitted by it: its range in this phase's image is all zero.
            # Letting that overwrite the phase that really carries the text was
            # worth almost the whole score -- 390 sections sat at the right
            # address with nothing but zeros in them.
            if any(m[a:a+z]):
                img[a:a+z]=m[a:a+z]
            smap.setdefault(e["name"],(a,z))
            if any(m[a:a+z]): smap[e["name"]]=(a,z)
    return img,smap,order
if __name__=="__main__":
    print("%-5s %-22s %7s %7s %7s" % ("cfg","phase load order","loaded","exact","rate"))
    for cfg in sys.argv[1:]:
        img,smap,order=build(cfg)
        aug=json.load(io.open("%s/augmented-%s.json"%(M,cfg)))
        r=list(struct.unpack(">%dH"%(os.path.getsize("%s/%s.fcm"%(M,cfg))//2),
               io.open("%s/%s.fcm"%(M,cfg),"rb").read()))
        F={0xC6C6,0xC9FB}
        rng=sorted((g["start"],g["end"],n) for n,g in aug.items()); cont=set()
        for i in range(len(rng)-1):
            for j in range(i+1,len(rng)):
                if rng[j][0]>rng[i][1]: break
                cont.add(rng[i][2]); cont.add(rng[j][2])
        tot=ex=0
        for n,g in aug.items():
            s,e=g["start"],g["end"]
            if e+1>len(r) or n in cont: continue
            sz=e-s+1
            if sum(1 for i in range(s,e+1) if r[i] in F)/sz>=0.5: continue
            tot+=1
            ex += smap.get(n)==(s,sz) and all(img[s+i]==r[s+i] for i in range(sz))
        io.open("%s/phase/combined-%s.fcm"%(T,cfg),"wb").write(
            b"".join(struct.pack(">H",v) for v in img))
        print("%-5s %-22s %7d %7d %6.1f%%"
              % (cfg,"+".join(str(x) for x in order),tot,ex,100*ex/tot))
