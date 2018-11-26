#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
#	set -o pipefail


#for bam in $( find /raid/data/raw/1000genomes/phase3/data/ -name *unmapped*bam ) ; do
#for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*unmapped*bam ; do
#for fasta in NA*.fasta.gz ; do
#for fasta in HG04*.fasta.gz ; do
for fasta in HG03[6789]*.fasta.gz ; do
#for fasta in *.fasta.gz ; do
	base=$( basename $fasta )
	#subject=${base%.unmapped.ILLUMINA.bwa*}
	subject=${base%.fasta.gz}
#	echo $bam
	echo $base
	echo $subject

	echo "Processing $subject"

	for hhv in HHV6a HHV6b ; do

		echo "Processing $hhv"

		if [ -f ${subject}.${hhv}.kallisto10.count.txt ] && [ ! -w ${subject}.${hhv}.kallisto10.count.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.kallisto10.count.txt exists. Skipping step."
		else
			echo "Running kallisto10"
			#	kallisto crashes when 0 alignments
			set +e
			#	estimated fragment length and standard deviation are guesses
			kallisto quant --single -l 500 -s 50 -b 10 --threads 10 --index /raid/refs/kallisto/${hhv} --output-dir ${subject}.${hhv}.kallisto10 ${subject}.fasta.gz 2> ${subject}.${hhv}.kallisto10.log
			set -e
			awk -F"\t" '( NR == 2 ){ print $4 }' ${subject}.${hhv}.kallisto10/abundance.tsv > ${subject}.${hhv}.kallisto10.count.txt
			chmod a-w ${subject}.${hhv}.kallisto10.count.txt
		fi

		if [ -f ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} kallisto10 alignments to total reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.kallisto10.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt
			chmod a-w ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt
		fi

#		if [ -f ${subject}.${hhv}.kallisto40.count.txt ] && [ ! -w ${subject}.${hhv}.kallisto40.count.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.kallisto40.count.txt exists. Skipping step."
#		else
#			echo "Running kallisto40"
#			#	kallisto crashes when 0 alignments
#			set +e
#			#	estimated fragment length and standard deviation are guesses
#			kallisto quant --single -l 500 -s 50 -b 40 --threads 40 --index /raid/refs/kallisto/${hhv} --output-dir ${subject}.${hhv}.kallisto40 ${subject}.fasta.gz 2> ${subject}.${hhv}.kallisto40.log
#			set -e
#			awk -F"\t" '( NR == 2 ){ print $4 }' ${subject}.${hhv}.kallisto40/abundance.tsv > ${subject}.${hhv}.kallisto40.count.txt
#			chmod a-w ${subject}.${hhv}.kallisto40.count.txt
#		fi

	done

	echo "---"
done
