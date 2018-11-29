#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


#for bam in $( find /raid/data/raw/1000genomes/phase3/data/ -name *unmapped*bam ) ; do
for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*unmapped*bam ; do
	echo "------------------------------------------------------------"
	base=$( basename $bam )
	subject=${base%.unmapped.ILLUMINA.bwa*}
	echo $bam
	echo $base
	echo $subject

	echo "Processing $subject"


	if [ -f ${subject}.unmapped.count.txt ] && [ ! -w ${subject}.unmapped.count.txt ]  ; then
		echo "Write-protected ${subject}.unmapped.count.txt exists. Skipping step."
	else
		echo "Counting reads in $bam.bai"
		#samtools view -c $bam > ${subject}.unmapped.count.txt
		cat $bam.bai | bamReadDepther | grep "^*\|^#" | awk -F"\t" '{s+=$NF}END{print s}' > ${subject}.unmapped.count.txt
		chmod a-w ${subject}.unmapped.count.txt
	fi

	if [ -f ${subject}.mapped.count.txt ] && [ ! -w ${subject}.mapped.count.txt ]  ; then
		echo "Write-protected ${subject}.mapped.count.txt exists. Skipping step."
	else
		mapped_bam=${bam/.unmapped/.mapped}
		echo "Counting reads in $mapped_bam.bai"
		#	DIFFERENT THAN UNMAPPED
		cat $mapped_bam.bai | bamReadDepther | grep "^#" | awk -F"\t" '{s+=$2+$3}END{print s}' > ${subject}.mapped.count.txt
		chmod a-w ${subject}.mapped.count.txt
	fi

	if [ -f ${subject}.total.count.txt ] && [ ! -w ${subject}.total.count.txt ]  ; then
		echo "Write-protected ${subject}.total.count.txt exists. Skipping step."
	else
		echo "Adding mapped and unmapped read counts."
		echo $( cat ${subject}.mapped.count.txt )"+"$( cat ${subject}.unmapped.count.txt ) | bc > ${subject}.total.count.txt
		chmod a-w ${subject}.total.count.txt
	fi

#	if [ -f ${subject}.fastq.gz ] && [ ! -w ${subject}.fastq.gz ]  ; then
#		echo "Write-protected ${subject}.fastq.gz exists. Skipping step."
#	else
#		echo "Extracting fastq reads from $bam"
#		samtools fastq -N $bam | gzip --best > ${subject}.fastq.gz
#		chmod a-w ${subject}.fastq.gz
#	fi

#	blastn only accepts fasta. Bowtie2 can take either. Not sure if bowtie2 uses the quality

	if [ -f ${subject}.fasta.gz ] && [ ! -w ${subject}.fasta.gz ]  ; then
		echo "Write-protected ${subject}.fasta.gz exists. Skipping step."
	else
		echo "Extracting fasta reads from $bam"
		samtools fasta -N $bam 2>> ${subject}.fasta.log | gzip --best > ${subject}.fasta.gz
		chmod a-w ${subject}.fasta.gz
	fi


#	This block is a lot of viruses, NOT HHV, but keeping the variable

