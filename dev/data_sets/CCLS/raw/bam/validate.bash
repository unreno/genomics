#!/usr/bin/env bash


for bam in *bam ; do
	echo $bam

	if [ ! -e $bam.gatk_ValidateSamFile.STDOUT ] ; then
		gatk ValidateSamFile --INPUT $bam --IGNORE MATE_NOT_FOUND > $bam.gatk_ValidateSamFile.STDOUT 2> $bam.gatk_ValidateSamFile.STDERR
	fi

#	samtools index $bam $bam.index > $bam.samtools_index.txt 2>&1

#	samtools view -H $bam | grep "^@RG"

#	samtools stats and samtools flagstat both seem to be pointless

done

