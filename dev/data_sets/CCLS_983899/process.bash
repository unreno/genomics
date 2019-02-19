#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


#	really should've done this

for sample in GM_983899 983899 ; do
	echo "Processing ${sample}"

	bam="${sample}.hg38.bam"
	if [ -f ${bam} ] && [ ! -w ${bam} ]  ; then
		echo "${bam} already exists, so skipping."
	else

		sam="${sample}.name.hg38.sam"
		if [ -f ${sam} ] && [ ! -w ${sam} ]  ; then
			echo "${sam} already exists, so skipping."
		else

			echo "Aligning fastq data creating ${sam}"	
			bowtie2 --rg-id 1 --rg SM:${sample} --rg LB:unknownLB --rg PL:unknownPL --rg PU:unknownPU \
				-x hg38 -1 ${sample}.1.fastq.gz -2 ${sample}.2.fastq.gz --very-sensitive --threads 40 \
				-S ${sam} > ${sample}.bowtie2.out 2> ${sample}.bowtie2.err
			chmod a-w ${sam}

		fi

		sam_count="${sample}.name.hg38.sam.count"
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

	PPbam="${sample}.hg38.PP.bam"
	if [ -f ${PPbam} ] && [ ! -w ${PPbam} ]  ; then
		echo "${PPbam} already exists, so skipping."
	else
		echo "Selecting proper paired reads from ${bam} creating ${PPbam}"
		samtools view -f 2 -@ 39 -o ${PPbam} ${bam} > ${PPbam}.out 2> ${PPbam}.err
		chmod a-w ${PPbam}
	fi


	for core in hg38 hg38.PP ; do
		echo "Processing ${core}"

		base=${sample}.${core}
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

		vcf=${base}.vcf.gz
		if [ -f ${vcf} ] && [ ! -w ${vcf} ]  ; then
			echo "${vcf} already exists, so skipping."
		else
			echo "Creating ${vcf} from ${bam}"
			gatk HaplotypeCaller --input ${bam} \
				--output ${vcf} \
				--reference /raid/refs/fasta/hg38.fa.gz > ${vcf}.out 2> ${vcf}.err
			chmod a-w ${vcf}
		fi

	done

done

