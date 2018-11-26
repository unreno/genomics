#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


for f1 in /raid/data/raw/gEUVADIS/*_1.fastq.gz ; do
	#	 NA20759.4.M_120208_3_2.fastq.gz
	f2=${f1/_1.fastq/_2.fastq}
	basename=${f1##*/}
#	basename=${basename%.*_1.fastq.gz}	#	just 1 %, not 2		# SADLY, this is NOT unique for 4 samples
	basename=${basename%_1.fastq.gz}
	echo $f1 $f2
	echo $basename

	#	Apparently NEED to use my combined index Homo_sapiens.GRCh38.rna which matches
	#	the ensembl stuff from sleuth and the following works ...
	#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
	#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz
	#	cat Homo_sapiens.GRCh38.cdna.all.fa.gz Homo_sapiens.GRCh38.ncrna.fa.gz > Homo_sapiens.GRCh38.rna.fa.gz
	#	kallisto index --index Homo_sapiens.GRCh38.rna.idx Homo_sapiens.GRCh38.rna.fa.gz

	#	Also, sleuth seems to need some bootstraps. Not sure how many. 100 takes a while. Use less next time?



	if [ -f ${basename}.total.count.txt ] && [ ! -w ${basename}.total.count.txt ]  ; then
		echo "Write-protected ${basename}.total.count.txt exists. Skipping step."
	else
		echo "Counting reads in fastqs"
		#samtools view -c $bam > ${basename}.unmapped.count.txt
		#cat $bam.bai | bamReadDepther | grep "^*\|^#" | awk -F"\t" '{s+=$NF}END{print s}' > ${basename}.unmapped.count.txt
		#	rather that cat both and divide by 4, cat 1 and divide by 2
		echo $( zcat $f1 | wc -l )"/2" | bc > ${basename}.total.count.txt

		chmod a-w ${basename}.total.count.txt
	fi



	for hhv in HHV6a HHV6b ; do

		echo "Processing ${hhv}"

		if [ -f ${basename}.${hhv}.bam ] && [ ! -w ${basename}.${hhv}.bam ] ; then
			echo "Write protected ${hhv} alignment already. Skipping."
		else
			echo "Aligning ${basename} to ${hhv}"
			bowtie2 --threads 40 --xeq -x ${hhv} --very-sensitive -1 ${f1} -2 ${f2} 2>> ${basename}.${hhv}.log | samtools view -F 4 -o ${basename}.${hhv}.bam -
			chmod a-w ${basename}.${hhv}.bam
		fi

		if [ -f ${basename}.${hhv}.bowtie2.mapped.count.txt ] && [ ! -w ${basename}.${hhv}.bowtie2.mapped.count.txt ]  ; then
			echo "Write-protected ${basename}.${hhv}.bowtie2.mapped.count.txt exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned to ${hhv}"
			#	-F 4 needless here as filtered with this flag above.
			samtools view -c -F 4 ${basename}.${hhv}.bam > ${basename}.${hhv}.bowtie2.mapped.count.txt
			chmod a-w ${basename}.${hhv}.bowtie2.mapped.count.txt
		fi


		if [ -f ${basename}.${hhv}.bowtie2.mapped.ratio_total.txt ] && [ ! -w ${basename}.${hhv}.bowtie2.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${basename}.${hhv}.bowtie2.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} bowtie2 alignments to total reads"
			echo "scale=9; "$(cat ${basename}.${hhv}.bowtie2.mapped.count.txt)"/"$(cat ${basename}.total.count.txt) | bc > ${basename}.${hhv}.bowtie2.mapped.ratio_total.txt
			chmod a-w ${basename}.${hhv}.bowtie2.mapped.ratio_total.txt
		fi

		if [ -f ${basename}.${hhv}.kallisto10.count.txt ] && [ ! -w ${basename}.${hhv}.kallisto10.count.txt ] ; then
			echo "Write-protected ${basename}.${hhv}.kallisto10.count.txt exists. Skipping step."
		else
			echo "Running kallisto10"
			# kallisto crashes when 0 alignments
			set +e
			kallisto quant -b 10 --threads 10 --index /raid/refs/kallisto/${hhv} --output-dir ${basename}.${hhv}.kallisto10 ${f1} ${f2} 2> ${basename}.${hhv}.kallisto10.log
			set -e
			awk -F"\t" '( NR == 2 ){ print $4 }' ${basename}.${hhv}.kallisto10/abundance.tsv > ${basename}.${hhv}.kallisto10.count.txt
			chmod a-w ${basename}.${hhv}.kallisto10.count.txt
		fi

		if [ -f ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt ] && [ ! -w ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} kallisto10 alignments to total reads"
			echo "scale=9; "$(cat ${basename}.${hhv}.kallisto10.count.txt)"/"$(cat ${basename}.total.count.txt) | bc > ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt
			chmod a-w ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt
		fi


#		if [ -f ${basename}.${hhv}.kallisto40.count.txt ] && [ ! -w ${basename}.${hhv}.kallisto40.count.txt ] ; then
#			echo "Write-protected ${basename}.${hhv}.kallisto40.count.txt exists. Skipping step."
#		else
#			echo "Running kallisto40"
#			# kallisto crashes when 0 alignments
#			set +e
#			kallisto quant -b 40 --threads 40 --index /raid/refs/kallisto/${hhv} --output-dir ${basename}.${hhv}.kallisto40 ${f1} ${f2} 2> ${basename}.${hhv}.kallisto40.log
#			set -e
#			awk -F"\t" '( NR == 2 ){ print $4 }' ${basename}.${hhv}.kallisto40/abundance.tsv > ${basename}.${hhv}.kallisto40.count.txt
#			chmod a-w ${basename}.${hhv}.kallisto40.count.txt
#		fi






	done

done

echo "Done"
