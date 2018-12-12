#!/usr/bin/env bash

#	original vcfs are numeric (1,2,3 not chr1,chr2,chr3,etc)
#	these are reversed

#for vcf in *.recal.chr.vcf.gz ; do
#for vcf in [89G]*.recal.chr.vcf.gz ; do
#for vcf in 811386.recal.chr.vcf.gz ; do
for vcf in 186069.recal.chr.vcf.gz 341203.recal.chr.vcf.gz 439338.recal.chr.vcf.gz 506458.recal.chr.vcf.gz 530196.recal.chr.vcf.gz 634370.recal.chr.vcf.gz ; do
	base=${vcf##*/}
	base=${base%%.recal.chr.vcf.gz}
	echo $vcf $base

	gatk ApplyVQSR \
		-R /raid/refs/fasta/hg38.fa \
		-V /raid/data/raw/20180718-Adam/vcf/chr/${base}.chr.vcf.gz \
		-O ${base}.applied_recal.chr.vcf.gz \
		--truth-sensitivity-filter-level 99.9 \
		--tranches-file ${base}.tranches.txt \
		--recal-file ${base}.recal.chr.vcf.gz \
		--exclude-filtered \
		-mode SNP > ${base}.ApplyVQSR.txt 2>&1

#	mode can be SNP, INDEL or BOTH (but the VariantRecalibrator NEEDS to have used the same value)

done

