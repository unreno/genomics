#!/usr/bin/env bash


#	This script is to create an hg38 alignment vcf file.



#	expecting a bowtie2 index as well as a .fa file here
index=~/s3/herv/indexes/hg38

set -e
set -x




while [ $# -ne 0 ] ; do
	
	base=$1
	
	if [ ! -f ${base}.1.fastq.gz -a ! -f ${base}.2.fastq.gz ] ; then
		samtools fastq -N -1 ${base}.1.fastq.gz -2 ${base}.2.fastq.gz <( zcat ${base}.bam.gz )
	fi
	
	#\rm ${base}.bam
	
	#	Local seems to be the normal way to align before generating a VCF
	
	if [ ! -f ${base}.bam ] ; then
		#	local ALL alignments
	#	bowtie2 --threads 4 -x ${index} --very-sensitive-local -1 ${base}.1.fastq.gz -2 ${base}.2.fastq.gz -S ${base}.sam
	#	samtools sort --threads 3 -o ${base}.bam ${base}.sam
	
	
		#	end-to-end only PROPER_PAIR alignments
		#	This should actually find very little in our TCGA samples, since they've
		#	already been filtered to include only HERV data.
		bowtie2 --threads 4 -x ${index} --very-sensitive -1 ${base}.1.fastq.gz -2 ${base}.2.fastq.gz -S ${base}.sam
		samtools view -f 2 -o ${base}.PP.bam ${base}.sam
		samtools sort --threads 3 -o ${base}.bam ${base}.PP.bam
		\rm ${base}.PP.bam
	
	#	\rm ${base}.1.fastq.gz ${base}.2.fastq.gz
		\rm ${base}.sam
	fi
	
	chmod -w ${base}.bam
	
	if [ ! -f ${base}.bam.bai ] ; then
		samtools index ${base}.bam
	fi
	chmod -w ${base}.bam.bai
	
	
	for o in 'c' 'm' ; do
	
		if [ ! -f ${base}.${o}.vcf.gz ] ; then
			#	u = uncompressed bcf
			#	z =   compressed vcf
			#	-c, --consensus-caller    : the original calling method (conflicts with -m)
			#	-m, --multiallelic-caller : alternative model for multiallelic and rare-variant calling (conflicts with -c)
			bcftools mpileup  --threads 1 --output-type u --fasta-ref ${index}.fa ${base}.bam \
				| bcftools call --threads 1 --output-type z -${o} --variants-only --output ${base}.${o}.vcf.gz
		fi
		chmod -w ${base}.${o}.vcf.gz
	
		for t in 'CT' 'GA'; do
			from=${t: 0:1}	#	first letter
			to=${t: -1:1}		#	last letter
	
			#	collect chromosome and position
			zcat ${base}.${o}.vcf.gz | awk -F"\t" '\
				( !/^#/ && $4 == "'${from}'" && $5 == "'${to}'"){ \
					print $1"\t"$2
				}' > ${base}.${o}.${t}.txt
	
			#	collect chromosome, position and the upcased trinucleotide centered about that position
			#	using the while(){} loop in awk is to return the last line from samtools faidx
			zcat ${base}.${o}.vcf.gz | awk -F"\t" '\
				( !/^#/ && $4 == "'${from}'" && $5 == "'${to}'"){ \
					while("samtools faidx '${index}'.fa "$1":"$2-1"-"$2+1" " | getline x ){}; \
					print $1"\t"$2"\t"toupper(x) \
				}' > ${base}.${o}.${t}.tri.txt
	
		done	#	for t
	
	done	#	for o
	
	shift
done	#	while
