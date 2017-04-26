#!/usr/bin/env bash

script=`basename $0`


#	E-GEUV-1 - RNA-sequencing of 465 lymphoblastoid cell lines from the 1000 Genomes
#	http://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/processed/
#	actually only 462

#	geuvadis.txt contains list

#	wget?

: ${BOWTIE2_INDEXES:="$HOME/BOWTIE2_INDEXES"}
export BOWTIE2_INDEXES


#	Print a lot more stuff
set -x

{
	echo "Starting at ..."
	date

#	for bam in HG00096.1.M_111124_6.bam HG00101.1.M_111124_4.bam HG00104.1.M_111124_5.bam HG00117.1.M_111124_2.bam HG00121.1.M_111124_7.bam HG00125.1.M_111124_6.bam HG00126.1.M_111124_8.bam HG00127.1.M_111124_2.bam HG00128.1.M_111124_6.bam ; do
	for bam in $(head ../geuvadis.txt) ; do
		echo $bam
		bam_base=${bam%.*}
		echo $bam_base
	
		if [ ! -f raw/$bam ] ; then
			echo "WGetting bam"
			\rm $bam
			wget http://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/processed/$bam
			mv $bam raw/
		else
			echo "Already have this bam"
		fi
	
		echo "Total read count"
		samtools view raw/$bam | wc -l
	
		samtools view -h -f12 raw/$bam | samtools sort -n -o $bam_base.human_unaligned.sorted.bam -
	
		echo "Unmapped read count"
		samtools view $bam_base.human_unaligned.sorted.bam | wc -l
	
		bamToFastq -i $bam_base.human_unaligned.sorted.bam \
			-fq  $bam_base.human_unaligned.1.fastq \
			-fq2 $bam_base.human_unaligned.2.fastq
	
		bowtie2 -x geuvadis \
			-1 $bam_base.human_unaligned.1.fastq \
			-2 $bam_base.human_unaligned.2.fastq \
			-S $bam_base.human_unaligned.viral_aligned.sam
	
		samtools view -b $bam_base.human_unaligned.viral_aligned.sam > $bam_base.human_unaligned.viral_aligned.bam
		\rm $bam_base.human_unaligned.viral_aligned.sam
	
		echo "Aligned read counts"
		samtools view $bam_base.human_unaligned.viral_aligned.bam | awk -F"\t" '{print $3}' | sort | uniq -c
	
	done

	echo "Finishing at ..."
	date

} 1>>$script.out 2>&1 

