#!/usr/bin/env bash

#/raid/data/raw/20180718-Adam/bam/GM_268325.recaled.bam GM_268325
#/raid/data/raw/20180718-Adam/bam/GM_439338.recaled.bam GM_439338
#/raid/data/raw/20180718-Adam/bam/GM_63185.recaled.bam GM_63185
#/raid/data/raw/20180718-Adam/bam/GM_634370.recaled.bam GM_634370
#/raid/data/raw/20180718-Adam/bam/GM_983899.recaled.bam GM_983899

#	/raid/data/raw/CCLS/bam/redo/GM_983899.hg38_no_alts.PP.RG.bam


#	For consistency, I should have use hg38.num.fa instead of hg38_no_alts.fa
#	HOWEVER, the latest dbsnp reference uses the "chr" prefix. Would need to edit.


#for base in 268325 439338 63185 634370 983899 ; do
for base in 983899 ; do


#	~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
#		--normalBam /raid/data/raw/CCLS/bam/GM_${base}.recaled.bam \
#		--tumorBam /raid/data/raw/CCLS/bam/${base}.recaled.bam \
#		--ref /raid/refs/fasta/hg38.num.fa \
#		--runDir ${base}
#
#	#Seems that each option NEEDS an explicit path
#
#	${base}/runWorkflow.py -m local -j 30
#
#
#	~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
#		--normalBam /raid/data/working/CCLS/20181203-strelka/GM_${base}.hg38_no_alts.bam \
#		--tumorBam /raid/data/working/CCLS/20181203-strelka/${base}.hg38_no_alts.bam \
#		--ref /raid/refs/fasta/hg38_no_alts.fa \
#		--runDir ${base}
#
#	#Seems that each option NEEDS an explicit path
#
#	${base}/runWorkflow.py -m local -j 30

	~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
		--normalBam /raid/data/raw/CCLS/bam/redo/GM_${base}.hg38.num.PP.bam \
		--tumorBam /raid/data/raw/CCLS/bam/redo/${base}.hg38.num.PP.bam \
		--ref /raid/refs/fasta/hg38.num.fa \
		--runDir ${base}.PP

	#Seems that each option NEEDS an explicit path

	${base}.PP/runWorkflow.py -m local -j 40


	~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
		--normalBam /raid/data/raw/CCLS/bam/redo/GM_${base}.hg38.num.bam \
		--tumorBam /raid/data/raw/CCLS/bam/redo/${base}.hg38.num.bam \
		--ref /raid/refs/fasta/hg38.num.fa \
		--runDir ${base}

	#Seems that each option NEEDS an explicit path

	${base}/runWorkflow.py -m local -j 40

done