#	for hhv in AY446894.2 EF999921.1 FJ527563.1 GQ221974.1 GQ396662.1 GU937742.2 KF021605.1 KF297339.1 NC_003521.1 NC_006150.1 NC_006273.2 NC_012783.2 NC_016447.1 NC_016448.1 NC_027016.1 NC_033176.1 NC_001664.4 NC_000898.1 ; do

	for hhv in /raid/refs/fasta/virii/*fasta ; do
		hhv=$( basename $hhv .fasta )

		echo "Processing $subject / $hhv"


		if [ -f ${subject}.${hhv}.unsorted.bam ] && [ ! -w ${subject}.${hhv}.unsorted.bam ]  ; then
			echo "Write-protected ${subject}.${hhv}.unsorted.bam exists. Skipping step."
		else
			bowtie2 --threads 35 -f --xeq -x virii/${hhv} --very-sensitive -U ${subject}.fasta.gz 2>> ${subject}.${hhv}.log | samtools view -F 4 -o ${subject}.${hhv}.unsorted.bam -
			chmod a-w ${subject}.${hhv}.unsorted.bam
		fi

		if [ -f ${subject}.${hhv}.sorted.bam ] && [ ! -w ${subject}.${hhv}.sorted.bam ]  ; then
			echo "Write-protected ${subject}.${hhv}.sorted.bam exists. Skipping step."
		else
			echo "Sorting"
			samtools sort -o ${subject}.${hhv}.sorted.bam ${subject}.${hhv}.unsorted.bam
			chmod a-w ${subject}.${hhv}.sorted.bam
		fi

		if [ -f ${subject}.${hhv}.sorted.bam.bai ] && [ ! -w ${subject}.${hhv}.sorted.bam.bai ]  ; then
			echo "Write-protected ${subject}.${hhv}.sorted.bam.bai exists. Skipping step."
		else
			echo "Indexing"
			samtools index ${subject}.${hhv}.sorted.bam
			chmod a-w ${subject}.${hhv}.sorted.bam.bai
		fi

		if [ -f ${subject}.${hhv}.depth.csv ] && [ ! -w ${subject}.${hhv}.depth.csv ]  ; then
			echo "Write-protected ${subject}.${hhv}.depth.csv exists. Skipping step."
		else
			echo "Getting depth"
			samtools depth ${subject}.${hhv}.sorted.bam > ${subject}.${hhv}.depth.csv
			chmod a-w ${subject}.${hhv}.depth.csv
		fi

		if [ -f ${subject}.${hhv}.bowtie2.mapped.count.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped.count.txt ]  ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped.count.txt exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned to ${hhv}"
			#	-F 4 needless here as filtered with this flag above.
			samtools view -c -F 4 ${subject}.${hhv}.unsorted.bam > ${subject}.${hhv}.bowtie2.mapped.count.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped.count.txt
		fi

		if [ -f ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} bowtie2 alignments to total unaligned reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped.count.txt)"/"$(cat ${subject}.unmapped.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt
		fi

		if [ -f ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} bowtie2 alignments to total reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt
		fi

#		if [ -f ${subject}.${hhv}.bowtie2.mapped_center.count.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped_center.count.txt ]  ; then
#			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped_center.count.txt exists. Skipping step."
#		else
#			echo "Counting reads bowtie2 aligned to CENTER of ${hhv} in region ${hhv}:20000-120000"
#			#	-F 4 needless here as filtered with this flag above.
#			#	MUST USE SORTED
#			samtools view -c -F 4 ${subject}.${hhv}.sorted.bam ${hhv}:20000-120000 > ${subject}.${hhv}.bowtie2.mapped_center.count.txt
#			chmod a-w ${subject}.${hhv}.bowtie2.mapped_center.count.txt
#		fi
#
#		if [ -f ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${hhv} bowtie2 alignments to total unaligned reads"
#			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped_center.count.txt)"/"$(cat ${subject}.unmapped.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt
#			chmod a-w ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt
#		fi
#
#		if [ -f ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${hhv} bowtie2 alignments to total reads"
#			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped_center.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt
#			chmod a-w ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt
#		fi

#		if [ -f ${subject}.${hhv}.kallisto10.count.txt ] && [ ! -w ${subject}.${hhv}.kallisto10.count.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.kallisto10.count.txt exists. Skipping step."
#		else
#			echo "Running kallisto10"
#			#	kallisto crashes when 0 alignments
#			set +e
#			#	estimated fragment length and standard deviation are guesses
#			kallisto quant --single -l 500 -s 50 -b 10 --threads 10 --index /raid/refs/kallisto/${hhv} --output-dir ${subject}.${hhv}.kallisto10 ${subject}.fasta.gz 2> ${subject}.${hhv}.kallisto10.log
#			set -e
#			awk -F"\t" '( NR == 2 ){ print $4 }' ${subject}.${hhv}.kallisto10/abundance.tsv > ${subject}.${hhv}.kallisto10.count.txt
#			chmod a-w ${subject}.${hhv}.kallisto10.count.txt
#		fi
#
#		if [ -f ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${hhv} kallisto10 alignments to total reads"
#			echo "scale=9; "$(cat ${subject}.${hhv}.kallisto10.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt
#			chmod a-w ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt
#		fi

	done















	for hhv in HHV6a HHV6b ; do

		echo "Processing $subject / $hhv"

		if [ -f ${subject}.${hhv}.unsorted.bam ] && [ ! -w ${subject}.${hhv}.unsorted.bam ]  ; then
			echo "Write-protected ${subject}.${hhv}.unsorted.bam exists. Skipping step."
		else
			#	echo "Bowtie2 aligning fastq reads to ${hhv}"
			#	bowtie2 --xeq -x ${hhv} --very-sensitive -U ${subject}.fastq.gz | samtools view -F 4 -o ${subject}.${hhv}.bam -
			echo "Bowtie2 aligning fasta reads to ${hhv}"

#	FASTA REQUIRES the -f FLAG!
			bowtie2 --threads 35 -f --xeq -x ${hhv} --very-sensitive -U ${subject}.fasta.gz 2>> ${subject}.${hhv}.log | samtools view -F 4 -o ${subject}.${hhv}.unsorted.bam -


			chmod a-w ${subject}.${hhv}.unsorted.bam
		fi


		if [ -f ${subject}.${hhv}.sorted.bam ] && [ ! -w ${subject}.${hhv}.sorted.bam ]  ; then
			echo "Write-protected ${subject}.${hhv}.sorted.bam exists. Skipping step."
		else
			echo "Sorting"
			samtools sort -o ${subject}.${hhv}.sorted.bam ${subject}.${hhv}.unsorted.bam
			chmod a-w ${subject}.${hhv}.sorted.bam
		fi


		if [ -f ${subject}.${hhv}.sorted.bam.bai ] && [ ! -w ${subject}.${hhv}.sorted.bam.bai ]  ; then
			echo "Write-protected ${subject}.${hhv}.sorted.bam.bai exists. Skipping step."
		else
			echo "Indexing"
			samtools index ${subject}.${hhv}.sorted.bam
			chmod a-w ${subject}.${hhv}.sorted.bam.bai
		fi



		if [ -f ${subject}.${hhv}.depth.csv ] && [ ! -w ${subject}.${hhv}.depth.csv ]  ; then
			echo "Write-protected ${subject}.${hhv}.depth.csv exists. Skipping step."
		else
			echo "Getting depth"
			samtools depth ${subject}.${hhv}.sorted.bam > ${subject}.${hhv}.depth.csv
			chmod a-w ${subject}.${hhv}.depth.csv
		fi






		if [ -f ${subject}.${hhv}.bowtie2.mapped.count.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped.count.txt ]  ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped.count.txt exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned to ${hhv}"
			#	-F 4 needless here as filtered with this flag above.
			samtools view -c -F 4 ${subject}.${hhv}.unsorted.bam > ${subject}.${hhv}.bowtie2.mapped.count.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped.count.txt
		fi

		if [ -f ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} bowtie2 alignments to total unaligned reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped.count.txt)"/"$(cat ${subject}.unmapped.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped.ratio_unmapped.txt
		fi

		if [ -f ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} bowtie2 alignments to total reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped.ratio_total.txt
		fi

#$ samtools view -H NA21144.HHV6b.sorted.bam 
#@HD	VN:1.0	SO:coordinate
#@SQ	SN:NC_000898.1	LN:162114
#$ samtools view -H NA21144.HHV6a.sorted.bam 
#@HD	VN:1.0	SO:coordinate
#@SQ	SN:NC_001664.4	LN:159378


		if [ -f ${subject}.${hhv}.bowtie2.mapped_center.count.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped_center.count.txt ]  ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped_center.count.txt exists. Skipping step."
		else

			#	either NC_000898.1 or NC_001664.4
			name=$( samtools view -H ${subject}.${hhv}.sorted.bam | grep "^@SQ" | awk '{print $2}' | awk -F: '{print $2}' )
			echo "Counting reads bowtie2 aligned to CENTER of ${hhv} in region ${name}:20000-120000"

			#	-F 4 needless here as filtered with this flag above.
			#	MUST USE SORTED
			samtools view -c -F 4 ${subject}.${hhv}.sorted.bam ${name}:20000-120000 > ${subject}.${hhv}.bowtie2.mapped_center.count.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped_center.count.txt
		fi

		if [ -f ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} bowtie2 alignments to total unaligned reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped_center.count.txt)"/"$(cat ${subject}.unmapped.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped_center.ratio_unmapped.txt
		fi

		if [ -f ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} bowtie2 alignments to total reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.bowtie2.mapped_center.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt
			chmod a-w ${subject}.${hhv}.bowtie2.mapped_center.ratio_total.txt
		fi















		if [ -f ${subject}.${hhv}.kallisto10.count.txt ] && [ ! -w ${subject}.${hhv}.kallisto10.count.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.kallisto10.count.txt exists. Skipping step."
		else
			echo "Running kallisto10"
			#	kallisto crashes when 0 alignments
			set +e
			#	estimated fragment length and standard deviation are guesses
			kallisto quant --single -l 500 -s 50 -b 10 --threads 10 --index /raid/refs/kallisto/${hhv} --output-dir ${subject}.${hhv}.kallisto10 ${subject}.fasta.gz 2> ${subject}.${hhv}.kallisto10.log
			set -e
			awk -F"\t" '( NR == 2 ){ print $4 }' ${subject}.${hhv}.kallisto10/abundance.tsv > ${subject}.${hhv}.kallisto10.count.txt
			chmod a-w ${subject}.${hhv}.kallisto10.count.txt
		fi

		if [ -f ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} kallisto10 alignments to total reads"
			echo "scale=9; "$(cat ${subject}.${hhv}.kallisto10.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt
			chmod a-w ${subject}.${hhv}.kallisto10.mapped.ratio_total.txt
		fi

#		if [ -f ${subject}.${hhv}.kallisto40.count.txt ] && [ ! -w ${subject}.${hhv}.kallisto40.count.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.kallisto40.count.txt exists. Skipping step."
#		else
#			echo "Running kallisto40"
#			#	kallisto crashes when 0 alignments
#			set +e
#			#	estimated fragment length and standard deviation are guesses
#			kallisto quant --single -l 500 -s 50 -b 40 --threads 40 --index /raid/refs/kallisto/${hhv} --output-dir ${subject}.${hhv}.kallisto40 ${subject}.fasta.gz 2> ${subject}.${hhv}.kallisto40.log
#			set -e
#			awk -F"\t" '( NR == 2 ){ print $4 }' ${subject}.${hhv}.kallisto40/abundance.tsv > ${subject}.${hhv}.kallisto40.count.txt
#			chmod a-w ${subject}.${hhv}.kallisto40.count.txt
#		fi








#		if [ -f ${subject}.${hhv}.blastn.txt.gz ] && [ ! -w ${subject}.${hhv}.blastn.txt.gz ]  ; then
#			echo "Write-protected ${subject}.${hhv}.blastn.txt.gz exists. Skipping step."
#		else
#			echo "blastn aligning fasta reads to ${hhv}"
#			blastn -query <( zcat ${subject}.fasta.gz ) -db ${hhv} -num_threads 40 -max_hsps 1 -outfmt 6 \
#				-task blastn -evalue 0.00005 2>> ${subject}.${hhv}.blastn.log | gzip --best > ${subject}.${hhv}.blastn.txt.gz
#			chmod a-w ${subject}.${hhv}.blastn.txt.gz
#		fi
#
#		if [ -f ${subject}.${hhv}.blastn.mapped.count.txt ] && [ ! -w ${subject}.${hhv}.blastn.mapped.count.txt ]  ; then
#			echo "Write-protected ${subject}.${hhv}.blastn.mapped.count.txt exists. Skipping step."
#		else
#			echo "Counting reads blastn aligned to ${hhv}"
#			zcat ${subject}.${hhv}.blastn.txt.gz | wc -l > ${subject}.${hhv}.blastn.mapped.count.txt
#			chmod a-w ${subject}.${hhv}.blastn.mapped.count.txt
#		fi
#
#		if [ -f ${subject}.${hhv}.blastn.mapped.ratio_unmapped.txt ] && [ ! -w ${subject}.${hhv}.blastn.mapped.ratio_unmapped.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.blastn.mapped.ratio_unmapped.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${hhv} blastn alignments to total unaligned reads"
#			echo "scale=9; "$(cat ${subject}.${hhv}.blastn.mapped.count.txt)"/"$(cat ${subject}.unmapped.count.txt) | bc > ${subject}.${hhv}.blastn.mapped.ratio_unmapped.txt
#			chmod a-w ${subject}.${hhv}.blastn.mapped.ratio_unmapped.txt
#		fi
#
#		if [ -f ${subject}.${hhv}.blastn.mapped.ratio_total.txt ] && [ ! -w ${subject}.${hhv}.blastn.mapped.ratio_total.txt ] ; then
#			echo "Write-protected ${subject}.${hhv}.blastn.mapped.ratio_total.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${hhv} blastn alignments to total reads"
#		echo "scale=9; "$(cat ${subject}.${hhv}.blastn.mapped.count.txt)"/"$(cat ${subject}.total.count.txt) | bc > ${subject}.${hhv}.blastn.mapped.ratio_total.txt
#			chmod a-w ${subject}.${hhv}.blastn.mapped.ratio_total.txt
#		fi

	done

done

echo "---"
echo "Done"
