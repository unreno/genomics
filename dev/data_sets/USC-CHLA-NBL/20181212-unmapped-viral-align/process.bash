#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


#for bam in $( find /raid/data/raw/1000genomes/phase3/data/ -name *unmapped*bam ) ; do
#for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*unmapped*bam ; do
for r1 in /raid/data/raw/USC-CHLA-NBL/2018????/*.R1.fastq.gz ; do

	echo "------------------------------------------------------------"
	base=$( basename $r1 )
	subject=${base%.R1.fastq.gz}
	r2=${r1/.R1.fastq.gz/.R2.fastq.gz}
	echo $r1
	echo $r2
	echo $base
	echo $subject

	echo "Processing $subject"


	if [ -f ${subject}.unmapped.count.txt ] && [ ! -w ${subject}.unmapped.count.txt ]  ; then
		echo "Write-protected ${subject}.unmapped.count.txt exists. Skipping step."
	else
		echo "Counting reads in $r1"
		r1lines=$( zcat $r1 | wc -l )
		echo $[r1lines/4] > ${subject}.unmapped.count.txt
		chmod a-w ${subject}.unmapped.count.txt
	fi


#	NC_001710.1 GB virus C/Hepatitis G virus, complete genome
#	NC_001716.2 Human herpesvirus 7, complete genome
#	NC_001664.4 Human betaherpesvirus 6A, variant A DNA, complete virion genome,
#	NC_000898.1 Human herpesvirus 6B
#	NC_008168.1 Choristoneura fumiferana granulovirus, complete genome

	for virus in NC_001710.1 NC_001716.2 NC_001664.4 NC_000898.1 NC_08168.1 ; do

#	for virus in /raid/refs/fasta/virii/*fasta ; do
#		virus=$( basename $virus .fasta )

		echo "Processing $subject / $virus"


		if [ -f ${subject}.${virus}.bam ] && [ ! -w ${subject}.${virus}.bam ]  ; then
			echo "Write-protected ${subject}.${virus}.bam exists. Skipping step."
		else

			if [ -f ${subject}.${virus}.unsorted.bam ] && [ ! -w ${subject}.${virus}.unsorted.bam ]  ; then
				echo "Write-protected ${subject}.${virus}.unsorted.bam exists. Skipping step."
			else
				bowtie2 --threads 35 --xeq -x virii/${virus} --very-sensitive -1 ${r1} -2 ${r2} 2>> ${subject}.${virus}.log | samtools view -F 4 -o ${subject}.${virus}.unsorted.bam -
				#chmod a-w ${subject}.${virus}.unsorted.bam
			fi

			echo "Sorting"
			samtools sort -o ${subject}.${virus}.bam ${subject}.${virus}.unsorted.bam
			chmod a-w ${subject}.${virus}.bam

			\rm ${subject}.${virus}.unsorted.bam
		fi

		if [ -f ${subject}.${virus}.bam.bai ] && [ ! -w ${subject}.${virus}.bam.bai ]  ; then
			echo "Write-protected ${subject}.${virus}.bam.bai exists. Skipping step."
		else
			echo "Indexing"
			samtools index ${subject}.${virus}.bam
			chmod a-w ${subject}.${virus}.bam.bai
		fi

		if [ -f ${subject}.${virus}.depth.csv ] && [ ! -w ${subject}.${virus}.depth.csv ]  ; then
			echo "Write-protected ${subject}.${virus}.depth.csv exists. Skipping step."
		else
			echo "Getting depth"
			samtools depth ${subject}.${virus}.bam > ${subject}.${virus}.depth.csv
			chmod a-w ${subject}.${virus}.depth.csv
		fi

		if [ -f ${subject}.${virus}.bowtie2.mapped.count.txt ] && [ ! -w ${subject}.${virus}.bowtie2.mapped.count.txt ]  ; then
			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.count.txt exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned to ${virus}"
			#	-F 4 needless here as filtered with this flag above.
			samtools view -c -F 4 ${subject}.${virus}.bam > ${subject}.${virus}.bowtie2.mapped.count.txt
			chmod a-w ${subject}.${virus}.bowtie2.mapped.count.txt
		fi

		if [ -f ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] && [ ! -w ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] ; then
			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt exists. Skipping step."
		else
			echo "Calculating ratio ${virus} bowtie2 alignments to total unaligned reads"
			echo "scale=9; "$(cat ${subject}.${virus}.bowtie2.mapped.count.txt)"/"$(cat ${subject}.unmapped.count.txt) | bc > ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
			chmod a-w ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
		fi

	done

done

echo "---"
echo "Done"
