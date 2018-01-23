#!/usr/bin/env bash

script=$(basename $0)

#	currently requires samtools, bedtools, bowtie2
#	sudo apt install samtools bedtools bowtie2

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

#	for bam in $(head -n 50 ../geuvadis.txt) ; do
	for bam in $(cat geuvadis.txt) ; do
		echo "$bam"
		bam_base=${bam%.*}
		echo "$bam_base"

		if [ ! -f "raw/$bam" ] ; then
			echo "WGetting bam."
			if [ -f "$bam" ] ; then
				echo "Removing existing download."
				chmod +w "$bam"
				rm "$bam"
			fi
			wget "http://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/processed/$bam"
			mkdir -p raw
			mv "$bam" raw/
#			chmod -w "raw/$bam"
		else
			echo "Already have this bam."
		fi

		if [ ! -f "raw/$bam.bai" ] ; then
			#	NEEDED for region selection
			echo "Indexing raw file."
			samtools index "raw/$bam"
		fi


#
#	https://www.ncbi.nlm.nih.gov/gene?term=NM_001243432
#	
#		Assembly	Chr	Location
#		GRCh38.p7 (GCF_000001405.33)	21	NC_000021.9 (38367261..38662045, complement)
#		GRCh37.p13 (GCF_000001405.25)	21	NC_000021.8 (39739183..40033704, complement)
#		
#
#	How did we devise that they are aligned to GRCh38(hg38) and not GRCh37(hg19)???
#	This was incorrect.
#	https://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/E-GEUV-1.idf.txt
#	... "The reads were mapped to the human hg19 reference genome" ...
#
#
#


		if [ ! -f "$bam_base.ERG.bam" ] ; then
			echo "Extracting ERG region."
#	hg38 gene
#			samtools view -h -b -o "$bam_base.ERG.bam" "raw/$bam" "chr21:38367261-38662045"
#	hg38 gene with 1000 base pair extension
#			samtools view -h -b -o "$bam_base.ERG.bam" "raw/$bam" "chr21:38366261-38663045"

#	hg19 gene with 1000 base pair extension
			samtools view -h -b -o "$bam_base.ERG.bam" "raw/$bam" "chr21:39738183-40034704"

#			chmod -w "$bam_base.ERG.bam"
		fi

		if [ ! -f "$bam_base.ERG.bam.bai" ] ; then
			echo "Indexing ERG extraction."
			samtools index "$bam_base.ERG.bam"
#			chmod -w "$bam_base.ERG.bam.bai"
		fi

		echo "Extracting total read count."
		total_read_count=$(samtools view "raw/$bam" | wc -l)
		echo "$total_read_count"
		echo "$total_read_count" > "$bam_base.total_raw_read_count"

		if [ ! -f "$bam_base.human_unaligned.sorted.bam" ] ; then
			echo "Selecting unaligned (-f12) (not mapped & mate not mapped)."
			samtools view -h -f12 "raw/$bam" | samtools sort -n -o "$bam_base.human_unaligned.sorted.bam" -
#			chmod -w "$bam_base.human_unaligned.sorted.bam"
		fi

		echo "Extracting unmapped read count."
		unmapped_read_count=$(samtools view "$bam_base.human_unaligned.sorted.bam" | wc -l)
		echo "$unmapped_read_count"
		echo "$unmapped_read_count" > "$bam_base.unmapped_raw_read_count"

		if [ ! -f "$bam_base.human_unaligned.viral_aligned.bam" ] ; then

			if [ ! -f "$bam_base.human_unaligned.1.fastq" ] ; then
				echo "Creating fastq files."
				bamToFastq -i "$bam_base.human_unaligned.sorted.bam" \
					-fq  "$bam_base.human_unaligned.1.fastq" \
					-fq2 "$bam_base.human_unaligned.2.fastq"
				chmod +w "$bam_base.human_unaligned.sorted.bam"
				rm "$bam_base.human_unaligned.sorted.bam"
			fi

			if [ ! -f "$bam_base.human_unaligned.viral_aligned.sam" ] ; then
				echo "Aligning to geuvadis viral list."
				bowtie2 -x geuvadis \
					-1 "$bam_base.human_unaligned.1.fastq" \
					-2 "$bam_base.human_unaligned.2.fastq" \
					-S "$bam_base.human_unaligned.viral_aligned.sam"
			fi

			echo "Converting sam to bam."
			samtools view -b -o "$bam_base.human_unaligned.viral_aligned.bam" \
				"$bam_base.human_unaligned.viral_aligned.sam"

#			chmod -w "$bam_base.human_unaligned.viral_aligned.bam"

			if [ -f "$bam_base.human_unaligned.viral_aligned.bam" ] ; then
				echo "Removing fastqs."
				chmod +w "$bam_base.human_unaligned.1.fastq"
				rm "$bam_base.human_unaligned.1.fastq"
				chmod +w "$bam_base.human_unaligned.2.fastq"
				rm "$bam_base.human_unaligned.2.fastq"

				echo "Removing sam."
				chmod +w "$bam_base.human_unaligned.viral_aligned.sam"
				rm "$bam_base.human_unaligned.viral_aligned.sam"
			fi

		fi

		echo "Extracting aligned read counts."
		aligned_output=$(samtools view -F4 "$bam_base.human_unaligned.viral_aligned.bam" | awk 'BEGIN{FS="\t"}{print $3}' | sort | uniq -c )
		#	output likely contains an * which bash will likely glob totally mucking this up. QUOTE IT!
		#	* removed by adding the -F4
		echo "$aligned_output"
		echo "$aligned_output" > "$bam_base.viral_aligned_counts"

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



		chmod +w "raw/$bam.bai"
		rm "raw/$bam.bai"
		chmod +w "raw/$bam"
		rm "raw/$bam"

	done

	echo "Finishing at ..."
	date

} 1>>$script.out 2>&1 

