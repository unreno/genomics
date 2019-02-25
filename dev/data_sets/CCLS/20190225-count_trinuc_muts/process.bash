#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

wd=$PWD

#/raid/data/raw/CCLS/vcf/GM_268325.output-HC.vcf.gz
#/raid/data/raw/CCLS/vcf/GM_439338.output-HC.vcf.gz
#/raid/data/raw/CCLS/vcf/GM_63185.output-HC.vcf.gz
#/raid/data/raw/CCLS/vcf/GM_634370.output-HC.vcf.gz
#/raid/data/raw/CCLS/vcf/GM_983899.output-HC.vcf.gz
for vcf in /raid/data/raw/CCLS/vcf/{GM_,}{268325,439338,63185,634370,983899}.output-HC.vcf.gz ; do
	base=$( basename $vcf .output-HC.vcf.gz )
	echo $vcf

	f=${base}.count_trinuc_muts.input.txt
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		bcftools query --include 'TYPE="snp" && QD > 2 && FS < 60 && MQ > 40 && MQRankSum > -12.5 && ReadPosRankSum > -8.0' -f "%CHROM\t%POS\t%REF\t%ALT\t+\n" ${vcf} > ${f}
		chmod a-w ${f}
	fi

	f=${base}.count_trinuc_muts.txt
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		./count_trinuc_muts_v8.pl vcf /raid/refs/fasta/hg38_num_noalts.fa ${base}.count_trinuc_muts.input.txt
		mv ${base}.count_trinuc_muts.input.txt.*.count.txt ${f}
		chmod a-w ${f}
	fi

done
