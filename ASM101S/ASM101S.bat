@echo off >nul
REM This batch script simply runs the Python script ASM101S.py, giving it
REM all of the command-line parameters unchanged, but changing the path to
REM ASM101S.py itself by replacing all \ by /.  This script is needed 
REM because it's so phenomenally difficult in Windows to directly run a Python 
REM script from the command line that isn't in the current working directory.

for /f "tokens=*" %%i in ('where ASM101S.py.') do set ASM101S.py=%%i
python "%ASM101S.py:\=/%" %*

