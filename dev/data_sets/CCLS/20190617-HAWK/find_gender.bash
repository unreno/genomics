#!/usr/bin/env bash


for base in 983899 268325 439338 63185 634370 ; do
	echo ${base}
	for sample in ${base} GM_${base} ; do
		echo ${sample}
		for chr in X Y ; do
			echo ${chr}
			samtools view -c -@ 39 /raid/data/raw/CCLS/bam/${sample}.recaled.bam ${chr}
		done
	done
done


