#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

wd=$PWD

#	Both the provided bams and my bams were done on hg38, no chr prefix, no alts.
mkdir -p strelka

#for base in 268325 439338 63185 634370 983899 ; do
#
#	runDir="strelka/${base}.local"
#
#	~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
#		--normalBam /raid/data/raw/CCLS/bam/GM_${base}.recaled.bam \
#		--tumorBam /raid/data/raw/CCLS/bam/${base}.recaled.bam \
#		--ref /raid/refs/fasta/hg38.num.fa.gz \
#		--runDir ${runDir}
#
#	${runDir}/runWorkflow.py -m local -j 40
#
#done


base=983899


#runDir="strelka/${base}.local.PP"
#
#~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
#	--normalBam /raid/data/raw/CCLS/bam/GM_${base}.recaled.PP.bam \
#	--tumorBam /raid/data/raw/CCLS/bam/${base}.recaled.PP.bam \
#	--ref /raid/refs/fasta/hg38.num.fa.gz \
#	--runDir ${runDir}
#
#${runDir}/runWorkflow.py -m local -j 40


runDir="strelka/${base}.endtoend"

~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
	--normalBam /raid/data/raw/CCLS_983899/bam/GM_${base}.hg38.num.bam \
	--tumorBam /raid/data/raw/CCLS_983899/bam/${base}.hg38.num.bam \
	--ref /raid/refs/fasta/hg38.num.fa.gz \
	--runDir ${runDir}

${runDir}/runWorkflow.py -m local -j 40


runDir="strelka/${base}.endtoend.PP"

~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
	--normalBam /raid/data/raw/CCLS_983899/bam/GM_${base}.hg38.num.PP.bam \
	--tumorBam /raid/data/raw/CCLS_983899/bam/${base}.hg38.num.PP.bam \
	--ref /raid/refs/fasta/hg38.num.fa.gz \
	--runDir ${runDir}

${runDir}/runWorkflow.py -m local -j 40


