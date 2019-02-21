#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


#	really should've done this

for sample in GM_983899 983899 ; do
	echo "Processing sample ${sample}"

	for reference in hg38_chr_alts hg38_num_noalts ; do
		echo "Processing reference ${reference}"

		for alignment in e2e ; do
			echo "Processing alignment ${alignment}"

			bam="${sample}.${reference}.${alignment}.bam"
			if [ -f ${bam} ] && [ ! -w ${bam} ]  ; then
				echo "${bam} already exists, so skipping."
			else
		
				sam="${sample}.${reference}.${alignment}.name.sam"
				if [ -f ${sam} ] && [ ! -w ${sam} ]  ; then
					echo "${sam} already exists, so skipping."
				else

					if [ $alignment = 'e2e' ] ; then
						bowtie2_alignment="--very-sensitive"
					else
						bowtie2_alignment="--very-sensitive-local"
					fi
		
					echo "Aligning fastq data creating ${sam} using ${bowtie2_alignment}"
					bowtie2 --rg-id 1 --rg SM:${sample} --rg LB:unknownLB --rg PL:unknownPL --rg PU:unknownPU \
						-x ${reference} -1 ${sample}.1.fastq.gz -2 ${sample}.2.fastq.gz ${bowtie2_alignment} --threads 40 \
						-S ${sam} > ${sam}.out 2> ${sam}.err
					chmod a-w ${sam}
		
				fi
		
				sam_count="${sample}.${reference}.${alignment}.sam.count"
				if [ -f ${sam_count} ] && [ ! -w ${sam_count} ]  ; then
					echo "${sam_count} already exists, so skipping."
				else
					echo "Counting reads in ${sam}"
					samtools view -@ 39 -c ${sam} > ${sam_count} 2> ${sam_count}.err
					chmod a-w ${sam_count}
				fi
		
				echo "Sorting ${sam} creating ${bam}"
				gatk SortSam --INPUT ${sam} --OUTPUT ${bam} \
					--SORT_ORDER coordinate > ${bam}.out 2> ${bam}.err
				chmod a-w ${bam}
		
			fi
		
			PPbam="${sample}.${reference}.${alignment}_PP.bam"
			if [ -f ${PPbam} ] && [ ! -w ${PPbam} ]  ; then
				echo "${PPbam} already exists, so skipping."
			else
				echo "Selecting proper paired reads from ${bam} creating ${PPbam}"
				samtools view -f 2 -@ 39 -o ${PPbam} ${bam} > ${PPbam}.out 2> ${PPbam}.err
				chmod a-w ${PPbam}
			fi
	
			for core in ${alignment} ${alignment}_PP ; do
				echo "Processing ${core}"
	
	#	Sample.Reference.Alignment.Caller.vcf.gz
	
	#	../CCLS/vcf/GM_983899.e2e_PP.bcftools-c.vcf.gz
	#	../CCLS/vcf/GM_983899.e2e_PP.bcftools-m.vcf.gz
	#	../CCLS/vcf/GM_983899.e2e_PP.gatk.vcf.gz
	#	../CCLS/vcf/GM_983899.loc.bcftools-c.vcf.gz
	#	../CCLS/vcf/GM_983899.loc.bcftools-m.vcf.gz
	#	../CCLS/vcf/GM_983899.loc.gatk.vcf.gz
	
		
				base=${sample}.${reference}.${core}
				bam=${base}.bam
				index=${bam}.bai
				if [ -f ${index} ] && [ ! -w ${index} ]  ; then
					echo "${index} already exists, so skipping."
				else
					echo "Indexing ${bam}"
					samtools index -@ 40 ${bam} > ${index}.out 2> ${index}.err
					chmod a-w ${index}
				fi
		
				bam_count=${bam}.count
				if [ -f ${bam_count} ] && [ ! -w ${bam_count} ]  ; then
					echo "${bam_count} already exists, so skipping."
				else
					echo "Counting ${bam}"
					samtools view -@ 39 -c ${bam} > ${bam_count} 2> ${bam_count}.err
					chmod a-w ${bam_count}
				fi
		
				flagstat=${base}.flagstat.txt
				if [ -f ${flagstat} ] && [ ! -w ${flagstat} ]  ; then
					echo "${flagstat} already exists, so skipping."
				else
					echo "Getting flagstats ${bam}"
					samtools flagstat -@ 39 ${bam} > ${flagstat} 2> ${flagstat}.err
					chmod a-w ${flagstat}
				fi
		
				vcf=${base}.gatk.vcf.gz
				if [ -f ${vcf} ] && [ ! -w ${vcf} ]  ; then
					echo "${vcf} already exists, so skipping."
				else
					echo "Creating ${vcf} from ${bam}. Can take 24 hours."
