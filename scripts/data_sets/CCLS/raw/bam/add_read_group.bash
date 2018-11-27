#!/usr/bin/env bash

for bam in *bam ; do
	base=${bam%.recaled.bam}
	echo $bam $base

	if [ ! -e rg/$bam ] ; then
		gatk AddOrReplaceReadGroups --INPUT ${bam} --OUTPUT rg/${bam} \
			--RGID ${base} --RGSM ${base} \
			--RGPL Illumina --RGLB UnknownLibrary --RGPU UnknownPlatform > rg/${bam}.STDOUT 2> rg/${bam}.STDERR
	fi

done
