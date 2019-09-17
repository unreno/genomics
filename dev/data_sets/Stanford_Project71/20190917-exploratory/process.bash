#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



for r1 in /raid/data/raw/Stanford_Project71/71-*_S*_L001_R1_001.fastq.gz ; do
	#	71-9_S9_L001_R1_001.fastq.gz
	r2=${r1/_R1/_R2}

	base=$(basename $r1 _L001_R1_001.fastq.gz) 
	base=${base/71-/}
	base=${base/_S*/}

	echo $r1 $r2
	echo $base

	#	ftp://mirbase.org/pub/mirbase/CURRENT/hairpin.fa.gz
	#	ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz

	for ref in hg38 viral.masked mature hairpin ; do

		f=${base}.${ref}.e2e.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			bowtie2 --xeq --threads 40 --very-sensitive -x ${ref} -1 ${r1} -2 ${r2} \
				2> ${f}.bowtie2.err \
				| samtools view -o ${f} - > ${f}.samtools.log 2> ${f}.samtools.err
			chmod a-w $f
		fi

	
		f=${base}.${ref}.loc.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -1 ${r1} -2 ${r2} \
				2> ${f}.bowtie2.err \
				| samtools view -o ${f} - > ${f}.samtools.log 2> ${f}.samtools.err
			chmod a-w $f
		fi

	done

	for ref in hg38 viral.masked mature hairpin nt ; do

		f=${base}.${ref}.blastn.tsv.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			zcat $r1 $r2 | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' -e 's/ .+\/(.)$/\/\1/' -e 's/ .*$//' | blastn -num_threads 40 -outfmt 6 -db ${ref} | gzip --best > ${f}
			chmod a-w $f
		fi

	done

done 

