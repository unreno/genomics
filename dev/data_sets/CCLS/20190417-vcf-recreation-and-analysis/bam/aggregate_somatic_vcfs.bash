#!/usr/bin/env bash


# pointless settings here as everything is spawned in the background
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
wd=$PWD
bam_dir=/raid/data/raw/CCLS/bam

if [ $# -ne 1 ] ; then
	echo "Requires one argument: the sample id"
	exit
fi

#	nohup ./aggregate_somatic_vcfs.bash 983899 &

#	for chr in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X ; do
#	done

base_sample=$1
#chr=$2

#mkdir -p ${base_sample}.somatic
cd ${base_sample}.somatic

#	Currently in development and keeping all, which will make first output large.


#	Select all alleles from all positions called from only high quality,
#	with the added sample and allele depth tags (AD and DP)

for sample in ${base_sample} GM_${base_sample} ; do
	
	if [ ! -f ${bam_dir}/${sample}.recaled.bam ] ;  then
		echo "${bam_dir}/${sample}.recaled.bam not found. Skipping."
		continue
	fi

	for AF in $( seq 0.20 0.01 0.50 ) ; do

		f=${sample}.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			bcftools concat -Oz -o ${sample}.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz \
				${sample}.recaled.[1-9].mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz \
				${sample}.recaled.1?.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz \
				${sample}.recaled.2?.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz \
				${sample}.recaled.X.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz
			chmod a-w ${f}
		fi

		f=${sample}.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz.csi
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			bcftools index ${sample}.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz
			chmod a-w ${f}
		fi

		f=${sample}.${AF}.count_trinuc_muts.input.txt
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t+\t${sample}\n" \
				${sample}.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.${AF}.vcf.gz \
				> ${f}
			chmod a-w ${f}
		fi

		f=${sample}.${AF}.count_trinuc_muts.txt
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			/home/jake/.github/mcjarvis/Mutation-Signatures-Including-APOBEC-in-Cancer-Cell-Lines-JNCI-CS-Supplementary-Scripts/count_trinuc_muts_v8.pl pvcf /raid/refs/fasta/hg38_num_noalts.fa \
				${sample}.${AF}.count_trinuc_muts.input.txt
			mv ${sample}.${AF}.count_trinuc_muts.input.txt.*.count.txt ${f}
			chmod a-w ${f}
		fi

		f=${sample}.${AF}.count_trinuc_muts.counts.txt
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			tail -n +2 ${sample}.${AF}.count_trinuc_muts.txt \
				| awk -F"\t" '{print $7}' | sort | uniq -c \
				> ${f}
			chmod a-w ${f}
		fi

	done	#	AF

done	#	sample

