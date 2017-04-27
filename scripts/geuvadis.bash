#!/usr/bin/env bash

script=`basename $0`


#	E-GEUV-1 - RNA-sequencing of 465 lymphoblastoid cell lines from the 1000 Genomes
#	http://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/processed/
#	actually only 462



: ${BOWTIE2_INDEXES:="$HOME/BOWTIE2_INDEXES"}
export BOWTIE2_INDEXES


#	Print a lot more stuff
#set -x

{
	echo "Starting at ..."
	date

	echo -ne "bam\ttotal_read_count\tunmapped_read_count\t" > geuvadis_counts.tsv
	for virus in $(grep "^>" ~/BOWTIE2_INDEXES/geuvadis.fa | awk '{print $1}' | cut -c 2-) ; do
		echo -ne "$virus\t" >> geuvadis_counts.tsv
	done
	echo >> geuvadis_counts.tsv

#	for bam in HG00096.1.M_111124_6.bam HG00101.1.M_111124_4.bam HG00104.1.M_111124_5.bam HG00117.1.M_111124_2.bam HG00121.1.M_111124_7.bam HG00125.1.M_111124_6.bam HG00126.1.M_111124_8.bam HG00127.1.M_111124_2.bam HG00128.1.M_111124_6.bam ; do
	for bam in $(head ../geuvadis.txt) ; do
		echo "$bam"
		bam_base=${bam%.*}
		echo "$bam_base"

		if [ ! -f "raw/$bam" ] ; then
			echo "WGetting bam"
			if [ -f "$bam" ] ; then
				echo "Removing existing download."
				rm "$bam"
			fi
			wget "http://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/processed/$bam"
			mv "$bam" raw/
		else
			echo "Already have this bam"
		fi

		echo "Total read count"
		total_read_count=`samtools view "raw/$bam" | wc -l`
		echo "$total_read_count"

		if [ ! -f "$bam_base.human_unaligned.sorted.bam" ] ; then
			samtools view -h -f12 "raw/$bam" | samtools sort -n -o "$bam_base.human_unaligned.sorted.bam" -
		fi

		echo "Unmapped read count"
		unmapped_read_count=`samtools view "$bam_base.human_unaligned.sorted.bam" | wc -l`
		echo "$unmapped_read_count"

		if [ ! -f "$bam_base.human_unaligned.1.fastq" ] ; then
			bamToFastq -i "$bam_base.human_unaligned.sorted.bam" \
				-fq  "$bam_base.human_unaligned.1.fastq" \
				-fq2 "$bam_base.human_unaligned.2.fastq"
		fi

		if [ ! -f "$bam_base.human_unaligned.viral_aligned.bam" ] ; then
			bowtie2 -x geuvadis \
				-1 "$bam_base.human_unaligned.1.fastq" \
				-2 "$bam_base.human_unaligned.2.fastq" \
				-S "$bam_base.human_unaligned.viral_aligned.sam"
#		fi
#
#		if [ ! -f "$bam_base.human_unaligned.viral_aligned.bam" ] ; then
			samtools view -b "$bam_base.human_unaligned.viral_aligned.sam" > "$bam_base.human_unaligned.viral_aligned.bam"
			rm "$bam_base.human_unaligned.viral_aligned.sam"
		fi

		echo "Aligned read counts"
		aligned_output=$(samtools view -F4 "$bam_base.human_unaligned.viral_aligned.bam" | awk 'BEGIN{FS="\t"}{print $3}' | sort | uniq -c )
		#	output likely contains an * which bash will likely glob totally mucking this up. QUOTE IT!
		echo "$aligned_output"


		echo -ne "$bam\t$total_read_count\t$unmapped_read_count\t" >> geuvadis_counts.tsv
		for virus in $(grep "^>" ~/BOWTIE2_INDEXES/geuvadis.fa | awk '{print $1}' | cut -c 2-) ; do
			echo "$virus"
			virus_count=$(echo "$aligned_output" | grep "$virus" | awk '{print $1}')
			if [ -z "$virus_count" ] ; then
				virus_count=0
			fi
			echo "$virus_count"
			echo -ne "$virus_count\t" >> geuvadis_counts.tsv
		done

		echo >> geuvadis_counts.tsv

	done

	echo "Finishing at ..."
	date

} 1>>$script.out 2>&1 

