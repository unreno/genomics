#!/usr/bin/env bash


for base in 268325 439338 63185 634370 983899 ; do
	echo $base

	#/raid/data/raw/20180718-Adam/bam/983899.recaled.bam
	#/raid/data/raw/20180718-Adam/bam/GM_983899.recaled.bam

	#Bam files need sample names ... (this will take HOURS as these files are about 250GB each)

#	gatk AddOrReplaceReadGroups --INPUT /raid/data/raw/20180718-Adam/bam/${base}.recaled.bam \
#		--OUTPUT ${base}.tumor.bam --RGLB unknownLB --RGPL unknownPL --RGPU unknownPU --RGSM ${base}.tumor

#	gatk AddOrReplaceReadGroups --INPUT /raid/data/raw/20180718-Adam/bam/GM_${base}.recaled.bam \
#		--OUTPUT ${base}.normal.bam --RGLB unknownLB --RGPL unknownPL --RGPU unknownPU --RGSM ${base}.normal

	#	And indexes ...

#	samtools index -@ 20 ${base}.tumor.bam
#	samtools index -@ 20 ${base}.normal.bam

#		--input ${base}.tumor.bam --tumor-sample ${base}.tumor \
#		--input ${base}.normal.bam --normal-sample ${base}.normal \

	if [ ! -e ${base}.mutect2.vcf.gz ] ; then

		gatk Mutect2 --reference /raid/refs/fasta/hg38.num.fa \
			--input /raid/data/raw/CCLS/bam/${base}.recaled.bam --tumor-sample ${base} \
			--input /raid/data/raw/CCLS/bam/GM_${base}.recaled.bam --normal-sample GM_${base} \
			-A MappingQuality -A MappingQualityRankSumTest -A ReadPosRankSumTest \
			-A FisherStrand -A StrandOddsRatio -A DepthPerSampleHC -A InbreedingCoeff \
			-A QualByDepth -A RMSMappingQuality -A Coverage \
			--output ${base}.mutect2.vcf.gz > ${base}.mutect2.txt 2>&1

	fi

done

