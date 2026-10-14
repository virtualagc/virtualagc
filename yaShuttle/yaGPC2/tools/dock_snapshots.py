"""Snapshot sidecar: serialize session saves with the unmodified pilot's saves."""
import datetime as dt
import importlib
import json
import os
from pathlib import Path
import re
import sys
import threading
import time

os.environ['NSTS_NO_AUDIO'] = '1'
PANEL=Path(__file__).resolve().parents[2]/'discretePanel'
sys.path[:0]=[str(PANEL/'examples/flights'),str(PANEL)]
R=importlib.import_module('fly_rndz134')
if os.environ.get('APPROACH_DOCK')=='1':
    importlib.import_module('dock_autopilot')  # supplied, known-good docking phases
OUT=Path(os.environ['DOCK_SNAPSHOT_OUTPUT'])
OUT.mkdir(parents=True, exist_ok=True)
LOCK=threading.RLock()
# Never park the simulator for a save during a pilot pulse train.
_pilot_pulses = R.Rendezvous.thc_pulses
def serialized_pulses(self, *args, **kwargs):
    with LOCK:
        return _pilot_pulses(self, *args, **kwargs)
R.Rendezvous.thc_pulses = serialized_pulses

STOP=threading.Event()
STATE={'phase':'START','last_gmt':None,'driver':None,'error':None}
MET_ZERO=dt.datetime(2011,5,16,12,56,27,994000,tzinfo=dt.timezone.utc).timestamp()
YEAR=dt.datetime(2011,1,1,tzinfo=dt.timezone.utc).timestamp()
old_init,old_say,old_snapshot=R.Rendezvous.__init__,R.Rendezvous.say,R.Rendezvous._snapshot
old_start,old_restart=R.Rendezvous.start,R.Rendezvous.restart_from

def vehicle(f):
    p=Path(f.log)
    try:
        with p.open('rb') as stream:
            stream.seek(max(0,p.stat().st_size-32768));text=stream.read().decode(errors='replace')
        matches=list(re.finditer(r'vehdyn-state: t=([\d.]+) gmt=([\d.]+)',text))
        return tuple(map(float,matches[-1].groups())) if matches else None
    except OSError:return None

def fmt_met(unix):
    s=unix-MET_ZERO;days=int(s//86400);s-=days*86400;h=int(s//3600);s-=h*3600;m=int(s//60);s-=m*60
    return f'{days:02}/{h:02}:{m:02}:{s:06.3f}'

def wait_capture(p,timeout=210):
    until=time.monotonic()+timeout
    while time.monotonic()<until:
        try:
            meta=json.loads((p/'capture.json').read_text())
            json.loads((p/'vehicle.json').read_text())
            if (p/'gpc1.mem.bin').stat().st_size>0 and (p/'panel.json').stat().st_size>0:
                return meta
        except (OSError,ValueError):pass
        time.sleep(.25)
    raise RuntimeError('session save did not complete: '+str(p))

def guarded_snapshot(f,name):
    with LOCK:
        result=old_snapshot(f,name)
        target=Path(f.a.logs)/('sts134r-'+name)
        if target.exists() and (target/'vehicle.json').exists():wait_capture(target)
        return result

def request_save(f,force=False):
    with LOCK:
        state=vehicle(f)
        if state is None:return
        t,gmt=state
        if STATE['last_gmt'] is None:
            STATE['last_gmt']=gmt
            if not force:return
        if not force and gmt-STATE['last_gmt']<300:return
        # Vehicle GMT uses one-based day of year.
        unix=YEAR+gmt-86400
        when=dt.datetime.fromtimestamp(unix,dt.timezone.utc)
        table=OUT/'snaps.tsv'
        existing=table.read_text().splitlines()[1:] if table.exists() else []
        n=len(existing)+1
        phase=re.sub('[^A-Z0-9_-]','',STATE['phase'].upper()) or 'UNKNOWN'
        target=OUT/f'{n:02}-{phase}-{when.strftime("%j-%H-%M-%S")}'
        if target.exists():raise RuntimeError('refuse to overwrite '+str(target))
        R.fly_sts134.crewscript.send_session('save '+str(target),f.base)
        meta=wait_capture(target)
        unix=float(meta.get('gmtUnix',unix));actual=dt.datetime.fromtimestamp(unix,dt.timezone.utc)
        rng,rate,sample='not found','not found','not found'
        try:
            text=(Path(f.a.logs)/'rndz-check.log').read_text(errors='replace')
            rows=list(re.finditer(r'check: GMT ([\d.]+).*?truth RNG ([-\d.]+) ft RDOT ([-\d.]+) ft/s',text))
            if rows:sample,rng,rate=rows[-1].groups()
        except OSError:pass
        size=sum(p.stat().st_size for p in target.rglob('*') if p.is_file())
        header='NN\tdir\tphase\tGMT_UTC\tMET\trange_ft\trange_rate_ft_s\tsize_bytes\trange_sample_GMT_DOYseconds\n'
        line=f'{n:02}\t{target}\t{phase}\t{actual.isoformat(timespec="milliseconds")}\t{fmt_met(unix)}\t{rng}\t{rate}\t{size}\t{sample}\n'
        with table.open('a') as out:
            if not existing:out.write(header)
            out.write(line)
        STATE['last_gmt']=gmt
        print(f'snapshot sidecar: saved {target} ({size} bytes)',flush=True)

def monitor(f):
    while not STOP.wait(2):
        try:
            if getattr(f,'proc',None) and f.proc.poll() is None:request_save(f)
        except Exception as exc:
            STATE['error']=str(exc);print('snapshot sidecar ERROR: '+str(exc),flush=True)
            (OUT/'sidecar-error.txt').write_text(str(exc)+'\n')
            R.fly_sts134.crewscript.send_session('quit',f.base)
            return

def init(f,a):
    old_init(f,a);STATE['driver']=f
    table=OUT/'snaps.tsv'
    if table.exists():
        rows=table.read_text().splitlines()[1:]
        if rows:
            unix=dt.datetime.fromisoformat(rows[-1].split('\t')[3]).timestamp()
            STATE['last_gmt']=unix-YEAR+86400
    threading.Thread(target=monitor,args=(f,),daemon=True).start()

def say(f,text):
    old_say(f,text)
    m=re.match(r'== (\w+)',text)
    if m:
        STATE['phase']=m.group(1)
        if STATE['phase']=='RBAR' and f.a.rate!=1:
            R.fly_sts134.crewscript.send_session('rate 1',f.base)
            f.a.rate=1.0
            print('snapshot sidecar: rate 1 for manual phases',flush=True)

def guarded_start(f,*args,**kwargs):
    with LOCK:return old_start(f,*args,**kwargs)

def guarded_restart(f,*args,**kwargs):
    with LOCK:return old_restart(f,*args,**kwargs)

R.Rendezvous.start=guarded_start
R.Rendezvous.restart_from=guarded_restart
R.Rendezvous.__init__=init
R.Rendezvous.say=say
R.Rendezvous._snapshot=guarded_snapshot
def main():
    try:
        R.main()
        f=STATE['driver']
        if f and getattr(f,'proc',None) and f.proc.poll() is None:request_save(f,force=True)
        if STATE['error']:raise RuntimeError(STATE['error'])
    finally:
        STOP.set()

if __name__ == "__main__":
    main()