#	--max-reads-per-alignment-start:Integer
#		Maximum number of reads to retain per alignment start position. Reads above this threshold
#		will be downsampled. Set to 0 to disable.  Default value: 50. 


#						--max-reads-per-alignment-start 0 \
					gatk HaplotypeCaller --input ${bam} \
						--output ${vcf} \
						--native-pair-hmm-threads 40 \
						--dbsnp /raid/refs/vcf/dbsnp_146.${reference}.vcf.gz \
						--reference /raid/refs/fasta/${reference}.fa.gz > ${vcf}.out 2> ${vcf}.err
					chmod a-w ${vcf}
				fi
		
				vcf=${base}.bcftools-c.vcf.gz
				if [ -f ${vcf} ] && [ ! -w ${vcf} ]  ; then
					echo "${vcf} already exists, so skipping."
				else
					echo "Creating ${vcf} from ${bam}"
#					bcftools mpileup --output-type u \
#						--fasta-ref /raid/refs/fasta/${reference}.fa.gz ${bam} \
#						| bcftools call --consensus-caller --variants-only --threads 9 \
#						--output-type z -o ${vcf} > ${vcf}.out 2> ${vcf}.err
#					chmod a-w ${vcf}
				fi
		
				vcf=${base}.bcftools-m.vcf.gz
				if [ -f ${vcf} ] && [ ! -w ${vcf} ]  ; then
					echo "${vcf} already exists, so skipping."
				else
					echo "Creating ${vcf} from ${bam}"
#					bcftools mpileup --output-type u \
#						--fasta-ref /raid/refs/fasta/${reference}.fa.gz ${bam} \
#						| bcftools call --multiallelic-caller --variants-only --threads 9 \
#						--output-type z -o ${vcf} > ${vcf}.out 2> ${vcf}.err
#					chmod a-w ${vcf}
				fi
		
			done
		done
	done
done


