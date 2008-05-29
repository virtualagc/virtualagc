rem Batch file for starting the Virtual AGC LM simulation.
rem What it WANTS to do by default is jump down to :WinAGC.  The other
rem (legacy) stuff is just there in case I hear of some excruciatingly
rem awful problem with WinAGC.
c:
cd \mingw\bin
if f==f%NOTWINAGC% goto WinAGC
if f==f%XPPRO% goto notxppro
  start /min "LMyaAGC" yaAGC --core=Luminary131.bin --port=19797 %2
  start "LMsimulator" LM_Simulator "--cfg=lm_simulator.ini" 
  SimStop LMyaAGC LMsimulator
  goto done
:notxppro
  start /min yaAGC --core=Luminary131.bin --port=19797 %2
  start LM_Simulator "--cfg=lm_simulator.ini" 
:WinAGC
  WinAGC <SimLuminary131_lite.xeq
:done

