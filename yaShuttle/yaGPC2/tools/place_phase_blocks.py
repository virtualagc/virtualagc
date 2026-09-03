#!/usr/bin/env python3
"""Assign destinations to a phase's load blocks as a MONOTONE assignment.

Scoring each block's destination independently does not work: phase 8 came out
at about 28 of 35, and forcing the remainder to avoid overlap made it worse,
pushing a 4538-halfword block to a 3.6%-confident address.

THE CONSTRAINT THAT MAKES IT TRACTABLE

A phase's load blocks are STRICTLY ASCENDING IN DESTINATION AND
NON-OVERLAPPING, and descriptor order is tape order.  Verified on all 48
ground-truth blocks of phases 10, 2, 13 and 3, read from the tape's own IPL
phase table at halfword 684294 -- not inferred.

So destinations are not 35 independent guesses; they are a monotone assignment,
solvable exactly by dynamic programming.  The constraint also ELIMINATES bad
placements instead of inventing them: a block whose candidates all conflict is
left unplaced, which is the honest outcome.

WHY IT CATCHES WHAT SCORING CANNOT

The flight software carries numbered variants of the same routine --
$0VB2LEV, A4VB2LEV, A6VB2LEV, B0VB2LEV.  A content fingerprint matches the
wrong variant at 93-97%, indistinguishable from a correct placement.  Ordering
is what separates them: in phase 8's stalled region, windows 90-95 and 99-104
both score 93-97% and are mutually exclusive under ascending order, so at most
one group is real.

INPUTS
  - blocks: (tapeOffset, length) pairs from the checksum walk, which is
    unambiguous where it works (35 blocks over phase 8's first 87 MM blocks).
  - reference: the AS-BUILT image, i.e. G9.fcm with the DASS patch summary's
    post-build changes reverted.  Scoring against the raw dump understates a
    correct placement badly -- see problems.md 8.34.
  - candidates: section starts only, from augmented-G9.json.  Every block in
    the ground truth begins at one.
"""
import numpy as np, io, json, struct, bisect
b=io.open('/home/rburkey/workspace/pass-run/pass-ipl-cflm.mmv','rb').read()
hw,ent,fl=struct.unpack('>III',b[8:20])
dirn=struct.unpack('>%dI'%ent,b[32:32+4*ent]); pos={v:i for i,v in enumerate(dirn)}
DATA=(32+4*ent)//2
T=np.frombuffer(b,dtype='>u2').astype(np.uint16); base8=DATA+pos[10880]*512
A=np.frombuffer(io.open('/tmp/G9-asbuilt.fcm','rb').read(),dtype='>u2').astype(np.uint16)
gn=len(A); FILL=np.array([0xc6c6,0xc9fb,0x0000],dtype=np.uint16)
m=json.load(open('augmented-G9.json'))
sec=sorted((d['start'],d['end'],c,d['type']) for c,d in m.items() if d.get('inConfig',True))
S=[x[0] for x in sec]; STARTS=sorted({x[0] for x in sec})
def own(a):
    i=bisect.bisect_right(S,a)-1
    if i<0: return '-'
    st,en,c,t=sec[i]
    return '%s %s%+d'%(c,t[:4],a-st) if a<=en else '-'
def score(t,cl,d):
    if d<0 or d+cl>gn: return 0.0
    tp=T[base8+t:base8+t+cl].astype(np.int32); dp=A[d:d+cl].astype(np.int32)
    eq=(tp==dp)
    fill=np.isin(tp,FILL.astype(np.int32))&np.isin(dp,FILL.astype(np.int32))
    return float((eq|fill).sum())/cl
blocks=[tuple(x) for x in json.load(open('/tmp/ph8_csum.json'))]     # 35 authoritative (tapeOff, len)
FIX={0:0x001f8,1:0x001fe,2:0x00242,3:0x002ac}
CAND=[]
for i,(t,L) in enumerate(blocks):
    cl=L-2
    if i in FIX: CAND.append([(FIX[i],1.0)]); continue
    seg=T[base8+t:base8+t+cl]
    nf=np.nonzero(~np.isin(seg,FILL))[0]
    if len(nf)==0: CAND.append([]); continue
    smp=nf if len(nf)<=96 else nf[np.linspace(0,len(nf)-1,96).astype(int)]
    vals=seg[smp]; lim=gn-cl if gn-cl>0 else gn-1
    sc=np.zeros(lim,dtype=np.int32)
    for off,val in zip(smp,vals): sc += (A[off:off+lim]==val)
    # candidates: section starts only, ranked by fingerprint then verified by score
    cs=[]
    for d in STARTS:
        if d>=lim: break
        if sc[d]>=max(3,0.10*len(smp)): cs.append((d,score(t,cl,d)))
    cs.sort(key=lambda x:-x[1]); CAND.append(cs[:25])
# DP: strictly ascending, non-overlapping, maximise total score
NEG=-1e9
import functools
@functools.lru_cache(maxsize=None)
def best(i,prev_end):
    if i==len(blocks): return (0.0,())
    cl=blocks[i][1]-2
    bs,bp=NEG,None
    for d,pc in CAND[i]:
        if d<prev_end: continue
        s,p=best(i+1,d+cl)
        s+=pc
        if s>bs: bs,bp=s,(d,)+p
    s,p=best(i+1,prev_end)          # allow a block to be left unplaced
    s-=0.5
    if s>bs: bs,bp=s,(None,)+p
    return (bs,bp)
import sys; sys.setrecursionlimit(10000)
tot,path=best(0,0)
print('  # tapeOff   len   dest      score   section')
placed=0
for i,((t,L),d) in enumerate(zip(blocks,path)):
    cl=L-2
    if d is None: print('  %2d %7d %5d  UNPLACED'%(i+1,t,cl)); continue
    placed+=1
    print('  %2d %7d %5d  0x%05x  %5.1f%%  %s'%(i+1,t,cl,d,100*score(t,cl,d),own(d)))
print()
print('%d of %d placed, all ascending and non-overlapping by construction'%(placed,len(blocks)))
json.dump([(t,L,d) for (t,L),d in zip(blocks,path)],open('/tmp/ph8_mono.json','w'))
