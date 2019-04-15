#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

wd=$PWD


#	Only 

for ref in hg38_no_alts NA12878 ; do

	f=hervk10-113-119.${ref}.vs.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bowtie2 --no-unal --threads 40 -f -x ${ref} --very-sensitive --all \
			-U hervk10-113-119.fasta \
			| samtools view -o $f - &
#		chmod a-w $f
	fi

	f=svas.${ref}.vs.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bowtie2 --no-unal --threads 40 -f -x ${ref} --very-sensitive --all \
			-U svas.fasta \
			| samtools view -o $f - &
#		chmod a-w $f
	fi


	#	Primers are 20bp each. Expected insert it about 40bp. Set to 100?
	#  -X/--maxins <int>  maximum fragment length (500)

	#	Really only want proper pairs of primers
	#	SVA 10-11RC overlaps by 1 so need to allow for dovetail

	f=sva_primers.${ref}.vs.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bowtie2 --no-unal --threads 40 -f -x ${ref} --very-sensitive --all \
			--dovetail \
			--no-discordant \
			-X 100 -1 sva_primers.1.fa -2 sva_primers.2.fa \
			| samtools view -o $f - &
#		chmod a-w $f
	fi

	f=hervk_primers.${ref}.vs.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bowtie2 --no-unal --threads 40 -f -x ${ref} --very-sensitive --all \
			--no-discordant \
			-X 100 -1 hervk_primers.1.fa -2 hervk_primers.2.fa \
		| samtools view -o $f - &
#		chmod a-w $f
	fi

done


#	
#	samtools view -f 2 -o sva_primers.hg38_no_alts.vs.PP.bam sva_primers.hg38_no_alts.vs.bam &
#	
#	samtools view -f 2 -o hervk_primers.hg38_no_alts.vs.PP.bam hervk_primers.hg38_no_alts.vs.bam &
#	
#	They are the same!!!! Yay!
#	
#	
#	---
#	
#	
#	
#	bam_to_positions_csvs.bash --paired sva_primers.hg38_no_alts.vs.bam
#	
#	bam_to_positions_csvs.bash --paired hervk_primers.hg38_no_alts.vs.bam
#	
#	bam_to_positions_csvs.bash svas.hg38_no_alts.vs.bam
#	
#	bam_to_positions_csvs.bash hervk10-113-119.hg38_no_alts.vs.bam
#	
#	
#	
#	awk -f nearest.awk hervk_primers.hg38_no_alts.vs.forward.positions.csv hervk10-113-119.hg38_no_alts.vs.forward.positions.csv > hervk10-113-119.nearest_primer.hg38_no_alts.vs.forward.positions.csv
#	awk -f nearest.awk hervk_primers.hg38_no_alts.vs.reverse.positions.csv hervk10-113-119.hg38_no_alts.vs.reverse.positions.csv > hervk10-113-119.nearest_primer.hg38_no_alts.vs.reverse.positions.csv
#	
#	awk -f nearest.awk hervk10-113-119.hg38_no_alts.vs.forward.positions.csv hervk_primers.hg38_no_alts.vs.forward.positions.csv > hervk_primer.nearest_herv.hg38_no_alts.vs.forward.positions.csv
#	awk -f nearest.awk hervk10-113-119.hg38_no_alts.vs.reverse.positions.csv hervk_primers.hg38_no_alts.vs.reverse.positions.csv > hervk_primer.nearest_herv.hg38_no_alts.vs.reverse.positions.csv
#	
#	awk -f nearest.awk sva_primers.hg38_no_alts.vs.forward.positions.csv svas.hg38_no_alts.vs.forward.positions.csv > svas.nearest_primers.hg38_no_alts.vs.forward.positions.csv
#	awk -f nearest.awk sva_primers.hg38_no_alts.vs.reverse.positions.csv svas.hg38_no_alts.vs.reverse.positions.csv > svas.nearest_primers.hg38_no_alts.vs.reverse.positions.csv
#	
#	awk -f nearest.awk svas.hg38_no_alts.vs.forward.positions.csv sva_primers.hg38_no_alts.vs.forward.positions.csv > sva_primers.nearest_sva.hg38_no_alts.vs.forward.positions.csv
#	awk -f nearest.awk svas.hg38_no_alts.vs.reverse.positions.csv sva_primers.hg38_no_alts.vs.reverse.positions.csv > sva_primers.nearest_sva.hg38_no_alts.vs.reverse.positions.csv
#	
#	
#	
#	
#	
#	awk -f nearest_summary.awk hervk10-113-119.hg38_no_alts.vs.forward.positions.csv hervk_primers.hg38_no_alts.vs.forward.positions.csv > hervk_primer.nearest_herv.hg38_no_alts.vs.forward.summary.csv
#	awk -f nearest_summary.awk hervk10-113-119.hg38_no_alts.vs.reverse.positions.csv hervk_primers.hg38_no_alts.vs.reverse.positions.csv > hervk_primer.nearest_herv.hg38_no_alts.vs.reverse.summary.csv
#	
#	awk -f nearest_summary.awk svas.hg38_no_alts.vs.forward.positions.csv sva_primers.hg38_no_alts.vs.forward.positions.csv > sva_primers.nearest_sva.hg38_no_alts.vs.forward.summary.csv
#	awk -f nearest_summary.awk svas.hg38_no_alts.vs.reverse.positions.csv sva_primers.hg38_no_alts.vs.reverse.positions.csv > sva_primers.nearest_sva.hg38_no_alts.vs.reverse.summary.csv



