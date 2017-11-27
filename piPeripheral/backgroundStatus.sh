#!/bin/bash

while true
do
	date
	vcgencmd measure_temp
	vcgencmd measure_clock arm
	uptime
	sleep 10
done
