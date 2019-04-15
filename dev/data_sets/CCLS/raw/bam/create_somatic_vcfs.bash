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

mkdir -p 983899.somatic
cd 983899.somatic

#	Currently in development and keeping all, which will make first output large.


#	Select all alleles from all positions called from only high quality,
#	with the added sample and allele depth tags (AD and DP)

bcftools mpileup --max-depth 999999 --min-MQ 60 --annotate 'FORMAT/AD,FORMAT/DP' --regions ${chr} --fasta-ref /raid/refs/fasta/hg38_num_noalts.fa $wd/983899.recaled.bam | bcftools call --keep-alts --multiallelic-caller -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.vcf.count

#	983899 - 2787476084 ( nearly 3 billion as expected )


#	Select only SNPs with DP between 10 and 100

bcftools view -i "TYPE='SNP' && DP>10 && DP<100" -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.count

#	983899 - 246632193 ( Down to about 10% )



bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz

bcftools annotate -a /raid/refs/vcf/gnomad.genomes.r2.0.2.sites.liftover.b38/gnomad.genomes.r2.0.2.sites.chr${chr}.liftover.b38.vcf.gz --columns ID,GNOMAD_AC:=AC,GNOMAD_AN:=AN,GNOMAD_AF:=AF -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.vcf.gz

bcftools index 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz


#	Select only unknown and rare gnomad SNPs.

bcftools view -i "GNOMAD_AF == '' || GNOMAD_AF < 0.001" -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.vcf.count

#	983899 - 242297670 ( sadly, minimal impact )


#	3/63 = 0.047...

#	Select alternate alleles with a depth of at least 3 and a portion between 0.04 and 0.25

bcftools view -i '(FMT/AD[0:1] >= 3 && (FMT/AD[0:1]/FMT/DP) >= 0.04 && (FMT/AD[0:1]/FMT/DP) <= 0.25 ) || (FMT/AD[0:2] >= 3 && (FMT/AD[0:2]/FMT/DP) >= 0.04 && (FMT/AD[0:2]/FMT/DP) <= 0.25 ) || (FMT/AD[0:3] >= 3 && (FMT/AD[0:3]/FMT/DP) >= 0.04 && (FMT/AD[0:3]/FMT/DP) <= 0.25 )' -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.vcf.count

#	983899 - 2124370 ( Under 1% )




#	Select only half on the "better" side of these biases
##INFO=<ID=VDB,Number=1,Type=Float,Description="Variant Distance Bias for filtering splice-site artefacts in RNA-seq data (bigger is better)",Version="3">
##INFO=<ID=RPB,Number=1,Type=Float,Description="Mann-Whitney U test of Read Position Bias (bigger is better)">
##INFO=<ID=MQB,Number=1,Type=Float,Description="Mann-Whitney U test of Mapping Quality Bias (bigger is better)">
##INFO=<ID=BQB,Number=1,Type=Float,Description="Mann-Whitney U test of Base Quality Bias (bigger is better)">
##INFO=<ID=MQSB,Number=1,Type=Float,Description="Mann-Whitney U test of Mapping Quality vs Strand Bias (bigger is better)">
##INFO=<ID=MQ0F,Number=1,Type=Float,Description="Fraction of MQ0 reads (smaller is better)">

bcftools view -i 'VDB>0.5 && RPB>0.5 && MQB>0.5 && BQB>0.5 && MQSB>0.5 && MQ0F<0.5' -Oz -o 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.vcf.gz

bcftools query -f "\n" 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz  | wc -l > 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.count

#	983899 - 108766 ( Under 0.1% )





exit





#	After all run

echo mpileup.MQ60.call.vcf.count
cat *mpileup.MQ60.call.vcf.count | awk '{s+=$1}END{print s}'
echo mpileup.MQ60.call.SNP.DP.vcf.count
cat *mpileup.MQ60.call.SNP.DP.vcf.count | awk '{s+=$1}END{print s}'
echo mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.vcf.count
cat *mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.vcf.count | awk '{s+=$1}END{print s}'
echo mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.vcf.count
cat *mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.vcf.count | awk '{s+=$1}END{print s}'
echo mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.count
cat *mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.count | awk '{s+=$1}END{print s}'


bcftools concat -Oz -o 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz 983899.recaled.[1-9].mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz 983899.recaled.1?.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz 983899.recaled.2?.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz 983899.recaled.X.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz

bcftools index 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz

/bin/rm -rf 983899.recaled.mpileup.filtered-strelka
mkdir 983899.recaled.mpileup.filtered-strelka

bcftools isec -p 983899.recaled.mpileup.filtered-strelka /raid/data/raw/CCLS/vcf/983899.hg38_num_noalts.loc.strelka.filtered/TUMOR.vcf.gz 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz

ll 983899.recaled.mpileup.filtered-strelka




bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t+\t983899\n" 983899.recaled.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.AD.Bias.vcf.gz > 983899.count_trinuc_muts.input.txt

/home/jake/.github/mcjarvis/Mutation-Signatures-Including-APOBEC-in-Cancer-Cell-Lines-JNCI-CS-Supplementary-Scripts/count_trinuc_muts_v8.pl pvcf /raid/refs/fasta/hg38_num_noalts.fa 983899.count_trinuc_muts.input.txt
mv 983899.count_trinuc_muts.input.txt.*.count.txt 983899.count_trinuc_muts.txt

tail -n +2 983899.count_trinuc_muts.txt | awk -F"\t" '{print $7}' | sort | uniq -c > 983899.count_trinuc_muts.counts.txt





bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t+\t983899\n" /raid/data/raw/CCLS/vcf/983899.hg38_num_noalts.loc.strelka.filtered/TUMOR.vcf.gz > 983899_strelka.count_trinuc_muts.input.txt

/home/jake/.github/mcjarvis/Mutation-Signatures-Including-APOBEC-in-Cancer-Cell-Lines-JNCI-CS-Supplementary-Scripts/count_trinuc_muts_v8.pl pvcf /raid/refs/fasta/hg38_num_noalts.fa 983899_strelka.count_trinuc_muts.input.txt
mv 983899_strelka.count_trinuc_muts.input.txt.*.count.txt 983899_strelka.count_trinuc_muts.txt

tail -n +2 983899_strelka.count_trinuc_muts.txt | awk -F"\t" '{print $7}' | sort | uniq -c > 983899_strelka.count_trinuc_muts.counts.txt

