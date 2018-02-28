#!/usr/bin/env bash

#	Be verbose
set -x

#	exit on any error
set -e








threads=8


date


[ $# -eq 1 ] || exit

base=$1

{
	date

	bowtie2 --threads ${threads} --very-fast -x hg38 \
		-U $(ls ${base}*fastq.gz | paste -sd ',' ) \
		--un-gz ${base}.nonhg38.fasta.gz \
		-S /dev/null
	chmod -w ${base}.nonhg38.fasta.gz





#	export BLASTDB=/Users/jakewendt/BLAST_DBS

	#	makeblastdb -dbtype nucl -in viral.fasta -out viral -title viral -parse_seqids


	blastn -query <( zcat ${base}.nonhg38.fasta.gz ) \
		-db /Users/jakewendt/BLAST_DBS/viral \
		-num_threads ${threads} \
		2> /dev/null | gzip --best > ${base}.nonhg38.blastn.txt.gz

	chmod -w ${base}.nonhg38.blastn.txt.gz




	#	ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/

	#	MAKE SURE THAT THE SOURCE FASTA IS A PROTEIN FASTA AND NOT NUCEOTIDES
	#	I used EMBOSS's transeq
	#	transeq viral.fasta viral.protein.fasta
	#	diamond makedb --in viral.protein.fasta --db viral

	#	https://github.com/bbuchfink/diamond/blob/master/diamond_manual.pdf

	diamond blastx \
		--threads ${threads} \
		--db ~/DIAMOND/viral \
		--query <( zcat ${base}.nonhg38.fasta.gz ) \
		2> /dev/null | gzip --best > ${base}.nonhg38.diamond.txt.gz

	chmod -w ${base}.nonhg38.diamond.txt.gz

	date
} > ${base}.log 2>&1
