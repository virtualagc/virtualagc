#!/bin/bash

while true
do
	date
	vcgencmd measure_temp
	vcgencmd measure_clock arm
	ps aux | grep piDSKY2 | grep --invert-match grep
	uptime
	sleep 10
done
