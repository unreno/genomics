#!/usr/bin/env bash


#	This script is to create an hg38 alignment vcf file.


base=$1

#	expecting a bowtie2 index as well as a .fa file here
index=~/s3/herv/indexes/hg38

set -e
set -x



if [ ! -f ${base}.1.fastq.gz -a ! -f ${base}.2.fastq.gz ] ; then
	samtools fastq -N -1 ${base}.1.fastq.gz -2 ${base}.2.fastq.gz <( zcat ${base}.bam.gz )
fi

#\rm ${base}.bam

#	Local seems to be the normal way to align before generating a VCF

if [ ! -f ${base}.bam ] ; then
	bowtie2 --threads 4 -x ${index} --very-sensitive-local -1 ${base}.1.fastq.gz -2 ${base}.2.fastq.gz -S ${base}.sam
	samtools sort --threads 3 -o ${base}.bam ${base}.sam
fi

#\rm ${base}.sam
chmod -w ${base}.bam

if [ ! -f ${base}.bam.bai ] ; then
	samtools index ${base}.bam
fi
chmod -w ${base}.bam.bai

if [ ! -f ${base}.m.vcf.gz ] ; then
	bcftools mpileup -Ou -f ${index}.fa ${base}.bam | bcftools call -mvO z -o ${base}.m.vcf.gz
fi
chmod -w ${base}.vcf.gz

if [ ! -f ${base}.c.vcf.gz ] ; then
	bcftools mpileup -Ou -f ${index}.fa ${base}.bam | bcftools call -cvO z -o ${base}.c.vcf.gz
fi
chmod -w ${base}.c.vcf.gz

for o in 'c' 'm' ; do
	for t in 'CT' 'GA'; do
		from=${t: 0:1}
		to=${t: -1:1}

		zcat ${base}.${o}.vcf.gz | awk -F"\t" '\
			( !/^#/ && $4 == "'${from}'" && $5 == "'${to}'"){ \
				print $1"\t"$2}' > ${base}.${o}.${t}.txt


		#	using the while(){} loop in awk is to return the last line from samtools faidx
		zcat ${base}.${o}.vcf.gz | awk -F"\t" '\
		( !/^#/ && $4 == "'${from}'" && $5 == "'${to}'"){ \
			while("samtools faidx '${index}'.fa "$1":"$2-1"-"$2+1" " | getline x ){}; \
			print $1"\t"$2"\t"toupper(x) \
		}' > ${base}.${o}.${t}.tri.txt

	done	#	for t
done	#	for o

#zcat ${base}.m.vcf.gz | awk -F"\t" '\
#( !/^#/ && $4 == "C" && $5 == "T"){ \
#	while("samtools faidx '${index}'.fa "$1":"$2-1"-"$2+1" " | getline x ){}; \
#	print $1"\t"$2"\t"toupper(x) \
#}' > ${base}.m.CT.tri.txt
#
#zcat ${base}.m.vcf.gz | awk -F"\t" '\
#( !/^#/ && $4 == "G" && $5 == "A"){ \
#	while("samtools faidx '${index}'.fa "$1":"$2-1"-"$2+1" " | getline x ){}; \
#	print $1"\t"$2"\t"toupper(x) \
#}' > ${base}.m.GA.tri.txt



