#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

#	really should've done this

for sample in GM_983899 983899 ; do
#for sample in GM_983899 ; do
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
					echo "f1 and f2 are the same. Not comparing. Continuing."
					continue
				fi

				b1=${f1%%.vcf.gz}
				b1=${b1##${sample}.${reference}.}
				b2=${f2%%.vcf.gz}
				b2=${b2##${sample}.${reference}.}
				echo $b1 $b2
				outdir=${sample}-${reference}-${b1}-${b2}
				if [ -d ${outdir} ] && [ ! -w ${outdir} ] ; then
					echo "${outdir} already exists, so skipping."
				else
					cmd="bcftools isec -p ${sample}-${reference}-${b1}-${b2} $f1 $f2"
					echo ${cmd}
					${cmd}
					chmod a-w ${outdir}
				fi

				counts="${outdir}.txt"
				if [ -f ${counts} ] && [ ! -w ${counts} ] ; then
					echo "${counts} already exists, so skipping."
				else
					echo "Counting intersection results."
					c1=$( bcftools query -i 'TYPE="SNP"' -f '\n' ${outdir}/0000.vcf | wc -l )
					c2=$( bcftools query -i 'TYPE="SNP"' -f '\n' ${outdir}/0001.vcf | wc -l )
					cboth=$( bcftools query -i 'TYPE="SNP"' -f '\n' ${outdir}/0002.vcf | wc -l )
					echo "${b1}	${c1}"  > ${counts}
					echo "${b2}	${c2}" >> ${counts}
					echo "Both	${cboth}" >> ${counts}

					chmod a-w ${counts}
				fi


			done
		done
	done
done


