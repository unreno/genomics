#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


#for bam in $( find /raid/data/raw/1000genomes/phase3/data/ -name *.unmapped*bam ) ; do
#for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*.unmapped*bam ; do
for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*.mapped*bam ; do
	base=$( basename $bam )
	subject=${base%.mapped.ILLUMINA.bwa*}
	echo $bam
	echo $base
	echo $subject

	echo "Processing $subject"


#	if [ -f ${subject}.unmapped.count.txt ] && [ ! -w ${subject}.unmapped.count.txt ]  ; then
#		echo "Write-protected ${subject}.unmapped.count.txt exists. Skipping step."
#	else
#		echo "Counting reads in $bam.bai"
#		#samtools view -c $bam > ${subject}.unmapped.count.txt
#		cat $bam.bai | bamReadDepther | grep "^*\|^#" | awk -F"\t" '{s+=$NF}END{print s}' > ${subject}.unmapped.count.txt
#		chmod a-w ${subject}.unmapped.count.txt
#	fi
#
#	if [ -f ${subject}.mapped.count.txt ] && [ ! -w ${subject}.mapped.count.txt ]  ; then
#		echo "Write-protected ${subject}.mapped.count.txt exists. Skipping step."
#	else
#		mapped_bam=${bam/.unmapped/.mapped}
#		echo "Counting reads in $mapped_bam.bai"
#		#	DIFFERENT THAN UNMAPPED
#		cat $mapped_bam.bai | bamReadDepther | grep "^#" | awk -F"\t" '{s+=$2+$3}END{print s}' > ${subject}.mapped.count.txt
#		chmod a-w ${subject}.mapped.count.txt
#	fi
#
#	if [ -f ${subject}.total.count.txt ] && [ ! -w ${subject}.total.count.txt ]  ; then
#		echo "Write-protected ${subject}.total.count.txt exists. Skipping step."
#	else
#		echo "Adding mapped and unmapped read counts."
#		echo $( cat ${subject}.mapped.count.txt )"+"$( cat ${subject}.unmapped.count.txt ) | bc > ${subject}.total.count.txt
#		chmod a-w ${subject}.total.count.txt
#	fi

#	if [ -f ${subject}.fastq.gz ] && [ ! -w ${subject}.fastq.gz ]  ; then
#		echo "Write-protected ${subject}.fastq.gz exists. Skipping step."
#	else
#		echo "Extracting fastq reads from $bam"
#		samtools fastq -N $bam | gzip --best > ${subject}.fastq.gz
#		chmod a-w ${subject}.fastq.gz
#	fi

