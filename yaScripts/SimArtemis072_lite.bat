# This batch file runs the CM elements of the Virtual AGC 
# emulation for software version Artemis 072 (Colossus 3).
rem What it WANTS to do by default is jump down to :WinAGC.  The other
rem (legacy) stuff is just there in case I hear of some excruciatingly
rem awful problem with WinAGC.
c:
cd \mingw\bin
if f==f%NOTWINAGC% goto WinAGC
if f==f%XPPRO% goto notxppro
  start /min "CMyaAGC" yaAGC --core=Artemis072.bin %2
  start "CMsimulator" LM_Simulator "--cfg=lm_simulator.ini" "--port=19701" 
  SimStop CMyaAGC CMsimulator
  goto done
:notxppro
  start /min yaAGC --core=Artemis072.bin %2
  start LM_Simulator "--cfg=lm_simulator.ini" "--port=19701" 
:WinAGC
  WinAGC <SimArtemis072_lite.xeq
:done



