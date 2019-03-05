#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

#	really should've done this

#for sample in GM_983899 983899 ; do
for sample in GM_983899 ; do
	echo "Processing sample ${sample}"

	for reference in hg38_chr_alts hg38_num_noalts ; do
		echo "Processing reference ${reference}"

		#	Sample.Reference.Alignment.Caller.vcf.gz

		for f1 in ${sample}.${reference}.*vcf.gz ; do
			echo "--------------------------------------------------"
			echo $f1

			for f2 in ${sample}.${reference}.*vcf.gz ; do
				echo $f2

				index="${f2}.tbi"
				if [ -f ${index} ] && [ ! -w ${index} ]  ; then
					echo "${index} already exists, so skipping."
				else
					echo "Indexing $f2"
					bcftools index --tbi $f2
					chmod a-w ${index}
				fi

				if [ $f1 == $f2 ] ; then
					echo "f1 and f2 are the same. Skipping."
				else
					b1=${f1%%.vcf.gz}
					b1=${b1##${sample}.${reference}.}
					b2=${f2%%.vcf.gz}
					b2=${b2##${sample}.${reference}.}
					echo $b1 $b2
					echo "bcftools isec -p ${sample}-${b1}-${b2} $f1 $f2"
					bcftools isec -p ${b1}-${b2} $f1 $f2
				fi

			done
		done
	done
done