#	Processing sample GM_983899
#	Processing reference hg38_chr_alts
#	Processing alignment e2e
#	Aligning fastq data creating GM_983899.hg38_chr_alts.e2e.name.sam using --very-sensitive
#	Counting reads in GM_983899.hg38_chr_alts.e2e.name.sam
#	Sorting GM_983899.hg38_chr_alts.e2e.name.sam creating GM_983899.hg38_chr_alts.e2e.bam
#	Selecting proper paired reads from GM_983899.hg38_chr_alts.e2e.bam creating GM_983899.hg38_chr_alts.e2e_PP.bam
#	Processing e2e
#	Indexing GM_983899.hg38_chr_alts.e2e.bam
#	Counting GM_983899.hg38_chr_alts.e2e.bam
#	Creating GM_983899.hg38_chr_alts.e2e.gatk.vcf.gz from GM_983899.hg38_chr_alts.e2e.bam
#	Creating GM_983899.hg38_chr_alts.e2e.bcftools-c.vcf.gz from GM_983899.hg38_chr_alts.e2e.bam
#	Creating GM_983899.hg38_chr_alts.e2e.bcftools-m.vcf.gz from GM_983899.hg38_chr_alts.e2e.bam
#	Processing e2e_PP
#	Indexing GM_983899.hg38_chr_alts.e2e_PP.bam
#	Counting GM_983899.hg38_chr_alts.e2e_PP.bam
#	Creating GM_983899.hg38_chr_alts.e2e_PP.gatk.vcf.gz from GM_983899.hg38_chr_alts.e2e_PP.bam
#	Creating GM_983899.hg38_chr_alts.e2e_PP.bcftools-c.vcf.gz from GM_983899.hg38_chr_alts.e2e_PP.bam
#	Creating GM_983899.hg38_chr_alts.e2e_PP.bcftools-m.vcf.gz from GM_983899.hg38_chr_alts.e2e_PP.bam
#	Processing reference hg38_num_noalts
#	Processing alignment e2e
#	Aligning fastq data creating GM_983899.hg38_num_noalts.e2e.name.sam using --very-sensitive
#	Counting reads in GM_983899.hg38_num_noalts.e2e.name.sam
#	Sorting GM_983899.hg38_num_noalts.e2e.name.sam creating GM_983899.hg38_num_noalts.e2e.bam
#	Selecting proper paired reads from GM_983899.hg38_num_noalts.e2e.bam creating GM_983899.hg38_num_noalts.e2e_PP.bam
#	Processing e2e
#	Indexing GM_983899.hg38_num_noalts.e2e.bam
#	Counting GM_983899.hg38_num_noalts.e2e.bam
#	Creating GM_983899.hg38_num_noalts.e2e.gatk.vcf.gz from GM_983899.hg38_num_noalts.e2e.bam
#	Creating GM_983899.hg38_num_noalts.e2e.bcftools-c.vcf.gz from GM_983899.hg38_num_noalts.e2e.bam
#	Creating GM_983899.hg38_num_noalts.e2e.bcftools-m.vcf.gz from GM_983899.hg38_num_noalts.e2e.bam
#	Processing e2e_PP
#	Indexing GM_983899.hg38_num_noalts.e2e_PP.bam
#	Counting GM_983899.hg38_num_noalts.e2e_PP.bam
#	Creating GM_983899.hg38_num_noalts.e2e_PP.gatk.vcf.gz from GM_983899.hg38_num_noalts.e2e_PP.bam
#	Creating GM_983899.hg38_num_noalts.e2e_PP.bcftools-c.vcf.gz from GM_983899.hg38_num_noalts.e2e_PP.bam
#	Creating GM_983899.hg38_num_noalts.e2e_PP.bcftools-m.vcf.gz from GM_983899.hg38_num_noalts.e2e_PP.bam
#	Processing sample 983899
#	Processing reference hg38_chr_alts
#	Processing alignment e2e
#	Aligning fastq data creating 983899.hg38_chr_alts.e2e.name.sam using --very-sensitive
#	Counting reads in 983899.hg38_chr_alts.e2e.name.sam
#	Sorting 983899.hg38_chr_alts.e2e.name.sam creating 983899.hg38_chr_alts.e2e.bam
#	Selecting proper paired reads from 983899.hg38_chr_alts.e2e.bam creating 983899.hg38_chr_alts.e2e_PP.bam
#	Processing e2e
#	Indexing 983899.hg38_chr_alts.e2e.bam
#	Counting 983899.hg38_chr_alts.e2e.bam
#	Creating 983899.hg38_chr_alts.e2e.gatk.vcf.gz from 983899.hg38_chr_alts.e2e.bam
#	Creating 983899.hg38_chr_alts.e2e.bcftools-c.vcf.gz from 983899.hg38_chr_alts.e2e.bam
#	Creating 983899.hg38_chr_alts.e2e.bcftools-m.vcf.gz from 983899.hg38_chr_alts.e2e.bam
#	Processing e2e_PP
#	Indexing 983899.hg38_chr_alts.e2e_PP.bam
#	Counting 983899.hg38_chr_alts.e2e_PP.bam
#	Creating 983899.hg38_chr_alts.e2e_PP.gatk.vcf.gz from 983899.hg38_chr_alts.e2e_PP.bam
#	Creating 983899.hg38_chr_alts.e2e_PP.bcftools-c.vcf.gz from 983899.hg38_chr_alts.e2e_PP.bam
#	Creating 983899.hg38_chr_alts.e2e_PP.bcftools-m.vcf.gz from 983899.hg38_chr_alts.e2e_PP.bam
#	Processing reference hg38_num_noalts
#	Processing alignment e2e
#	Aligning fastq data creating 983899.hg38_num_noalts.e2e.name.sam using --very-sensitive
#	Counting reads in 983899.hg38_num_noalts.e2e.name.sam
#	Sorting 983899.hg38_num_noalts.e2e.name.sam creating 983899.hg38_num_noalts.e2e.bam
#	Selecting proper paired reads from 983899.hg38_num_noalts.e2e.bam creating 983899.hg38_num_noalts.e2e_PP.bam
#	Processing e2e
#	Indexing 983899.hg38_num_noalts.e2e.bam
#	Counting 983899.hg38_num_noalts.e2e.bam
#	Creating 983899.hg38_num_noalts.e2e.gatk.vcf.gz from 983899.hg38_num_noalts.e2e.bam
#	Creating 983899.hg38_num_noalts.e2e.bcftools-c.vcf.gz from 983899.hg38_num_noalts.e2e.bam
#	Creating 983899.hg38_num_noalts.e2e.bcftools-m.vcf.gz from 983899.hg38_num_noalts.e2e.bam
#	Processing e2e_PP
#	Indexing 983899.hg38_num_noalts.e2e_PP.bam
#	Counting 983899.hg38_num_noalts.e2e_PP.bam
#	Creating 983899.hg38_num_noalts.e2e_PP.gatk.vcf.gz from 983899.hg38_num_noalts.e2e_PP.bam
#	Creating 983899.hg38_num_noalts.e2e_PP.bcftools-c.vcf.gz from 983899.hg38_num_noalts.e2e_PP.bam
#	Creating 983899.hg38_num_noalts.e2e_PP.bcftools-m.vcf.gz from 983899.hg38_num_noalts.e2e_PP.bam

