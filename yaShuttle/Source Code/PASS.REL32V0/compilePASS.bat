@echo off >nul
REM This batch script simply runs the Python script compilePASS, giving it
REM all of the command-line parameters unchanged, but changing the path to
REM compilePASS itself by replacing all \ by /.  This script is needed because it's
REM so phenomenally difficult in Windows to directly run a Python script from 
REM the command line that isn't in the current working directory.

for /f "tokens=*" %%i in ('where compilePASS.') do set compilePASS=%%i
python "%compilePASS:\=/%" %*

