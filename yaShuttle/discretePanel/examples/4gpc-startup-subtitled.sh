#!/usr/bin/bash
# How to run my 4-GPC 2-CRT subtitled simulation.
cd ~/git/virtualagc/yaShuttle/discretePanel
python3 simulatePASS.py --gpcs 1,2,3,4 --crts 2 --tape ~/workspace/pass-run/OI340700-v44boot.mmv --script examples/4gpc-startup-subtitled.script --layout examples/4gpc-startup-subtitled.layout --size 384 --scale 0.8
