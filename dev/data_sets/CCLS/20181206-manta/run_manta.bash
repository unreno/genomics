#!/usr/bin/env bash



#for base in 268325 439338 63185 634370 983899 ; do
for base in 983899 ; do
 
	~/.local/manta/bin/configManta.py \
		--normalBam /raid/data/raw/CCLS/bam/GM_${base}.recaled.bam \
		--tumorBam /raid/data/raw/CCLS/bam/${base}.recaled.bam \
		--referenceFasta /raid/refs/fasta/hg38.num.fa \
		--runDir ${base}

	#Seems that each option NEEDS an explicit path

	${base}/runWorkflow.py -m local -j 40

done
