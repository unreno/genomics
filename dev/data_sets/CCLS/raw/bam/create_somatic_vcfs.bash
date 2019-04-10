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

chr=$1

mkdir -p 983899.somatic
cd 983899.somatic

#	Currently in development and keeping all, which will make first output large.

bcftools mpileup --max-depth 999999 --min-MQ 60 --annotate 'FORMAT/AD,FORMAT/DP' --regions ${chr} --fasta-ref /raid/refs/fasta/hg38_num_noalts.fa $wd/983899.recaled.bam | bcftools call --keep-alts --multiallelic-caller -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.vcf.count

bcftools view -i "TYPE='SNP' && DP>10 && DP<100" -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.count

bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz

bcftools annotate -a /raid/refs/vcf/gnomad.genomes.r2.0.2.sites.liftover.b38/gnomad.genomes.r2.0.2.sites.chr${chr}.liftover.b38.vcf.gz --columns ID,GNOMAD_AC:=AC,GNOMAD_AN:=AN,GNOMAD_AF:=AF -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.count

bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz

bcftools view -i "GNOMAD_AF == '' || GNOMAD_AF < 0.001" -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.vcf.count

bcftools view -i '(FMT/AD[0:1] >= 3 && (FMT/AD[0:1]/FMT/DP) >= 0.05 && (FMT/AD[0:1]/FMT/DP) <= 0.25 ) || (FMT/AD[0:2] >= 3 && (FMT/AD[0:2]/FMT/DP) >= 0.05 && (FMT/AD[0:2]/FMT/DP) <= 0.25 ) || (FMT/AD[0:3] >= 3 && (FMT/AD[0:3]/FMT/DP) >= 0.05 && (FMT/AD[0:3]/FMT/DP) <= 0.25 )' -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.count



#cat *mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.count | awk '{s+=$1}END{print s}'
#
#bcftools concat -Oz -o 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz 983899.recaled.[1-9].mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz 983899.recaled.1?.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz 983899.recaled.2?.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz 983899.recaled.X.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz
#
#bcftools index 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz
#
#mkdir 983899.recaled.mpileup.filtered-strelka
#
#bcftools isec -c all -n =2 -w 2 -r 1 -p 983899.recaled.mpileup.filtered-strelka ../vcf/983899.hg38_num_noalts.loc.strelka.filtered/TUMOR.vcf.gz 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz
#
#bcftools isec -p 983899.recaled.mpileup.filtered-strelka /raid/data/raw/CCLS/vcf/983899.hg38_num_noalts.loc.strelka.filtered/TUMOR.vcf.gz 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF2.AD.vcf.gz
#
