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

	#	if the input are fastq, then --un, --al, etc are also. blastn only uses fastA
	#	very fast, fast, sensitive, or very sensitive. Tried very fast, but probably should've gone the other way.
	bowtie2 --threads ${threads} --very-fast -x hg38 \
		-U $(ls ${base}*fastq.gz | paste -sd ',' ) \
		| samtools fasta -f 4 --threads $[threads-1] -N -	\
		| gzip --best > ${base}.nonhg38.fasta.gz
	chmod -w ${base}.nonhg38.fasta.gz

#		-S ${base}.sam
	#chmod -w ${base}.sam
#	rm ${base}.sam



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
	#	--outfmt 0 is the same as blastn's default output format

	diamond blastx \
		--outfmt 0 \
		--threads ${threads} \
		--db ~/DIAMOND/viral \
		--query <( zcat ${base}.nonhg38.fasta.gz ) \
		2> /dev/null | gzip --best > ${base}.nonhg38.diamond.txt.gz

	chmod -w ${base}.nonhg38.diamond.txt.gz
	


	date
} > ${base}.log 2>&1
chmod -w ${base}.log

mkdir -p ../20180228.dark/
mv ${base}.nonhg38.* ${base}.log ../20180228.dark/

