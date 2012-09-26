# This batch file runs the CM elements of the Virtual AGC 
# emulation for software version 249 of Colossus.
rem What it WANTS to do by default is jump down to :WinAGC.  The other
rem (legacy) stuff is just there in case I hear of some excruciatingly
rem awful problem with WinAGC.
c:
cd \mingw\bin
if f==f%NOTWINAGC% goto WinAGC
if f==f%XPPRO% goto notxppro
  start /min "CMyaAGC" yaAGC --core=Colossus249.bin %2
  start "CMsimulator" LM_Simulator "--cfg=lm_simulator.ini" "--port=19701" 
  SimStop CMyaAGC CMsimulator
  goto done
:notxppro
  start /min yaAGC --core=Colossus249.bin %2
  start LM_Simulator "--cfg=lm_simulator_windows.ini" "--port=19701" 
:WinAGC
  WinAGC <SimColossus249_lite.xeq
:done



