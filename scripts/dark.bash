#!/usr/bin/env bash

script=$( basename $0 )

human="hg38"
blastn_viral="viral"	#/Users/jakewendt/BLAST_DBS/viral"
diamond_viral=""	#	/Users/jakewendt/DIAMOND/viral"
threads=8

function usage(){
	echo
	echo "Usage: ${script}"
	echo
	echo "$script [--human STRING] [--blastn_viral PATH] [--diamond_viral PATH] [--threads INTEGER] <file base(s)>"
	echo
	echo "Defaults:"
	echo "	threads .......... ${threads}"
	echo "	human ............ ${human}"
	echo "	blastn_viral ..... ${blastn_viral}"
	echo "	diamond_viral .... ${diamond_viral}"
	echo
	echo "Examples:"
	echo
	echo "$script --human hg38 --blastn_viral /Users/jakewendt/BLAST_DBS/viral --threads 8 H74_S6_L00"
	echo
	exit 1
}



while [ $# -ne 0 ] ; do
	case $1 in
		--threads)
			shift; threads=$1; shift;;
		--human)
			shift; human=$1; shift;;
		--blastn_viral)
			shift; blastn_viral=$1; shift;;
		--diamond_viral)
			shift; diamond_viral=$1; shift;;
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

	local_base=$( basename $base )

	{
		date

#	This was a mistake as it can include too many files.
#	If $base is 1, the 1*fastq.gz includes so much more.
#			-U $(ls ${base}*fastq.gz | paste -sd ',' ) \

		#	if the input are fastq, then --un, --al, etc are also. blastn only uses fastA
		#	very fast, fast, sensitive, or very sensitive. Tried very fast, but probably should've gone the other way.
		#	-N only works if sam/bam file has paired info. Aligned -U, does not have paired info.
		bowtie2 --threads ${threads} --very-fast -x ${human} \
			-U $(ls ${base}.R?.fastq.gz | paste -sd ',' ) \
			| samtools fasta -f 4 --threads $[threads-1] -N -	\
			| gzip --best > ${local_base}.non${human}.fasta.gz
		chmod -w ${local_base}.non${human}.fasta.gz

		#		-S ${base}.sam
			#chmod -w ${base}.sam
		#	rm ${base}.sam


		#	export BLASTDB=/Users/jakewendt/BLAST_DBS

		#	makeblastdb -dbtype nucl -in viral.fasta -out viral -title viral -parse_seqids

		if [[ ! -z "${blastn_viral}" ]]; then

			blastn -query <( zcat ${local_base}.non${human}.fasta.gz ) \
				-db "${blastn_viral}" \
				-num_threads ${threads} \
				2> /dev/null | gzip --best > ${local_base}.non${human}.blastn.txt.gz

			chmod -w ${local_base}.non${human}.blastn.txt.gz

		fi

		#	ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/

		#	MAKE SURE THAT THE SOURCE FASTA IS A PROTEIN FASTA AND NOT NUCEOTIDES
		#	I used EMBOSS's transeq
		#	transeq viral.fasta viral.protein.fasta
		#	diamond makedb --in viral.protein.fasta --db viral

		#	https://github.com/bbuchfink/diamond/blob/master/diamond_manual.pdf
		#	--outfmt 0 is the same as blastn's default output format

		if [[ ! -z "${diamond_viral}" ]]; then

			diamond blastx \
				--outfmt 0 \
				--threads ${threads} \
				--db "${diamond_viral}" \
				--query <( zcat ${local_base}.non${human}.fasta.gz ) \
				2> /dev/null | gzip --best > ${local_base}.non${human}.diamond.txt.gz

			chmod -w ${local_base}.non${human}.diamond.txt.gz

		fi

		date
	} > ${local_base}.log 2>&1
	chmod -w ${local_base}.log

	#	mkdir -p ../20180228.dark/
	#	mv ${base}.non${human}.* ${base}.log ../20180228.dark/

	shift
done
