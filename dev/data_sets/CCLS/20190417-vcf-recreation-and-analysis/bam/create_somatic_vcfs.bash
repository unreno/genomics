#!/usr/bin/env bash


# pointless settings here as everything is spawned in the background
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
wd=$PWD
bam_dir=/raid/data/raw/CCLS/bam

if [ $# -ne 2 ] ; then
	echo "Requires two arguments: the sample id and the chromosome"
	exit
fi




#	for chr in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X ; do
#	nohup ./create_somatic_vcfs.bash 983899 $chr &
#	done




base_sample=$1
chr=$2

mkdir -p ${base_sample}.somatic
cd ${base_sample}.somatic

#	Currently in development and keeping all, which will make first output large.


#	Select all alleles from all positions called from only high quality,
#	with the added sample and allele depth tags (AD and DP)

for sample in ${base_sample} GM_${base_sample} ; do

	if [ ! -f ${bam_dir}/${sample}.recaled.bam ] ;  then
		echo "${bam_dir}/${sample}.recaled.bam not found. Skipping."
		continue
	fi

	f=${sample}.recaled.${chr}.mpileup.MQ60.call.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools mpileup --max-depth 999999 --min-MQ 60 --annotate 'FORMAT/AD,FORMAT/DP' \
			--regions ${chr} --fasta-ref /raid/refs/fasta/hg38_num_noalts.fa ${bam_dir}/${sample}.recaled.bam \
			| bcftools call --keep-alts --multiallelic-caller --output-type z --output $f
		chmod a-w $f
	fi

	f=${sample}.recaled.${chr}.mpileup.MQ60.call.vcf.gz.csi
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools index ${sample}.recaled.${chr}.mpileup.MQ60.call.vcf.gz
		chmod a-w $f
	fi

	f=${sample}.recaled.${chr}.mpileup.MQ60.call.vcf.count
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools query -f "\n" ${sample}.recaled.${chr}.mpileup.MQ60.call.vcf.gz | wc -l > $f
		chmod a-w $f
	fi




	f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools view --types snps --output-type z \
			--output-file $f ${sample}.recaled.${chr}.mpileup.MQ60.call.vcf.gz
		chmod a-w $f
	fi

	f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.vcf.gz.csi
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools index ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.vcf.gz
		chmod a-w $f
	fi

	f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.vcf.count
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools query -f "\n" ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.vcf.gz | wc -l > $f
		chmod a-w $f
	fi


	#	Tumor 65x, Normal 40x
	#	Select only SNPs with DP between 10 and 200 (~3x coverage)

	for minDP in 10 20 ; do
		for maxDP in 200 ; do
		
			f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.vcf.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				echo "Creating $f"
				bcftools view --include "DP>${minDP} && DP<${maxDP}" --output-type z \
					--output-file $f ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.vcf.gz
				chmod a-w $f
			fi
		
			f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.vcf.gz.csi
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				echo "Creating $f"
				bcftools index ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.vcf.gz
				chmod a-w $f
			fi
		
			f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.vcf.count
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				echo "Creating $f"
				bcftools query -f "\n" ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.vcf.gz | wc -l > $f
				chmod a-w $f
			fi
		
			f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.vcf.gz 
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				echo "Creating $f"
				bcftools annotate -a /raid/refs/vcf/gnomad.genomes.r2.0.2.sites.liftover.b38/gnomad.genomes.r2.0.2.sites.chr${chr}.liftover.b38.vcf.gz --columns ID,GNOMAD_AC:=AC,GNOMAD_AN:=AN,GNOMAD_AF:=AF --output-type z \
					--output $f ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.vcf.gz
				chmod a-w $f
			fi
		
			f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.vcf.gz.csi
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				echo "Creating $f"
				bcftools index ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.vcf.gz
				chmod a-w $f
			fi
		
		
			for gAF in 0.0001 0.001 0.01 ; do

				#	Select only unknown and rare gnomad SNPs.
			
				f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.vcf.gz 
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f"
					bcftools view --include "GNOMAD_AF == '' || GNOMAD_AF < ${gAF}" --output-type z \
						--output-file $f ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.vcf.gz
					chmod a-w $f
				fi
			
				f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.vcf.gz.csi
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f"
					bcftools index ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.vcf.gz
					chmod a-w $f
				fi
			
				f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.vcf.count
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f"
					bcftools query -f "\n" ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.vcf.gz \
						| wc -l > $f
					chmod a-w $f
				fi
			
			
				#	#	3/63 = 0.047...
				#
				#	#	Select only half on the "better" side of these biases
				#	##INFO=<ID=VDB,Number=1,Type=Float,Description="Variant Distance Bias for filtering splice-site artefacts in RNA-seq data (bigger is better)",Version="3">
				#	##INFO=<ID=RPB,Number=1,Type=Float,Description="Mann-Whitney U test of Read Position Bias (bigger is better)">
				#	##INFO=<ID=MQB,Number=1,Type=Float,Description="Mann-Whitney U test of Mapping Quality Bias (bigger is better)">
				#	##INFO=<ID=BQB,Number=1,Type=Float,Description="Mann-Whitney U test of Base Quality Bias (bigger is better)">
				#	##INFO=<ID=MQSB,Number=1,Type=Float,Description="Mann-Whitney U test of Mapping Quality vs Strand Bias (bigger is better)">
				#	##INFO=<ID=MQ0F,Number=1,Type=Float,Description="Fraction of MQ0 reads (smaller is better)">
			
			
				f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.vcf.gz 
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f"
					bcftools view --include 'VDB>0.5 && RPB>0.5 && MQB>0.5 && BQB>0.5 && MQSB>0.5 && MQ0F<0.5' \
						--output-type z --output-file $f \
						${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.vcf.gz
					chmod a-w $f
				fi
			
				f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.vcf.gz.csi
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f"
					bcftools index ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.vcf.gz
					chmod a-w $f
				fi
			
				f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.vcf.count
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f"
					bcftools query -f "\n" \
						${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.vcf.gz \
						| wc -l > $f
					chmod a-w $f
				fi
	
				for minAF in 0.04 0.10 0.20 0.30 ; do
					for maxAF in $( seq 0.20 0.05 0.50 ) ; do
						#(( $(echo "0.1 < 0.2" | bc -l) )) && echo true || echo false
						if (( $( echo "$minAF >= $maxAF" | bc -l ) )) ; then
							continue
						fi
	
						f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.AF${minAF}-${maxAF}.vcf.gz 
						if [ -f $f ] && [ ! -w $f ] ; then
							echo "Write-protected $f exists. Skipping."
						else
							echo "Creating $f"
							bcftools view --include "FMT/AD[0:1] >= 3 && (FMT/AD[0:1]/FMT/DP) >= ${minAF} && (FMT/AD[0:1]/FMT/DP) <= ${maxAF}" \
								--output-type z --output-file $f \
								${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.vcf.gz
							chmod a-w $f
						fi
				
						f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.AF${minAF}-${maxAF}.vcf.gz.csi
						if [ -f $f ] && [ ! -w $f ] ; then
							echo "Write-protected $f exists. Skipping."
						else
							echo "Creating $f"
							bcftools index ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.AF${minAF}-${maxAF}.vcf.gz
							chmod a-w $f
						fi
				
						f=${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.AF${minAF}-${maxAF}.vcf.count
						if [ -f $f ] && [ ! -w $f ] ; then
							echo "Write-protected $f exists. Skipping."
						else
							echo "Creating $f"
							bcftools query -f "\n" \
								${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP${minDP}-${maxDP}.gnomad.gAF0-${gAF}.Bias.AF${minAF}-${maxAF}.vcf.gz \
								| wc -l > $f
							chmod a-w $f
						fi
	
					done	#	maxAF

				done	#	minAF

			done	#	gAF

		done	#	maxDP

	done	#	minDP

done	#	sample







#	Intersect with strelka


#	for AF in $( seq 0.20 0.01 0.50 ) ; do
#	
#		f=${base_sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP10-200.gnomad.GNOMAD_AF.Bias.AD.0.04-${AF}
#	
#		if [ ! -f ${f}.vcf.gz ] || [ ! -f GM_${f}.vcf.gz ] ; then
#			echo "One of the source VCF files does not exist so skipping."
#			continue
#		fi
#	
#		#	NOTE THAT THIS IS A DIRECTORY AND NOT A FILE SO -d AND NOT -f
#		if [ -d $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#	
#			mkdir -p $f
#			bcftools isec --regions ${chr} \
#				--output-type z \
#				--prefix ${f} \
#				${f}.vcf.gz \
#				GM_${f}.vcf.gz
#			chmod -R a-w $f
#		fi
#	
#		for i in 0000 0001 0002 0003 ; do
#	
#			#0000.vcf.gz	for records private to	FIRST sample
#			#0001.vcf.gz	for records private to	SECOND sample
#			#0002.vcf.gz	for records from FIRST sample shared by both
#			#0003.vcf.gz	for records from SECOND sample shared by both
#	
#			f=${base_sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP10-200.gnomad.GNOMAD_AF.Bias.AD.0.04-${AF}.${i}.count
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				echo "Creating $f"
#				bcftools query -f "\n" \
#					${base_sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP10-200.gnomad.GNOMAD_AF.Bias.AD.0.04-${AF}/${i}.vcf.gz \
#					| wc -l > $f
#				chmod a-w $f
#			fi
#	
#		done
#	
#	done	#	AF


