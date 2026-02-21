:: This batch script simply runs the Python script HALSFCp, giving it
:: all of the command-line parameters unchanged, but changing the path to
:: HALSFCp itself by replacing all \ by /.  This script is needed because it's
:: so phenominally difficult in Windows to directly run a Python script from 
:: the command line that isn't in the current working directory.

@echo off >nul
for /f "tokens=*" %%i in ('where HALSFCp') do set HALSFCp=%%i
python "%HALSFCp:\=/%" %*

