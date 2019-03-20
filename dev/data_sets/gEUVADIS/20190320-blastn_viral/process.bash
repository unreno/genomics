#!/usr/bin/env bash

#ls *fasta | parallel --no-notice --joblog ~/parallel.1.log -j40 blastn -query {} -num_threads 1 -outfmt 6 -db viral.masked -out {}.viral.masked.1.txt 2\> {}.viral.masked.1.err &

#ls /raid/data/raw/gEUVADIS/*fastq.gz | parallel --no-notice --joblog ./parallel.joblog -j40 ./process.bash &


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


if [ $# -ne 1 ] ; then
	echo "No file given"
fi

base=$( basename $1 .fastq.gz )

fastq_count=${base}.fastq_count
if [ -f ${fastq_count} ] && [ ! -w ${fastq_count} ]  ; then
	echo "${fastq_count} already exists, so skipping."
else
	echo "Creating ${fastq_count}"
	fastq_line_count=$( wc -l <( zcat $1 ) )
	echo "${fastq_line_count}/4" | bc > ${fastq_count}
	chmod a-w ${fastq_count}
fi

fasta=${base}.fasta
if [ -f ${fasta} ] && [ ! -w ${fasta} ]  ; then
	echo "${fasta} already exists, so skipping."
else
	echo "Creating ${fasta}"
	fastqToFa <( zcat $1 ) ${fasta}
	chmod a-w ${fasta}
fi

fasta_count=${base}.fasta_count
if [ -f ${fasta_count} ] && [ ! -w ${fasta_count} ]  ; then
	echo "${fasta_count} already exists, so skipping."
else
	echo "Creating ${fasta_count}"
	grep -c "^>" ${fasta} > ${fasta_count}
	chmod a-w ${fasta_count}
fi

blast_out="${base}.viral.masked.txt"
blast_err="${base}.viral.masked.err"
if [ -f ${blast_out} ] && [ ! -w ${blast_out} ]  ; then
	echo "${blast_out} already exists, so skipping."
else
	echo "Blasting ${fasta} creating ${blast_out}"
	blastn -query ${fasta} -num_threads 1 -outfmt 6 -db viral.masked -out ${blast_out} 2> ${blast_err}
	chmod a-w ${blast_out}
fi

