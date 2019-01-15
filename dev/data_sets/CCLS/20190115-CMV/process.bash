#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


wd=$PWD


for fasta in /raid/data/raw/CCLS/bam/1*fasta.gz ; do
	core=$( basename $fasta .fasta.gz )
	echo $fasta $core

	cd $wd
	mkdir -p $core
	cd $core

#/raid/refs/fasta/virii/EF999921.1.fasta:>EF999921.1 Human herpesvirus 5 strain TB40/E clone TB40-BAC4, complete sequence
#/raid/refs/fasta/virii/FJ527563.1.fasta:>FJ527563.1 Human herpesvirus 5 strain AD169, complete genome
#/raid/refs/fasta/virii/GQ221974.1.fasta:>GQ221974.1 Human herpesvirus 5 strain 3157, complete genome
#/raid/refs/fasta/virii/GQ396662.1.fasta:>GQ396662.1 Human herpesvirus 5 strain HAN38, complete genome
#/raid/refs/fasta/virii/GU937742.2.fasta:>GU937742.2 Human herpesvirus 5 strain Toledo, complete genome
#/raid/refs/fasta/virii/KF021605.1.fasta:>KF021605.1 Human herpesvirus 5 strain TR, complete genome
#/raid/refs/fasta/virii/KF297339.1.fasta:>KF297339.1 Human herpesvirus 5 strain TB40/E clone Lisa, complete genome
#/raid/refs/fasta/virii/NC_006273.2.fasta:>NC_006273.2 Human herpesvirus 5 strain Merlin, complete genome

#	ll /raid/refs/fasta/virii/{EF999921.1,FJ527563.1,GQ221974.1,GQ396662.1,GU937742.2,KF021605.1,KF297339.1,NC_006273.2,X17403.1}.fasta
	for v in EF999921.1 FJ527563.1 GQ221974.1 GQ396662.1 GU937742.2 KF021605.1 KF297339.1 NC_006273.2 X17403.1 ; do

		echo "Processing ${v}"
	
		bam=${core}.${v}.bam
		f=$bam
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			echo "Aligning"
			bowtie2 --no-unal --very-sensitive --threads 39 -x virii/${v} -f -U $fasta 2> ${f}.bowtie2.log | samtools view -o ${bam} -
			chmod a-w ${f}
			chmod a-w ${f}.bowtie2.log
		fi
	
		#f=${core}.${v}.all_count.txt
		#if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		#	echo "Write-protected ${f} exists. Skipping step."
		#else
		#	echo "Counting all"
		#	samtools view --threads 39 -c ${bam} > ${f} 2> ${f}.error
		#	chmod a-w ${f}
		#fi
	
		f=${core}.${v}.aligned_count.txt
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			echo "Counting aligned"
			samtools view --threads 39 -c -F 4 ${bam} > ${f} 2> ${f}.error
			chmod a-w ${f}
			chmod a-w ${f}.error
		fi
	
		f=${core}.${v}.depth.csv
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			echo "Extracting depth"
			samtools depth -d 0 ${bam} > ${f} 2> ${f}.error
			chmod a-w ${f}
			chmod a-w ${f}.error
		fi

	done

done


