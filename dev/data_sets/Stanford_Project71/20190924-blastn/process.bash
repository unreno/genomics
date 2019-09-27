#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



for base in $( seq -w 1 77 ) ; do

	echo $base

	fq="/raid/data/raw/Stanford_Project71/fastq-bbmap-2/${base}.fastq"

	f=${base}.fa
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		cat $fq | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' -e 's/ (.)/\/\1 /'  -e 's/ .*$//' > ${f}
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
	for ref in viral.masked hairpin hg38 nt ; do

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


for ref in viral.masked hairpin hg38 nt ; do
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



