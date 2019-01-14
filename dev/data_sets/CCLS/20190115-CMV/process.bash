#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


for f in /raid/data/raw/CCLS/bam/*fasta.gz ; do
	bam=$( basename $f .fasta.gz )
	echo $f $bam
	


	#	bowtie2 --very-sensitive --threads 39 -x CMV -f -U $f | samtools -o $bam -



	#	count reads


	#	count aligned read


	#	samtools depth -d 0 $bam


done


