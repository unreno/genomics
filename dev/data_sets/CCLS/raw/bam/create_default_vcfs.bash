#!/usr/bin/env bash


# pointless settings here as everything is spawned in the background
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
wd=$PWD

if [ $# -ne 1 ] ; then
	echo "Requires one argument, the chromosome"
	exit
fi




#	for chr in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X ; do
#	nohup ./create_somatic_vcfs.bash $chr &
#	done




chr=$1

mkdir -p 983899.default
cd 983899.default

#	Currently in development and keeping all, which will make first output large.


#	Select all alleles from all positions called from only high quality,
#	with the added sample and allele depth tags (AD and DP)

#bcftools mpileup --max-depth 999999 --min-MQ 60 --annotate 'FORMAT/AD,FORMAT/DP' --regions ${chr} --fasta-ref /raid/refs/fasta/hg38_num_noalts.fa $wd/983899.recaled.bam | bcftools call --keep-alts --multiallelic-caller -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools mpileup --max-depth 999999 --min-MQ 60 --annotate 'FORMAT/AD,FORMAT/DP' --regions ${chr} --fasta-ref /raid/refs/fasta/hg38_num_noalts.fa $wd/983899.recaled.bam | bcftools call --variants-only --keep-alts --multiallelic-caller -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.vcf.count

#	983899 - 2787476084 ( nearly 3 billion as expected )


#	Select only SNPs with DP between 10 and 100

bcftools view -i "TYPE='SNP' && DP>10 && DP<100" -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.count

#	983899 - 246632193 ( Down to about 10% )



bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz






exit





#	After all run


bcftools concat -Oz -o 983899.recaled.mpileup.MQ60.call.SNP.DP.vcf.gz 983899.recaled.[1-9].mpileup.MQ60.call.SNP.DP.vcf.gz 983899.recaled.1?.mpileup.MQ60.call.SNP.DP.vcf.gz 983899.recaled.2?.mpileup.MQ60.call.SNP.DP.vcf.gz 983899.recaled.X.mpileup.MQ60.call.SNP.DP.vcf.gz

bcftools index 983899.recaled.mpileup.MQ60.call.SNP.DP.vcf.gz


bcftools isec -p 983899.recaled.default.somatic /raid/data/raw/CCLS/bam/983899.default/983899.recaled.mpileup.MQ60.call.SNP.DP.vcf.gz /raid/data/raw/CCLS/bam/983899.somatic/983899.recaled.mpileup.MQ60.call.SNP.DP.vcf.gz

