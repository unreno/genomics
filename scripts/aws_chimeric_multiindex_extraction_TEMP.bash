#!/usr/bin/env bash

threads=2
index_glob="*"
core="bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned"

#	If passed 1 fast[aq], check for chimeric reads.
#	If passed 2 fast[aq], also check for anchors with paired read run.

function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` [--threads INTEGER] [--index_glob BOWTIE2 INDEX NAME GLOB]"
	echo "[--core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned]"
	echo
	echo "Defaults:"
	echo "  threads ..... : $threads (for bowtie2)"
	echo "  index_glob .. : $index_glob (for bowtie2)"
	echo "  core ........ : $core"
	echo
	echo "core is what is between \$PWD. and .pre_ltr.fasta"
#	echo
#	echo "Bowtie2 index must exist in \$BOWTIE2_INDEXES"
#	echo
#	echo "${index}.insertion_points must exist in \$PWD"
#	echo "Contains a list of entries in the format ... chrY|6749856|EF"
	echo
	echo "Example:"
	echo "nohup `basename $0` --index hg19_no_alts > `basename $0`.out 2>&1 &"
	echo "nohup `basename $0` --index hg38_no_alts > `basename $0`.out 2>&1 &"
	echo
	exit
}

while [ $# -ne 0 ] ; do
	case $1 in
		-t|--t*)
			shift; threads=$1; shift ;;
		-i|--i*)
			shift; index_glob=$1; shift ;;
		-c|--c*)
			shift; core=$1; shift ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#       Basically, this is TRUE AND DO ...
[ $# -gt 0 ] && usage

: ${BOWTIE2_INDEXES:="${HOME}/s3/herv/indexes"}

initial_PWD=$PWD
#for file in `find . -name \*pre\*fasta` ; do
for file in `find . -mindepth 1 -maxdepth 1 -type d` ; do
	cd $initial_PWD
#	cd `dirname $file`
	cd $file
	base=`basename $PWD`
	echo $base

	for index in `find ${BOWTIE2_INDEXES} -name ${index_glob}.rev.1.bt2` ; do

		index=${index%%.rev.1.bt2}	#	remove .rev.1.bt2
		index=${index##*/}	#	drop the longest prefix match to "*/" (the path)

		extract_herv_k113_chimerics_from_bam_TEMP.bash --index ${index} --core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned

	done

done

index="multiindex"

cd $initial_PWD


for q in 20 10 00 ; do
	echo $q

	q="Q${q}"

	echo overlappers_to_table.bash \*${q}\*overlappers
	overlappers_to_table.bash \*${q}\*overlappers > overlappers.${q}.csv
	\rm tmpfile.\*${q}\*overlappers.*

done

