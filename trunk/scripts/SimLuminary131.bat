rem Batch file for starting the Virtual AGC LM simulation.
rem What it WANTS to do by default is jump down to :WinAGC.  The other
rem (legacy) stuff is just there in case I hear of some excruciatingly
rem awful problem with WinAGC.
c:
cd \mingw\bin
if f==f%NOTWINAGC% goto WinAGC
if f==f%XPPRO% goto notxppro
  start /min "LMyaAGC" yaAGC --core=Luminary131.bin --port=19797 %2
  start /min "LMyaAGS" yaAGS --core=FP8.bin %4
  start "LMyaDEDA" yaDEDA %1
  start "LMyaDSKY" yaDSKY %1 --cfg=LM.ini --port=19797 --test-downlink
  start /min "LMyaACA" yaACA
  start "LMsimulator" LM_Simulator "--cfg=lm_simulator_nodsky.ini"
  SimStop LMyaAGC LMyaAGS LMyaDEDA LMyaDSKY LMyaACA LMsimulator
  goto done
:notxppro
  start /min yaAGC --core=Luminary131.bin --port=19797 %2
  start /min yaAGS --core=FP8.bin %4
  start yaDEDA %1
  start yaDSKY %1 --cfg=LM.ini --port=19797 --test-downlink
  start /min yaACA
  start LM_Simulator "--cfg=lm_simulator_windows_nodsky.ini"
  goto done
:WinAGC
  WinAGC <SimLuminary131.xeq
:done


