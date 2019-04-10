#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

wd=$PWD


echo "Beginning $wd"

date

bowtie2 --threads 40 --xeq --very-sensitive --all -x NA12878 -f -U /raid/refs/fasta/SVAs_and_HERVs_KWHE.fasta -S NA12878-SVAs_and_HERVs_KWHE.endtoend.sam

date

samtools view -o NA12878-SVAs_and_HERVs_KWHE.endtoend.bam NA12878-SVAs_and_HERVs_KWHE.endtoend.sam

date

bowtie2 --threads 40 --xeq --very-sensitive-local --all -x NA12878 -f -U /raid/refs/fasta/SVAs_and_HERVs_KWHE.fasta -S NA12878-SVAs_and_HERVs_KWHE.local.sam

date

samtools view -o NA12878-SVAs_and_HERVs_KWHE.local.bam NA12878-SVAs_and_HERVs_KWHE.local.sam

date


echo "Done"

