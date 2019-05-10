#!/usr/bin/env bash


# pointless settings here as everything is spawned in the background
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
wd=$PWD
bam_dir=/raid/data/raw/CCLS/bam
strelka_dir=/raid/data/working/CCLS/20190205-vcf-tumor-normal/strelka

if [ $# -ne 1 ] ; then
	echo "Requires one argument: the sample id"
	exit
fi

#	nohup ./aggregate_somatic_vcfs.bash 983899 &

base_sample=$1

cd ${base_sample}.somatic

if [ -f ${strelka-dir}/${base_sample}.hg38_num_noalts.loc/results/variants/somatic.snvs.vcf.gz ] ; then

	f=${base_sample}.strelka.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		mkdir -p strelka_tmp
		bcftools +split ${strelka_dir}/${base_sample}.hg38_num_noalts.loc/results/variants/somatic.snvs.vcf.gz \
			--output-type z --output strelka_tmp
		bcftools view --types snps --output-type z --output-file ${f} strelka_tmp/TUMOR.vcf.gz
		chmod a-w $f
		/bin/rm -rf strelka_tmp
	fi

	f=${base_sample}.strelka.vcf.gz.csi
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools index ${base_sample}.strelka.vcf.gz
		chmod a-w $f
	fi

	f=${base_sample}.strelka.allele_ratios.csv.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		strelka_vcf_to_allele_ratios.bash ${base_sample}.strelka.vcf.gz | gzip --best > ${f}
		chmod a-w $f
	fi

	f=${base_sample}.strelka.nonzero_af_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		zcat ${base_sample}.strelka.allele_ratios.csv.gz | tail -n +2 | \
			awk -F"\t" '{c=0;for(i=3;i<=NF;i++) if($i>0)c++;print c}' | sort | uniq -c > ${f}
		chmod a-w $f
	fi

	f=${base_sample}.strelka.vcf.count
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools query -f "\n" ${base_sample}.strelka.vcf.gz | wc -l > $f
		chmod a-w $f
	fi

	f=${base_sample}.strelka.filtered.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools view --include "FILTER='PASS'" --output-type z --output-file $f ${base_sample}.strelka.vcf.gz
		chmod a-w $f
	fi

	f=${base_sample}.strelka.filtered.vcf.gz.csi
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools index ${base_sample}.strelka.filtered.vcf.gz
		chmod a-w $f
	fi

	f=${base_sample}.strelka.filtered.vcf.count
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bcftools query -f "\n" ${base_sample}.strelka.filtered.vcf.gz | wc -l > $f
		chmod a-w $f
	fi

	f=${base_sample}.strelka.filtered.allele_ratios.csv.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		strelka_vcf_to_allele_ratios.bash ${base_sample}.strelka.filtered.vcf.gz | gzip --best > ${f}
		chmod a-w $f
	fi

	f=${base_sample}.strelka.filtered.nonzero_af_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		zcat ${base_sample}.strelka.filtered.allele_ratios.csv.gz | tail -n +2 | \
			awk -F"\t" '{c=0;for(i=3;i<=NF;i++) if($i>0)c++;print c}' | sort | uniq -c > ${f}
		chmod a-w $f
	fi

	f=${base_sample}.strelka.filtered.allele_ratios.csv.gz.histogram.png
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		allele_ratio_histogram.py ${base_sample}.strelka.filtered.allele_ratios.csv.gz
		chmod a-w $f
	fi

	f=${base_sample}.strelka.filtered.count_trinuc_muts.input.txt
	if [ -f ${f} ] && [ ! -w ${f} ] ; then
		echo "Write-protected ${f} exists. Skipping."
	else
		echo "Creating ${f}"
		bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t+\t${base_sample}\n" \
			${base_sample}.strelka.filtered.vcf.gz \
			> ${f}
		chmod a-w ${f}
	fi

	f=${base_sample}.strelka.filtered.count_trinuc_muts.txt.gz
	if [ -f ${f} ] && [ ! -w ${f} ] ; then
		echo "Write-protected ${f} exists. Skipping."
	else
		echo "Creating ${f}"
		/home/jake/.github/jakewendt/Mutation-Signatures/count_trinuc_muts_v8.pl pvcf \
			/raid/refs/fasta/hg38_num_noalts.fa \
			${base_sample}.strelka.filtered.count_trinuc_muts.input.txt | gzip --best >> ${f}
		chmod a-w ${f}
	fi

	f=${base_sample}.strelka.filtered.count_trinuc_muts.counts.txt
	if [ -f ${f} ] && [ ! -w ${f} ] ; then
		echo "Write-protected ${f} exists. Skipping."
	else
		echo "Creating ${f}"
		#tail -n +2 ${base_sample}.strelka.filtered.count_trinuc_muts.txt \
		zcat ${base_sample}.strelka.filtered.count_trinuc_muts.txt.gz \
			| tail -n +2 | awk -F"\t" '{print $7}' | sort | uniq -c \
			> ${f}
		chmod a-w ${f}
	fi

fi





for sample in ${base_sample} GM_${base_sample} ; do

	if [ ! -f ${bam_dir}/${sample}.recaled.bam ] ;  then
		echo "${bam_dir}/${sample}.recaled.bam not found. Skipping."
		continue
	fi


	base=${sample}.recaled
	suffix=""
	for new_suffix in mpileup.MQ60.call.SNP .DP200 .annotate.GNOMAD_AF .Bias ; do 
		suffix=${suffix}${new_suffix}

		f=${base}.${suffix}.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			bcftools concat --output-type z --output ${f} \
				${base}.[1-9].${suffix}.vcf.gz \
				${base}.1?.${suffix}.vcf.gz \
				${base}.2?.${suffix}.vcf.gz \
				${base}.X.${suffix}.vcf.gz
			chmod a-w ${f}
		fi

		f=${base}.${suffix}.vcf.gz.csi
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			bcftools index ${base}.${suffix}.vcf.gz
			chmod a-w ${f}
		fi

		f=${base}.${suffix}.vcf.count
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			bcftools query -f "\n" ${base}.${suffix}.vcf.gz | wc -l > $f
			chmod a-w $f
		fi

		f=${base}.${suffix}.allele_ratios.csv.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			vcf_to_allele_ratios.bash ${base}.${suffix}.vcf.gz | gzip --best > ${f}
			chmod a-w $f
		fi

		f=${base}.${suffix}.nonzero_af_counts
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			zcat ${base}.${suffix}.allele_ratios.csv.gz | tail -n +2 | \
				awk -F"\t" '{c=0;for(i=3;i<=NF;i++) if($i>0)c++;print c}' | sort | uniq -c > ${f}
			chmod a-w $f
		fi

		f=${base}.${suffix}.allele_ratios.csv.gz.histogram.png
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			allele_ratio_histogram.py ${base}.${suffix}.allele_ratios.csv.gz
			chmod a-w $f
		fi

#		f=${base}.${suffix}.count_trinuc_muts.input.txt
#		if [ -f ${f} ] && [ ! -w ${f} ] ; then
#			echo "Write-protected ${f} exists. Skipping."
#		else
#			echo "Creating ${f}"
#			bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t+\t${sample}\n" \
#				${base}.${suffix}.vcf.gz \
#				> ${f}
#			chmod a-w ${f}
#		fi
#
#		f=${base}.${suffix}.count_trinuc_muts.txt
#		fgz=${f}.gz
#		if [ -f ${fgz} ] && [ ! -w ${fgz} ] ; then
#			echo "Write-protected ${fgz} exists. Skipping."
#		else
#			if [ -f ${f} ] && [ ! -w ${f} ] ; then
#				echo "Write-protected ${f} exists. Skipping."
#			else
#				echo "Creating ${f}"
#				/home/jake/.github/jakewendt/Mutation-Signatures/count_trinuc_muts_v8.pl pvcf \
#					/raid/refs/fasta/hg38_num_noalts.fa \
#					${base}.${suffix}.count_trinuc_muts.input.txt
#				mv ${base}.${suffix}.count_trinuc_muts.input.txt.*.count.txt ${f}
#				chmod a-w ${f}
#			fi
#			gzip --best ${f}
#		fi
#
#		f=${base}.${suffix}.count_trinuc_muts.counts.txt
#		if [ -f ${f} ] && [ ! -w ${f} ] ; then
#			echo "Write-protected ${f} exists. Skipping."
#		else
#			echo "Creating ${f}"
#			#tail -n +2 ${base}.${suffix}.count_trinuc_muts.txt \
#			zcat ${base}.${suffix}.count_trinuc_muts.txt.gz \
#				| tail -n +2 | awk -F"\t" '{print $7}' | sort | uniq -c \
#				> ${f}
#			chmod a-w ${f}
#		fi

	done


	for AF in $( seq 0.20 0.01 0.50 ) ; do

		base=${sample}.recaled
		suffix=mpileup.MQ60.call.SNP.DP200.annotate.GNOMAD_AF.Bias.AD.${AF}

		f=${base}.${suffix}.vcf.gz
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			bcftools concat --output-type z --output ${f} \
				${base}.[1-9].${suffix}.vcf.gz \
				${base}.1?.${suffix}.vcf.gz \
				${base}.2?.${suffix}.vcf.gz \
				${base}.X.${suffix}.vcf.gz
			chmod a-w ${f}
		fi

		f=${base}.${suffix}.vcf.gz.csi
		if [ -f ${f} ] && [ ! -w ${f} ] ; then
			echo "Write-protected ${f} exists. Skipping."
		else
			echo "Creating ${f}"
			bcftools index ${base}.${suffix}.vcf.gz
			chmod a-w ${f}
		fi

		f=${base}.${suffix}.vcf.count
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			bcftools query -f "\n" ${base}.${suffix}.vcf.gz | wc -l > $f
			chmod a-w $f
		fi

		f=${base}.${suffix}.allele_ratios.csv.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			vcf_to_allele_ratios.bash ${base}.${suffix}.vcf.gz | gzip --best > ${f}
			chmod a-w $f
		fi

		f=${base}.${suffix}.nonzero_af_counts
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			zcat ${base}.${suffix}.allele_ratios.csv.gz | tail -n +2 | \
				awk -F"\t" '{c=0;for(i=3;i<=NF;i++) if($i>0)c++;print c}' | sort | uniq -c > ${f}
			chmod a-w $f
		fi

		f=${base}.${suffix}.allele_ratios.csv.gz.histogram.png
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			allele_ratio_histogram.py ${base}.${suffix}.allele_ratios.csv.gz
			chmod a-w $f
		fi

#		f=${base}.${suffix}.count_trinuc_muts.input.txt
#		if [ -f ${f} ] && [ ! -w ${f} ] ; then
#			echo "Write-protected ${f} exists. Skipping."
#		else
#			echo "Creating ${f}"
#			bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t+\t${sample}\n" \
#				${base}.${suffix}.vcf.gz \
#				> ${f}
#			chmod a-w ${f}
#		fi
#
#		f=${base}.${suffix}.count_trinuc_muts.txt
#		fgz=${f}.gz
#		if [ -f ${fgz} ] && [ ! -w ${fgz} ] ; then
#			echo "Write-protected ${fgz} exists. Skipping."
#		else
#			if [ -f ${f} ] && [ ! -w ${f} ] ; then
#				echo "Write-protected ${f} exists. Skipping."
#			else
#				echo "Creating ${f}"
#				/home/jake/.github/jakewendt/Mutation-Signatures/count_trinuc_muts_v8.pl pvcf \
#					/raid/refs/fasta/hg38_num_noalts.fa \
#					${base}.${suffix}.count_trinuc_muts.input.txt
#				mv ${base}.${suffix}.count_trinuc_muts.input.txt.*.count.txt ${f}
#				chmod a-w ${f}
#			fi
#			gzip --best ${f}
#		fi
#
#		f=${base}.${suffix}.count_trinuc_muts.counts.txt
#		if [ -f ${f} ] && [ ! -w ${f} ] ; then
#			echo "Write-protected ${f} exists. Skipping."
#		else
#			echo "Creating ${f}"
#			#tail -n +2 ${base}.${suffix}.count_trinuc_muts.txt \
#			zcat ${base}.${suffix}.count_trinuc_muts.txt \
#				| tail -n +2 | awk -F"\t" '{print $7}' | sort | uniq -c \
#				> ${f}
#			chmod a-w ${f}
#		fi

	done	#	AF

done	#	sample




if [ -f ${strelka_dir}/${base_sample}.hg38_num_noalts.loc/results/variants/somatic.snvs.vcf.gz ] ; then

for AF in $( seq 0.20 0.01 0.50 ) ; do

	base=${base_sample}.recaled.mpileup.MQ60.call.SNP.DP200.annotate.GNOMAD_AF.Bias.AD.${AF}
	tumor=${base}.vcf.gz
	isec_dir=${base}-strelka
	strelka=${base_sample}.strelka.filtered.vcf.gz

	if [ ! -f ${tumor} ] || [ ! -f ${strelka} ] ; then
		echo "One of the source VCF files does not exist so skipping."
		continue
	fi

	#	NOTE THAT THIS IS A DIRECTORY AND NOT A FILE SO -d AND NOT -f
	if [ -d $isec_dir ] && [ ! -w $isec_dir ] ; then
		echo "Write-protected $isec_dir exists. Skipping."
	else
		echo "Creating $isec_dir"

		mkdir -p $isec_dir
		bcftools isec \
			--output-type z \
			--prefix ${isec_dir} \
			${tumor} \
			${strelka}
		chmod -R a-w $isec_dir
	fi

	for i in 0000 0001 0002 0003 ; do

		#0000.vcf.gz	for records private to	FIRST sample
		#0001.vcf.gz	for records private to	SECOND sample
		#0002.vcf.gz	for records from FIRST sample shared by both
		#0003.vcf.gz	for records from SECOND sample shared by both

		f=${isec_dir}.${i}.count
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			bcftools query -f "\n" ${isec_dir}/${i}.vcf.gz | wc -l > $f
			chmod a-w $f
		fi

	done

done

fi
