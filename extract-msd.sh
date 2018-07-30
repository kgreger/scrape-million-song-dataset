#!/bin/bash
COUNTER=1
while true
do
	[[ `ls ~/Desktop/MSD/ | wc -l | wc -l` -gt 0 ]]
	echo $COUNTER
	let COUNTER=COUNTER+10000
done
