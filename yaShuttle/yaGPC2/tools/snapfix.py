#!/usr/bin/env python3
"""Copy a snapshot and remove pre-rendezvous propellant use, preserving dry mass.

Usage: snapfix.py SOURCE DEST --oms-used-lb LEFT,RIGHT [--rcs-used-lb F,L,R]
Only the five propellant entries in vehdyn.json are changed. Existing output
and previously corrected input are rejected to prevent double subtraction.
"""
import argparse,json,math,shutil
from pathlib import Path
LB_KG=.45359237

def amounts(text,count):
    values=[float(x) for x in text.split(',')]
    if len(values)!=count or any(not math.isfinite(x) or x<0 for x in values):
        raise ValueError(f'expected {count} finite nonnegative pound amounts')
    return values

def corrected(data,oms,rcs):
    values=data.get('vehdyn')
    if not isinstance(values,list) or len(values)<21 or values[0]!=1:
        raise ValueError('unsupported vehdyn snapshot format; expected version 1 with five modules')
    result=json.loads(json.dumps(data));values=result['vehdyn']
    for module,used in enumerate(rcs+oms):
        current=values[16+module];new=current-used*LB_KG
        if not math.isfinite(current) or new<0:
            raise ValueError(f'module {module}: use exceeds captured propellant')
        values[16+module]=new
    return result

def repair(source,dest,oms,rcs):
    source=Path(source).resolve();dest=Path(dest).resolve()
    if not source.is_dir() or dest.exists() or source==dest or source in dest.parents:
        raise ValueError('source must exist and destination must be new and outside source')
    if (source/'propellant-correction.json').exists():
        raise ValueError('source already corrected; refusing double subtraction')
    before=json.loads((source/'vehdyn.json').read_text());after=corrected(before,oms,rcs)
    shutil.copytree(source,dest)
    (dest/'vehdyn.json').write_text(json.dumps(after,indent=2)+'\n')
    record=dict(source=str(source),oms_used_lb=oms,rcs_used_lb=rcs,mass_reduction_kg=sum(oms+rcs)*LB_KG,propellant_before_kg=before['vehdyn'][16:21],propellant_after_kg=after['vehdyn'][16:21],convention='pre-rendezvous depletion; later captured burns retained; dry mass unchanged')
    (dest/'propellant-correction.json').write_text(json.dumps(record,indent=2)+'\n')
    return record

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('source');p.add_argument('dest');p.add_argument('--oms-used-lb',required=True);p.add_argument('--rcs-used-lb',default='0,0,0');a=p.parse_args()
    try:record=repair(a.source,a.dest,amounts(a.oms_used_lb,2),amounts(a.rcs_used_lb,3))
    except (ValueError,OSError) as error:p.error(str(error))
    print(json.dumps(record,indent=2))
if __name__=='__main__':main()
