#!/usr/bin/env bash



#for base in 268325 439338 63185 634370 983899 ; do
for base in 983899 ; do
 
	configManta.py \
		--normalBam /raid/data/raw/CCLS/bam/redo/GM_${base}.hg38_no_alts.RG.bam \
		--tumorBam /raid/data/raw/CCLS/bam/redo/${base}.hg38_no_alts.RG.bam \
		--referenceFasta /raid/refs/fasta/hg38_no_alts.fa \
		--runDir ${base}

	#Seems that each option NEEDS an explicit path

	${base}/runWorkflow.py -m local -j 40


	configManta.py \
		--normalBam /raid/data/raw/CCLS/bam/redo/GM_${base}.hg38_no_alts.PP.RG.bam \
		--tumorBam /raid/data/raw/CCLS/bam/redo/${base}.hg38_no_alts.PP.RG.bam \
		--referenceFasta /raid/refs/fasta/hg38_no_alts.fa \
		--runDir ${base}.PP

	#Seems that each option NEEDS an explicit path

	${base}.PP/runWorkflow.py -m local -j 40

done
