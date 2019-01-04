#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


#for bam in $( find /raid/data/raw/1000genomes/phase3/data/ -name *unmapped*bam ) ; do
for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*unmapped*bam ; do
	echo "------------------------------------------------------------"
	base=$( basename $bam )
	subject=${base%.unmapped.ILLUMINA.bwa*}
	echo $bam
	echo $base
	echo $subject

	echo "Processing $subject"


	if [ -f ${subject}.unmapped.count.txt ] && [ ! -w ${subject}.unmapped.count.txt ]  ; then
		echo "Write-protected ${subject}.unmapped.count.txt exists. Skipping step."
	else
		echo "Counting reads in $bam.bai"
		#samtools view -c $bam > ${subject}.unmapped.count.txt
		cat $bam.bai | bamReadDepther | grep "^*\|^#" | awk -F"\t" '{s+=$NF}END{print s}' > ${subject}.unmapped.count.txt
		chmod a-w ${subject}.unmapped.count.txt
	fi

	if [ -f ${subject}.mapped.count.txt ] && [ ! -w ${subject}.mapped.count.txt ]  ; then
		echo "Write-protected ${subject}.mapped.count.txt exists. Skipping step."
	else
		mapped_bam=${bam/.unmapped/.mapped}
		echo "Counting reads in $mapped_bam.bai"
		#	DIFFERENT THAN UNMAPPED
		cat $mapped_bam.bai | bamReadDepther | grep "^#" | awk -F"\t" '{s+=$2+$3}END{print s}' > ${subject}.mapped.count.txt
		chmod a-w ${subject}.mapped.count.txt
	fi

	if [ -f ${subject}.total.count.txt ] && [ ! -w ${subject}.total.count.txt ]  ; then
		echo "Write-protected ${subject}.total.count.txt exists. Skipping step."
	else
		echo "Adding mapped and unmapped read counts."
		echo $( cat ${subject}.mapped.count.txt )"+"$( cat ${subject}.unmapped.count.txt ) | bc > ${subject}.total.count.txt
		chmod a-w ${subject}.total.count.txt
	fi

#	if [ -f ${subject}.fastq.gz ] && [ ! -w ${subject}.fastq.gz ]  ; then
#		echo "Write-protected ${subject}.fastq.gz exists. Skipping step."
#	else
#		echo "Extracting fastq reads from $bam"
#		samtools fastq -N $bam | gzip --best > ${subject}.fastq.gz
#		chmod a-w ${subject}.fastq.gz
#	fi

#	blastn only accepts fasta. Bowtie2 can take either. Not sure if bowtie2 uses the quality

	if [ -f ${subject}.fasta.gz ] && [ ! -w ${subject}.fasta.gz ]  ; then
		echo "Write-protected ${subject}.fasta.gz exists. Skipping step."
	else
		echo "Extracting fasta reads from $bam"
		samtools fasta -N $bam 2>> ${subject}.fasta.log | gzip --best > ${subject}.fasta.gz
		chmod a-w ${subject}.fasta.gz
	fi



	if [ -f ${subject}.virii.bam ] && [ ! -w ${subject}.virii.bam ]  ; then
		echo "Write-protected ${subject}.virii.bam exists. Skipping step."
	else

		if [ -f ${subject}.virii.unsorted.bam ] && [ ! -w ${subject}.virii.unsorted.bam ]  ; then
			echo "Write-protected ${subject}.virii.unsorted.bam exists. Skipping step."
		else
			echo "Aligning ${subject} to all virii."


