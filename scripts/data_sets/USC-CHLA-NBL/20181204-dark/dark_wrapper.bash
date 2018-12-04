#!/usr/bin/env bash

for subject in /raid/data/raw/USC-CHLA-NBL/20181204/*.R1.fastq.gz ; do
	base=$( basename ${subject%%.R1.fastq.gz} )
	echo $subject $base
	if [[ -e ${base}.log ]] ; then
		echo "Log exists. Skipping."
	else
		dark.bash --threads 39 $base
	fi
done

