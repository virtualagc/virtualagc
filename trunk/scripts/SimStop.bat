rem I tried every aspect of this on the Windows XP machine at work,
rem but when I try it on my Windows XP machine at home it doesn't 
rem work at all, because tasklist and taskkill is missing.  Perhaps
rem it's because my machine at the office is XP Pro and at home
rem it's XP Home.  *Sigh!*  Thank you, M$!

rem This shell script stops all of the processes whose titles are the 
rem input parameters, when any one of them stops.  It only works in
rem Windows XP.  We allow a maximum of 6 processes.

break off

rem Loop until one of the processes listed on the command line is 
rem missing.
:Loop
  tasklist /FI "windowtitle eq %1" | find "=" /C
  if errorlevel 1 goto Done
  if f==f%2 goto Loop
  tasklist /FI "windowtitle eq %2" | find "=" /C
  if errorlevel 1 goto Done
  if f==f%3 goto Loop
  tasklist /FI "windowtitle eq %3" | find "=" /C
  if errorlevel 1 goto Done
  if f==f%4 goto Loop
  tasklist /FI "windowtitle eq %4" | find "=" /C
  if errorlevel 1 goto Done
  if f==f%5 goto Loop
  tasklist /FI "windowtitle eq %5" | find "=" /C
  if errorlevel 1 goto Done
  if f==f%6 goto Loop
  tasklist /FI "windowtitle eq %6" | find "=" /C
  if errorlevel 1 goto Done
  goto Loop
:Done
  
rem Kill all the processes.
taskkill /F /FI "windowtitle eq %1"
taskkill /F /FI "windowtitle eq %2"
taskkill /F /FI "windowtitle eq %3"
taskkill /F /FI "windowtitle eq %4"
taskkill /F /FI "windowtitle eq %5"
taskkill /F /FI "windowtitle eq %6"