#	Hmm. All?

			bowtie2 --all --threads 35 -f --xeq -x virii --very-sensitive -U ${subject}.fasta.gz 2>> ${subject}.virii.log | samtools view -F 4 -o ${subject}.virii.unsorted.bam -


			#chmod a-w ${subject}.virii.unsorted.bam
		fi

		echo "Sorting"
		samtools sort -o ${subject}.virii.bam ${subject}.virii.unsorted.bam
		chmod a-w ${subject}.virii.bam

		\rm ${subject}.virii.unsorted.bam
	fi

	if [ -f ${subject}.virii.bam.bai ] && [ ! -w ${subject}.virii.bam.bai ]  ; then
		echo "Write-protected ${subject}.virii.bam.bai exists. Skipping step."
	else
		echo "Indexing"
		samtools index ${subject}.virii.bam
		chmod a-w ${subject}.virii.bam.bai
	fi

	if [ -f ${subject}.virii.depth.csv ] && [ ! -w ${subject}.virii.depth.csv ]  ; then
		echo "Write-protected ${subject}.virii.depth.csv exists. Skipping step."
	else
		echo "Getting depth"
		samtools depth ${subject}.virii.bam > ${subject}.virii.depth.csv
		chmod a-w ${subject}.virii.depth.csv
	fi


	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )

		echo "Processing $subject / $virus"

		if [ -f ${subject}.${virus}.depth.csv ] && [ ! -w ${subject}.${virus}.depth.csv ]  ; then
			echo "Write-protected ${subject}.${virus}.depth.csv exists. Skipping step."
		else
			echo "Getting depth"


			awk '( $1 == "'${virus}'" )' ${subject}.virii.depth.csv > ${subject}.${virus}.depth.csv
#			samtools depth ${subject}.${virus}.bam > ${subject}.${virus}.depth.csv



			chmod a-w ${subject}.${virus}.depth.csv
		fi


		if [ -f ${subject}.${virus}.bowtie2.mapped.count.txt ] && [ ! -w ${subject}.${virus}.bowtie2.mapped.count.txt ]  ; then
			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.count.txt exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned to ${virus}"
			#	-F 4 needless here as filtered with this flag above.
			samtools view -c -F 4 ${subject}.virii.bam ${virus} > ${subject}.${virus}.bowtie2.mapped.count.txt
			chmod a-w ${subject}.${virus}.bowtie2.mapped.count.txt
		fi







		if [ -f ${subject}.${virus}.bowtie2.mapped_uncommon.count.txt ] && [ ! -w ${subject}.${virus}.bowtie2.mapped_uncommon.count.txt ]  ; then
			echo "Write-protected ${subject}.${virus}.bowtie2.mapped_uncommon.count.txt exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned uncommon to ${virus}"
			#	-F 4 needless here as filtered with this flag above.

			region=$( grep Samtools common_regions.${virus}.txt || true ) #	grep will return error code if no line found so add || true
			echo $region
			region=${region#Samtools uncommon regions: }
			#common_regions.D13784.1.txt:Samtools uncommon regions: D13784.1:1-4163 D13784.1:4208-7649 D13784.1:7691-8000 D13784.1:8053-1000000

			echo "${region}"
			[ -z "${region}" ] && region="${virus}"

			samtools view -c -F 4 ${subject}.virii.bam ${region} > ${subject}.${virus}.bowtie2.mapped_uncommon.count.txt


			chmod a-w ${subject}.${virus}.bowtie2.mapped_uncommon.count.txt
		fi











		if [ -f ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] && [ ! -w ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] ; then
			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt exists. Skipping step."
		else
			echo "Calculating ratio ${virus} bowtie2 alignments to total unaligned reads"
			echo "scale=9; "$(cat ${subject}.${virus}.bowtie2.mapped.count.txt)"/"$(cat ${subject}.unmapped.count.txt) | bc > ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
			chmod a-w ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
		fi

		if [ -f ${subject}.${virus}.bowtie2.mapped.ratio_total.txt ] && [ ! -w ${subject}.${virus}.bowtie2.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${virus} bowtie2 alignments to total reads"
			echo "scale=9; "$(cat ${subject}.${virus}.bowtie2.mapped.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${virus}.bowtie2.mapped.ratio_total.txt
			chmod a-w ${subject}.${virus}.bowtie2.mapped.ratio_total.txt
		fi

	done

done

echo "---"
echo "Done"
