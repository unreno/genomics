#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


script=$( basename $0 )
source_path='/raid/data/raw/CCLS/bam'
unique_extension='.recaled.bam'
threads=40
canonical=''
bam_quality=40
proper_pair_only=''

function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "$script [--source_path STRING] [--unique_extension STRING] [--extension STRING] [--threads INTEGER] [--bam_quality INTEGER] [--canonical] [--proper_pair_only]"
	echo
	echo "Example:"
	echo "$script -p /raid/data/raw/MS-20190422 -u _R1.fastq.gz -e fastq.gz --canonical"
	echo "$script -p /raid/data/raw/CCLS -b 40 -u .recaled.bam"
	echo
	exit
}

while [ $# -ne 0 ] ; do
	case $1 in
		-s|--s*)
			shift; source_path=$1; shift ;;
		-u|--u*)
			shift; unique_extension=$1; shift ;;
		-e|--e*)
			shift; extension=$1; shift ;;
		-t|--t*)
			shift; threads=$1; shift ;;
		-c|--c*)
			shift; canonical='--both-strands';;		#	in jellyfish 2, this is --canonical
		-p|--p*)
			shift; proper_pair_only='-f 2';;
		-b|--b*)
			shift; bam_quality=$1; shift ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

[ $# -ne 0 ] && usage

: ${extension:=${unique_extension}}

echo "Source Path : ${source_path}"
echo "Unique Extension : ${unique_extension}"
echo "Extension : ${extension}"
echo "Canonical : ${canonical}"


#base_dir=$PWD


KMERSIZE=31 # RD:61


hawkDir=/home/jake/HAWK-0.9.8-beta
#	My version, 2.2.4 never completed?
jellyfishDir=${hawkDir}/supplements/jellyfish-Hawk/bin	# the included version is modified 1.1.6
#jellyfishDir=/usr/bin
#sortDir=/usr/bin # my normal version seems to be the parallel version


#for file in $( ls -d /raid/data/raw/CCLS/bam/*bam )
#for file in $( ls /raid/data/raw/CCLS/bam/{GM_,}{983899,63185,268325,439338,634370}.recaled.bam )

for file in $( ls ${source_path}/*${unique_extension} )
do
	OUTPREFIX=$( basename $file	${unique_extension} )

	echo ${OUTPREFIX}

	#if [ ${OUTPREFIX} == "120207" ] ; then
	#	echo "Skipping"
	#	continue
	#fi


#	if [   -f ${OUTPREFIX}.kmers.hist.csv ] \
#	&& [ ! -w ${OUTPREFIX}.kmers.hist.csv ] \
#	&& [   -f ${OUTPREFIX}_kmers_sorted.txt ] \
#	&& [ ! -w ${OUTPREFIX}_kmers_sorted.txt ] \
#	&& [   -f ${OUTPREFIX}_total_kmer_counts.txt ] \
#	&& [ ! -w ${OUTPREFIX}_total_kmer_counts.txt ] ; then

	if [   -f ${OUTPREFIX}_kmers_sorted.txt.gz ] \
	&& [ ! -w ${OUTPREFIX}_kmers_sorted.txt.gz ] ; then
		echo "Write-protected final products exist. Skipping."
	else

		f=${OUTPREFIX}_kmers_jellyfish
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			ls -l ${source_path}/${OUTPREFIX}*${extension}
			echo ${extension}

			if [ ${extension:(-1)} == 'q' ] ; then
				command="cat ${source_path}/${OUTPREFIX}*${extension}"
			elif [ ${extension:(-4)} == 'q.gz' ] ; then
				command="zcat ${source_path}/${OUTPREFIX}*${extension}"
			elif [ ${extension:(-3)} == 'bam' ] ; then
				#	this may not work for multiple matches
				command="samtools view -h -q ${bam_quality} ${proper_pair_only} ${source_path}/${OUTPREFIX}*${extension} | samtools fastq -"
			else
				echo "Unknown filetype so exiting"
				exit
			fi
			echo $command

			mkdir -p ${OUTPREFIX}_kmers

			#	I think that perhaps this samtools fastq should have some flags added to filter out only high quality, proper pair aligned reads?
			#	Sadly "samtools fastq" does not have a -q quality filter as does "samtools view". Why not?
			#	I suppose that I could pipe one to the other like ...
			#		<( samtools view -h -q 40 -f 2 ${file} | samtools fastq - )

			#	I think that when extracting reads from a bam, we probably shouldn't use the -C(canonical) flag,
			#		particularly when select high quality mappings

			date
			${jellyfishDir}/jellyfish count ${canonical} --output ${OUTPREFIX}_kmers/tmp \
				--mer-len ${KMERSIZE} --threads ${threads} --size 5G \
				<( eval ${command} )
			date


			COUNT=$(ls ${OUTPREFIX}_kmers/tmp* |wc -l)

			if [ $COUNT -eq 1 ]
			then
	 			mv ${OUTPREFIX}_kmers/tmp_0 ${f}
			else
				${jellyfishDir}/jellyfish merge -o ${f} ${OUTPREFIX}_kmers/tmp*
			fi
			rm -rf ${OUTPREFIX}_kmers

			chmod a-w $f
		fi

		f=${OUTPREFIX}.kmers.hist.csv
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			f2=${OUTPREFIX}.kmers.jellyfish.hist.csv
			if [ -f $f2 ] && [ ! -w $f2 ] ; then
				echo "Write-protected $f2 exists. Skipping."
			else
				echo "Creating $f2"
				${jellyfishDir}/jellyfish histo --full --output ${f2} --threads ${threads} ${OUTPREFIX}_kmers_jellyfish
				chmod a-w $f2
			fi

			#	swap, for some reason
			awk '{print $2"\t"$1}' ${OUTPREFIX}.kmers.jellyfish.hist.csv > ${f}
			chmod a-w $f

			rm -f $f2
		fi


		f=${OUTPREFIX}_total_kmer_counts.txt
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			awk -f ${hawkDir}/countTotalKmer.awk ${OUTPREFIX}.kmers.hist.csv > ${f}
			chmod a-w $f
		fi

		f1=${OUTPREFIX}_kmers_sorted.txt.gz
		if [ -f $f1 ] && [ ! -w $f1 ] ; then
			echo "Write-protected $f1 exists. Skipping."
		else

			f2=${OUTPREFIX}_kmers_sorted.txt
			if [ -f $f2 ] && [ ! -w $f2 ] ; then
				echo "Write-protected $f2 exists. Skipping."
			else

				#	Original version does this with CUTOFF. I have no idea why.
				#	Set it to 1, output it to a file, then add 1 and use as the lower limit.
				#	Everytime? Why not just fixed as 2?
				#
				#	CUTOFF=1
				#	echo $CUTOFF > ${OUTPREFIX}_cutoff.csv
				#	${jellyfishDir}/jellyfish dump -c -L `expr $CUTOFF + 1` \
				#		${OUTPREFIX}_kmers_jellyfish > ${OUTPREFIX}_kmers.txt

				f3=${OUTPREFIX}_kmers.txt
				if [ -f $f3 ] && [ ! -w $f3 ] ; then
					echo "Write-protected $f3 exists. Skipping."
				else
					echo "Creating $f3"
					${jellyfishDir}/jellyfish dump --column --lower-count 2 ${OUTPREFIX}_kmers_jellyfish > ${f3}
					chmod a-w $f3
				fi

				echo "Creating $f2"
				sort --parallel=${threads} -n -k 1 ${f3} > ${f2}
				chmod a-w $f2

				rm -f $f3
			fi

			gzip --best $f2

		fi

		rm -f ${OUTPREFIX}_kmers_jellyfish

	fi

done
