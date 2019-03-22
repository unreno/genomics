#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

outfile="geuvadis.viral.masked.csv"


echo -e "source\tmolecule\tsample\tsubject\tread_count\tblast_err_count\tqaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" > ${outfile}

#for f in {HG,NA}*.viral.masked.txt.gz ; do
for f in *.viral.masked.txt.gz ; do
	base=$(basename $f .viral.masked.txt.gz )
	subject=${base%%.*}
	fastq_count=$( cat ${base}.fastq_count )
	blast_err_count=$( cat ${base}.viral.masked.err | wc -l )
	zcat $f | sed "s/^/geuvadis\tRNA\t${base}\t${subject}\t${fastq_count}\t${blast_err_count}\t/"
done >> ${outfile}

#gzip ${outfile}