#	blastn only accepts fasta. Bowtie2 can take either. Not sure if bowtie2 uses the quality

	if [ -f ${subject}.unmapped.fasta.gz ] && [ ! -w ${subject}.unmapped.fasta.gz ]  ; then
		echo "Write-protected ${subject}.unmapped.fasta.gz exists. Skipping step."
	else
		echo "Extracting unmapped.fasta reads from $bam"
		samtools fasta -@ 39 -f 4 -N $bam 2>> ${subject}.unmapped.fasta.log | gzip --best > ${subject}.unmapped.fasta.gz
		chmod a-w ${subject}.unmapped.fasta.gz
	fi

	if [ -f ${subject}.unmapped.count.txt ] && [ ! -w ${subject}.unmapped.count.txt ]  ; then
		echo "Write-protected ${subject}.unmapped.count.txt exists. Skipping step."
	else
		echo "Counting unmapped.fasta reads"
		echo $( zcat ${subject}.unmapped.fasta.gz | wc -l )"/2" | bc > ${subject}.unmapped.count.txt
		chmod a-w ${subject}.unmapped.count.txt
	fi

	if [ -f ${subject}.mapped.fasta.gz ] && [ ! -w ${subject}.mapped.fasta.gz ]  ; then
		echo "Write-protected ${subject}.mapped.fasta.gz exists. Skipping step."
	else
		echo "Extracting mapped.fasta reads from $bam"
		samtools fasta -@ 39 -F 4 -N $bam 2>> ${subject}.mapped.fasta.log | gzip --best > ${subject}.mapped.fasta.gz
		chmod a-w ${subject}.mapped.fasta.gz
	fi

	if [ -f ${subject}.mapped.count.txt ] && [ ! -w ${subject}.mapped.count.txt ]  ; then
		echo "Write-protected ${subject}.mapped.count.txt exists. Skipping step."
	else
		echo "Counting mapped.fasta reads"
		echo $( zcat ${subject}.mapped.fasta.gz | wc -l )"/2" | bc > ${subject}.mapped.count.txt
		chmod a-w ${subject}.mapped.count.txt
	fi


	for hhv in HHV6a HHV6b ; do

		echo "Processing $hhv"

		for m in mapped unmapped ; do

			echo "Processing $m"

			if [ -f ${subject}.${m}.${hhv}.unsorted.bam ] && [ ! -w ${subject}.${m}.${hhv}.unsorted.bam ]  ; then
				echo "Write-protected ${subject}.${m}.${hhv}.unsorted.bam exists. Skipping step."
			else
				echo "Bowtie2 aligning ${m}.fasta reads to ${hhv}"
	
				#	FASTA REQUIRES the -f FLAG!
				bowtie2 --threads 40 -f --xeq -x ${hhv} --very-sensitive -U ${subject}.${m}.fasta.gz 2>> ${subject}.${m}.${hhv}.log | samtools view -F 4 -o ${subject}.${m}.${hhv}.unsorted.bam -
	
				chmod a-w ${subject}.${m}.${hhv}.unsorted.bam
			fi
	
			if [ -f ${subject}.${m}.${hhv}.sorted.bam ] && [ ! -w ${subject}.${m}.${hhv}.sorted.bam ]  ; then
				echo "Write-protected ${subject}.${m}.${hhv}.sorted.bam exists. Skipping step."
			else
				echo "Sorting"
				samtools sort -o ${subject}.${m}.${hhv}.sorted.bam ${subject}.${m}.${hhv}.unsorted.bam
				chmod a-w ${subject}.${m}.${hhv}.sorted.bam
			fi



			if [ -f ${subject}.${m}.${hhv}.depth.csv ] && [ ! -w ${subject}.${m}.${hhv}.depth.csv ]  ; then
				echo "Write-protected ${subject}.${m}.${hhv}.depth.csv exists. Skipping step."
			else
				echo "Getting depth"
				samtools depth ${subject}.${m}.${hhv}.sorted.bam > ${subject}.${m}.${hhv}.depth.csv
				chmod a-w ${subject}.${m}.${hhv}.depth.csv
			fi















			if [ -f ${subject}.${m}.${hhv}.bowtie2.mapped.count.txt ] && [ ! -w ${subject}.${m}.${hhv}.bowtie2.mapped.count.txt ]  ; then
				echo "Write-protected ${subject}.${hhv}.${m}.bowtie2.mapped.count.txt exists. Skipping step."
			else
				echo "Counting reads ${m}.bowtie2 aligned to ${hhv}"
				#	-F 4 needless here as filtered with this flag above.
				samtools view -c -F 4 ${subject}.${m}.${hhv}.sorted.bam > ${subject}.${m}.${hhv}.bowtie2.mapped.count.txt
				chmod a-w ${subject}.${m}.${hhv}.bowtie2.mapped.count.txt
			fi

			if [ -f ${subject}.${m}.${hhv}.kallisto10.mapped.count.txt ] && [ ! -w ${subject}.${m}.${hhv}.kallisto10.mapped.count.txt ] ; then
				echo "Write-protected ${subject}.${m}.${hhv}.kallisto10.mapped.count.txt exists. Skipping step."
			else
				echo "Running ${m}.kallisto10"
				#	kallisto crashes when 0 alignments
				set +e
				#	estimated fragment length and standard deviation are guesses
				kallisto quant --single -l 500 -s 50 -b 10 --threads 10 --index /raid/refs/kallisto/${hhv} --output-dir ${subject}.${m}.${hhv}.kallisto10.mapped ${subject}.${m}.fasta.gz 2> ${subject}.${m}.${hhv}.kallisto10.mapped.log
				set -e
				awk -F"\t" '( NR == 2 ){ print $4 }' ${subject}.${m}.${hhv}.kallisto10.mapped/abundance.tsv > ${subject}.${m}.${hhv}.kallisto10.mapped.count.txt
				chmod a-w ${subject}.${m}.${hhv}.kallisto10.mapped.count.txt
			fi

		done

	done

	echo "---"
done

echo "Done"
