#!/usr/bin/env bash

#/raid/data/raw/20180718-Adam/bam/GM_268325.recaled.bam GM_268325
#/raid/data/raw/20180718-Adam/bam/GM_439338.recaled.bam GM_439338
#/raid/data/raw/20180718-Adam/bam/GM_63185.recaled.bam GM_63185
#/raid/data/raw/20180718-Adam/bam/GM_634370.recaled.bam GM_634370
#/raid/data/raw/20180718-Adam/bam/GM_983899.recaled.bam GM_983899

for base in 268325 439338 63185 634370 983899 ; do

#	for aligner in bwa eland isaac ; do
	for aligner in eland ; do

		configureStrelkaWorkflow.pl --normal=/raid/data/raw/20180718-Adam/bam/GM_${base}.recaled.bam --tumor=/raid/data/raw/20180718-Adam/bam/${base}.recaled.bam --ref=/raid/refs/fasta/hg38.num.fa --config=${HOME}/.local/etc/strelka_config_${aligner}_default.ini --output-dir=${PWD}/${base}.${aligner}

		#Seems that each option NEEDS an explicit path

		make -C ${PWD}/${base}.${aligner}  -j 10

	done
done
