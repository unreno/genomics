#!/usr/bin/env bash

for bam in *bam ; do
	echo $bam

	if [ ! -e $bam.bai ] ; then
		samtools index -@ 30 $bam
	fi

done
