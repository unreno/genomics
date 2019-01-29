#!/usr/bin/env bash


for virus_path in /raid/refs/fasta/virii/*fasta ; do
	virus=$( basename $virus_path .fasta )

	echo $virus


	if [ -f ${virus}.bam ] && [ ! -w ${virus}.bam ]; then 
		echo "${virus}.bam exists already."
	else
		bowtie2 --all --no-unal --threads 35 -f --xeq -x virii/${virus} --very-sensitive-local -U /raid/refs/fasta/hg19.100.fa.gz 2>> ${virus}.bowtie.log | samtools view -F 4 -o ${virus}.unsorted.bam - 2>> ${virus}.samtools.log
		samtools sort -o ${virus}.bam ${virus}.unsorted.bam
		\rm ${virus}.unsorted.bam
		chmod a-w ${virus}.bam
	fi

	if [ -f ${virus}.bam.bai ] && [ ! -w ${virus}.bam.bai ]; then 
		echo "${virus}.bam.bai exists already."
	else
		samtools index ${virus}.bam
		chmod a-w ${virus}.bam.bai
	fi
	
	if [ -f ${virus}.nonhg19.txt ] && [ ! -w ${virus}.nonhg19.txt ]; then 
		echo "${virus}.nonhg19.txt exists already."
	else
		if [ $(samtools view -c ${virus}.bam) -eq 0 ] ; then
			echo "Bam file empty."
			echo "${virus}:1-10000000" > ${virus}.nonhg19.txt
		else
			samtools depth ${virus}.bam | awk -f depths_to_reverse_regions.awk > ${virus}.nonhg19.txt
		fi
		chmod a-w ${virus}.nonhg19.txt
	fi

	if [ -f ${virus}.hg19.depth.txt ] && [ ! -w ${virus}.hg19.depth.txt ]; then 
		echo "${virus}.hg19.depth.txt exists already."
	else
		#samtools depth --reference ${virus_path} -aa ${virus}.bam > ${virus}.hg19.depth.txt
		samtools depth -r ${virus} -aa ${virus}.bam > ${virus}.hg19.depth.txt
		chmod a-w ${virus}.hg19.depth.txt
	fi

done

