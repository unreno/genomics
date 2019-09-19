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

	f=${base}.fa
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		zcat $r1 $r2 | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' -e 's/ (.)/\/\1 /'  -e 's/ .*$//' > ${f}
		chmod a-w $f
	fi

	f=${base}.pieces
	if [ -d $f ] ; then	#	&& [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		mkdir $f
		split -d --suffix-length=6 --additional-suffix=.fa --lines=100 ${base}.fa ${f}/
		#chmod a-w $f
	fi

	#	mature hg38 nt
	for ref in viral.masked hairpin hg38 ; do

		# @M04104:246:000000000-D6RBR:1:1101:13542:1883 2:N:0:CTGAAGCT+GTACTGAC

#		f=${base}.${ref}.blastn.tsv.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#			zcat $r1 $r2 | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' -e 's/ (.)/\/\1 /'  -e 's/ .*$//' | blastn -num_threads 40 -outfmt 6 -db ${ref} | gzip --best > ${f}
#			chmod a-w $f
#		fi


		f=${base}.${ref}.blastn.tsv.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			ls ${base}.pieces/*fa | parallel --no-notice --joblog ${base}.${ref}.parallel.blastn.log -j40 blastn -query {} -outfmt 6 -db ${ref} -out {}.${ref}.blastn.out 2\> {}.${ref}.blastn.err
			cat ${base}.pieces/*fa.${ref}.blastn.out | gzip --best > ${f}
			chmod a-w $f
		fi

		f=${base}.${ref}.blastn.tsv.gz.counts
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			zcat ${base}.${ref}.blastn.tsv.gz | awk '{print $1,$2}' | sort | uniq | awk '{print $2}' | sort | uniq -c > ${f}
			chmod a-w $f
		fi

	done

done 


for ref in viral.masked hairpin nt ; do
	echo "Summarizing ${ref}"

	f=summary.${ref}.blastn.tsv.gz.counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		awk '{print $2}' *.${ref}.blastn.tsv.gz.counts | sort | uniq -c | sort -r -n > ${f}
		chmod a-w $f
	fi

done



