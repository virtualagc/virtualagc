#!/bin/bash
# Run HAL_S_FC.py, and pass all of our command-line parameters to it.
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
$scriptDir/PASS1P/HAL_S_FC.py "$@"
