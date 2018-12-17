#!/usr/bin/env bash


# pointless settings here as everything is spawned in the background
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



#keeps crashing with 
#Failed to open -: unknown file type

#nohup is the cause? How? Why?

#for o in -c -m ; do
#	u = uncompressed bcf
#	z =   compressed vcf
#	-c, --consensus-caller    : the original calling method (conflicts with -m)
#	-m, --multiallelic-caller : alternative model for multiallelic and rare-variant calling (conflicts with -c)

for o in c m ; do
for f in *983899.recaled*bam redo/*983899.hg38.num*bam ; do

bcftools mpileup  --threads 1 --output-type u --fasta-ref /raid/refs/fasta/hg38.num.fa ${f} | bcftools call --threads 1 --output-type z -${o} --variants-only --output ${f}.${o}.vcf.gz &

done ; done

