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

#for germline_vcf in /raid/data/raw/CCLS/vcf/GM_*.output-HC.vcf.gz ; do
#	somatic_vcf=${germline_vcf/GM_/}
#	echo $germline_vcf
#	echo $somatic_vcf





		f=${base}.snps.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
	
			bcftools filter --include 'TYPE="snp"' ${vcf} --output-type z --output ${f}
	
			chmod a-w ${f}
		fi

		f=${base}.snps.filtered.1.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
	
			#	SNPs:
			#	• QD  < 2.0         
			#	• FS  >  60.0         
			#	• MQ  <  40.0 	
			#	• MQRankSum  <  -12.5 
			#	• ReadPosRankSum  <  -8.0
			#	
	
			#1	54380	rs2691279	T	C	68.77	PASS	AC=1;AF=0.5;AN=2;BaseQRankSum=0.875;ClippingRankSum=-0.012;DB;DP=57;ExcessHet=3.0103;FS=5.97;MLEAC=1;MLEAF=0.5;MQ=48.28;MQRankSum=-4.06;QD=1.21;ReadPosRankSum=-1.58;SOR=1.55GT:AD:DP:GQ:PL	0/1:50,7:57:97:97,0,3087

			bcftools filter --include 'TYPE="snp" && QD < 2 && FS > 60 && MQ < 40 && MQRankSum < -12.5 && ReadPosRankSum < -8.0' ${vcf} --output-type z --output ${f}

			chmod a-w ${f}
		fi

		f=${base}.snps.filtered.2.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			bcftools filter --include 'TYPE="snp" && QD < 3 && FS > 50 && MQ < 50 && MQRankSum < -10 && ReadPosRankSum < -7' ${base}.snps.vcf.gz --output-type z --output ${f}
			chmod a-w ${f}
		fi

		f=${base}.snps.filtered.3.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			bcftools filter --include 'TYPE="snp" && QD < 4 && FS > 40 && MQ < 60 && MQRankSum < -8 && ReadPosRankSum < -6' ${base}.snps.vcf.gz --output-type z --output ${f}
			chmod a-w ${f}
		fi

		f=${base}.snps.filtered.4.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			bcftools filter --include 'TYPE="snp" && QD < 5 && FS > 30 && MQ < 70 && MQRankSum < -6 && ReadPosRankSum < -5' ${base}.snps.vcf.gz --output-type z --output ${f}
			chmod a-w ${f}
		fi

		f=${base}.snps.filtered.5.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			bcftools filter --include 'TYPE="snp" && QD < 6 && FS > 25 && MQ < 80 && MQRankSum < -5 && ReadPosRankSum < -4' ${base}.snps.vcf.gz --output-type z --output ${f}
			chmod a-w ${f}
		fi



#		f=${base}.snps.txt
#		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
#			echo "Write-protected ${f} exists. Skipping step."
#		else
#	
#			#	This will skip SNPs with multiple alternates
#			#	Also, strand not in VCF files, but raw count_trinuc_muts_v8.pl expects it, so add "+"
#			#	Use bcftools query instead of, or with, awk
#			#	Add filter?
#			#
#			#	SNPs:
#			#	• QD  < 2.0         
#			#	• FS  >  60.0         
#			#	• MQ  <  40.0 	
#			#	• MQRankSum  <  -12.5 
#			#	• ReadPosRankSum  <  -8.0
#			#	
#	
#			zcat $vcf | awk 'BEGIN{FS=OFS="\t"}( !/^#/ && length($4) == 1 && length($5) == 1 ){ 
#				if($1=="MT") $1="M"; print "chr"$1,$2,$4,$5,"+" }' > ${f}
#	
#			chmod a-w ${f}
#		fi
#	
#	##reference=file:///MGMUST1/SHARED/ANALYSIS/HG38/Genome/hg38.fa
#	#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	GM_983899
#	#1	13684	rs71260404	C	T	32.77	.	AC=1;AF=0.500;AN=2;BaseQRankSum=2.285;ClippingRankSum=-0.065;DB;DP=15;ExcessHet=3.0103;FS=11.139;MLEAC=1;MLEAF=0.500;MQ=23.12;MQRankSum=-2.024;QD=2.18;ReadPosRankSum=0.196;SOR=3.234	GT:AD:DP:GQ:PL	0/1:11,4:15:61:61,0,266
#	
#	#$name.$time.count.txt
#	
#		f=${base}.count.txt
#		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
#			echo "Write-protected ${f} exists. Skipping step."
#		else
#	
#			#	/raid/refs/fasta/hg38.fa.gz contains chr prefix and chrM (not chrMT)
#			#	count_trinuc_muts_v8 DOES NOT work with gzipped reference
#	
#			#	for some reason existing /raid/refs/fasta/hg38.fa.index needs to be writable?
#			./count_trinuc_muts_v8.pl vcf /raid/refs/fasta/hg38.fa ${base}.snps.txt
#	
#			mv ${base}.snps.txt.*.count.txt ${f}
#			chmod a-w ${f}
#	
#		fi





















done


