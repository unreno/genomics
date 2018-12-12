#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*.mapped*bam ; do
	base=$( basename $bam )
	subject=${base%.mapped.ILLUMINA.bwa*}
	echo $bam
	echo $base
	echo $subject

	echo "Processing $subject"




#	In a hurry to just create the fasta files




	if [ -f ${subject}.unmapped.fasta.gz ] ; then
		echo "${subject}.unmapped.fasta.gz exists. Skipping step."
	else
		echo "Extracting unmapped.fasta reads from $bam"
		samtools fasta -@ 3 -f 4 -N $bam 2>> ${subject}.unmapped.fasta.log | gzip --best > ${subject}.unmapped.fasta.gz && chmod a-w ${subject}.unmapped.fasta.gz &
	fi

	if [ -f ${subject}.mapped.fasta.gz ] ; then
		echo "${subject}.mapped.fasta.gz exists. Skipping step."
	else
		echo "Extracting mapped.fasta reads from $bam"
		samtools fasta -@ 3 -F 4 -N $bam 2>> ${subject}.mapped.fasta.log | gzip --best > ${subject}.mapped.fasta.gz && chmod a-w ${subject}.mapped.fasta.gz &
	fi

	echo "---"
done

echo "Done"
