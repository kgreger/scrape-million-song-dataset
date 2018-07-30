#!/bin/bash
COUNTER=1
while true
do
	[[ `ls ~/Desktop/MSD/ | wc -l | wc -l` -gt 0 ]]
	echo $COUNTER
	/Library/Frameworks/R.framework/Resources/bin/Rscript "/Users/konstantingreger/Documents/GitHub/scrape-million-song-dataset/scrape-million-song-dataset.R"
	let COUNTER=COUNTER+10000
done
