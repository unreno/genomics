#!/usr/bin/env bash

script=$( basename $0 )

human="hg38"
blastn_viral="/Users/jakewendt/BLAST_DBS/viral"
diamond_viral="/Users/jakewendt/DIAMOND/viral"
threads=8

function usage(){
	echo
	echo "Usage: ${script}"
	echo
	echo
	echo "Defaults:"
	echo "	threads .......... ${threads}"
	echo "	human ............ ${human}"
	echo "	blastn_viral ..... ${blastn_viral}"
	echo "	diamond_viral .... ${diamond_viral}"
	echo
	echo
	exit 1
}



while [ $# -ne 0 ] ; do
	case $1 in
#		-n|--estimated-num-cells)
#			shift; num_cells=$1; shift;;
#		-g|--genomedir)
#			shift; genomedir=$1; shift;;
#		-r|--referencefasta)
#			shift; referencefasta=$1; shift;;
#		-m|--m*)
#			shift; max=$1; shift;;
#		-v|--v*)
#			verbose=true; shift;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#	Basically, this is TRUE AND DO ...
[ $# -eq 0 ] && usage



#	Check presence of bowtie, blast and diamond references




#	Be verbose
set -x

#	exit on any error
set -e




date



while [ $# -ne 0 ] ; do

	base=$1

	{
		date

		#	if the input are fastq, then --un, --al, etc are also. blastn only uses fastA
		#	very fast, fast, sensitive, or very sensitive. Tried very fast, but probably should've gone the other way.
		#	-N only works if sam/bam file has paired info. Aligned -U, does not have paired info.
		bowtie2 --threads ${threads} --very-fast -x ${human} \
			-U $(ls ${base}*fastq.gz | paste -sd ',' ) \
			| samtools fasta -f 4 --threads $[threads-1] -N -	\
			| gzip --best > ${base}.non${human}.fasta.gz
		chmod -w ${base}.non${human}.fasta.gz

		#		-S ${base}.sam
			#chmod -w ${base}.sam
		#	rm ${base}.sam


		#	export BLASTDB=/Users/jakewendt/BLAST_DBS

		#	makeblastdb -dbtype nucl -in viral.fasta -out viral -title viral -parse_seqids

		blastn -query <( zcat ${base}.non${human}.fasta.gz ) \
			-db "${blastn_viral}" \
			-num_threads ${threads} \
			2> /dev/null | gzip --best > ${base}.non${human}.blastn.txt.gz

		chmod -w ${base}.non${human}.blastn.txt.gz


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
			--db "${diamond_viral}" \
			--query <( zcat ${base}.non${human}.fasta.gz ) \
			2> /dev/null | gzip --best > ${base}.non${human}.diamond.txt.gz

		chmod -w ${base}.non${human}.diamond.txt.gz

		date
	} > ${base}.log 2>&1
	chmod -w ${base}.log

	#	mkdir -p ../20180228.dark/
	#	mv ${base}.non${human}.* ${base}.log ../20180228.dark/

	shift
done
