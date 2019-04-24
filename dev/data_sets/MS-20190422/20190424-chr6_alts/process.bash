#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



for r1 in /raid/data/raw/MS-20190422/*R1.fastq.gz ; do
	r2=${r1/_R1/_R2}
	base=$(basename $r1 _R1.fastq.gz) 

#echo "sickle pe -g -t sanger -f ${r1} -r ${r2} -o ${base}_R1.fastq.gz -p ${base}_R2.fastq.gz -s /dev/null > ${base}.sickle.log 2> ${base}.sickle.err"

	bowtie2 --threads 40 --very-sensitive -x hg38.chr6_alts -1 ${r1} -2 ${r2} 2> ${base}.bowtie2.err | samtools view -o ${base}.hg38.chr6_alts.bam - > ${base}.samtools.log 2> ${base}.samtools.err
done 

