#!/usr/bin/env bash

#	vcfs are numeric (1,2,3 not chr1,chr2,chr3,etc)

#for vcf in /raid/data/raw/20180718-Adam/vcf/*vcf.gz ; do
#for vcf in /raid/data/raw/20180718-Adam/vcf/chr/*vcf.gz ; do
#for vcf in /raid/data/raw/20180718-Adam/vcf/chr/811386*vcf.gz ; do
for vcf in /raid/data/raw/20170804-Adam/VCF/chr/*.chr.vcf.gz ; do
	base=${vcf##*/}
#	base=${base%%.output-HC.vcf.gz}
	base=${base%%.chr.vcf.gz}
	base=${base%%.vcf.gz}
	echo $vcf $base

#	bcftools annotate --rename-chrs /raid/refs/vcf/num_to_chr.txt --output-type z \
#		--output ${base}.chr.vcf.gz ${vcf}
#	chmod 444 ${base}.chr.vcf.gz
#
#	gatk IndexFeatureFile -F ${base}.chr.vcf.gz 
#	chmod 444 ${base}.chr.vcf.gz.tbi

#	gatk VariantRecalibrator --variant ${base}.chr.vcf.gz \
	gatk VariantRecalibrator --variant ${vcf} \
		-resource hapmap,known=false,training=true,truth=true,prior=15.0:/raid/refs/vcf/hapmap_3.3.hg38.vcf.gz \
		-resource omni,known=false,training=true,truth=false,prior=12.0:/raid/refs/vcf/1000G_omni2.5.hg38.vcf.gz \
		-resource 1000G,known=false,training=true,truth=false,prior=10.0:/raid/refs/vcf/1000G_phase1.snps.high_confidence.hg38.vcf.gz \
		-resource dbsnp,known=true,training=false,truth=false,prior=2.0:/raid/refs/vcf/dbsnp_146.hg38.vcf.gz \
		-an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP \
		-mode SNP \
		--rscript-file ${base}.recal.plots.R \
		--output ${base}.recal.chr.vcf.gz \
		--tranches-file ${base}.tranches.txt > ${base}.VariantRecalibrator.txt 2>&1

#		-an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP -an InbreedingCoeff \

done

