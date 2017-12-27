#!/bin/bash
cd /home/pi/virtualagc/piPeripheral
xterm -fullscreen  -e ./runPiDSKY2.sh --custom-bare --pigpio=7 --playback &
