#!/usr/bin/env bash

#/raid/data/raw/20180718-Adam/bam/GM_268325.recaled.bam GM_268325
#/raid/data/raw/20180718-Adam/bam/GM_439338.recaled.bam GM_439338
#/raid/data/raw/20180718-Adam/bam/GM_63185.recaled.bam GM_63185
#/raid/data/raw/20180718-Adam/bam/GM_634370.recaled.bam GM_634370
#/raid/data/raw/20180718-Adam/bam/GM_983899.recaled.bam GM_983899

for base in 268325 439338 63185 634370 983899 ; do

	configureStrelkaSomaticWorkflow.py \
		--normalBam /raid/data/raw/20180718-Adam/bam/GM_${base}.recaled.bam \
		--tumorBam /raid/data/raw/20180718-Adam/bam/${base}.recaled.bam \
		--ref /raid/refs/fasta/hg38.num.fa \
		--runDir ${base}

	#Seems that each option NEEDS an explicit path

	${base}/runWorkflow.py -m local -j 5

done
