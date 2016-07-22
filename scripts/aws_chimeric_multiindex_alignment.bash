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
#	echo "Contains a list of entries in the format ... chrY:6749856:EF"
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









#	I think that the "exit" call in the usage function just ends the subshell.
#[ -e "${BOWTIE2_INDEXES}/${index}.1.bt2" ] || (echo -e "\nIndex not found.\n\n" && usage)
#if [ ! -e "${BOWTIE2_INDEXES}/${index}.1.bt2" ] ; then
#	echo -e "\nIndex not found.\n\n"
#	usage
#fi

##	I think that the "exit" call in the usage function just ends the subshell.
##[ -e "${index}.insertion_points" ] || (echo -e "\nInsertion points list not found.\n\n" && usage)
#if [ ! -e "${index}.insertion_points" ] ; then
#	echo -e "\nInsertion points list not found.\n\n"
#	usage
#fi



#find . -name \*pre\*fasta -execdir align_herv_k113_chimerics_to_index.sh --index ${index} --core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned \; > align_herv_k113_chimerics_to_index.sh.out
#
#	Trying to resolve this which occurs after about 100
#
#	+ '[' 0 -gt 0 ']'
#	/home/ec2-user/.local/bin/align_herv_k113_chimerics_to_index.sh: cannot make pipe for command substitution: Too many open files
#	  base=
#	++ basename /home/ec2-user/.local/bin/align_herv_k113_chimerics_to_index.sh
#	/home/ec2-user/.local/bin/align_herv_k113_chimerics_to_index.sh: redirection error: cannot duplicate fd: Too many open files
#	/home/ec2-user/.local/bin/align_herv_k113_chimerics_to_index.sh: line 215: 1: Too many open files
#	/usr/bin/env: error while loading shared libraries: libc.so.6: cannot open shared object file: Error 24
#	20
#	+ mapq=20

#find . -name \*pre\*fasta -execdir sh -c "align_herv_k113_chimerics_to_index.sh --index ${index} --core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned > align_herv_k113_chimerics_to_index.sh.out 2>&1" \; > align_herv_k113_chimerics_to_index.sh.out



initial_PWD=$PWD
for file in `find . -name \*pre\*fasta` ; do
	cd $initial_PWD
	cd `dirname $file`
	base=`basename $PWD`
	echo $base

	for index in `find ${BOWTIE2_INDEXES} -name ${index_glob}.rev.1.bt2` ; do

		index=${index%%.rev.1.bt2}	#	remove .rev.1.bt2
		index=${index##*/}	#	drop the longest prefix match to "*/" (the path)

		align_herv_k113_chimerics_to_index.bash --index ${index} --core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned

	done

	mkdir parts

	for q in 20 10 00 ; do

		mv *${core}.pre_ltr.bowtie2.*.Q${q}.insertion_points parts/
		cat parts/*${core}.pre_ltr.bowtie2.*.Q${q}.insertion_points \
			> ${base}.${core}.pre_ltr.bowtie2.multiindex.Q${q}.insertion_points

		mv *${core}.pre_ltr.bowtie2.*.Q${q}.rc_insertion_points parts/
		cat parts/*${core}.pre_ltr.bowtie2.*.Q${q}.rc_insertion_points \
			> ${base}.${core}.pre_ltr.bowtie2.multiindex.Q${q}.rc_insertion_points \

		mv *${core}.post_ltr.bowtie2.*.Q${q}.rc_insertion_points parts/
		cat parts/*${core}.post_ltr.bowtie2.*.Q${q}.rc_insertion_points \
			> ${base}.${core}.post_ltr.bowtie2.multiindex.Q${q}.rc_insertion_points \

		mv *${core}.post_ltr.bowtie2.*.Q${q}.insertion_points parts/
		cat parts/*${core}.post_ltr.bowtie2.*.Q${q}.insertion_points \
			> ${base}.${core}.post_ltr.bowtie2.multiindex.Q${q}.insertion_points \

		mv *${core}.both_ltr.bowtie2.*.Q${q}.rc_insertion_points.rc_overlappers parts/
		cat parts/*${core}.both_ltr.bowtie2.*.Q${q}.rc_insertion_points.rc_overlappers \
			> ${base}.${core}.both_ltr.bowtie2.multiindex.Q${q}.rc_insertion_points.rc_overlappers \

		mv *${core}.both_ltr.bowtie2.*.Q${q}.insertion_points.overlappers parts/
		cat parts/*${core}.both_ltr.bowtie2.*.Q${q}.insertion_points.overlappers \
			> ${base}.${core}.both_ltr.bowtie2.multiindex.Q${q}.insertion_points.overlappers \

	done

done


index="multiindex"

cd $initial_PWD


#	This compiles everything there, not just matches to glob


for q in 20 10 00 ; do
	echo $q

	echo compile_all_overlappers.sh --mapq $q --index ${index}
	compile_all_overlappers.bash --mapq $q --index ${index} \
		--core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned

	q="Q${q}"

	echo insertion_points_to_table.sh --skip-table \*${q}\*points
	insertion_points_to_table.sh --skip-table \*${q}\*points > insertion_points_to_table.${q}.irrelevant

	mv tmpfile.\*${q}\*points.* insertion_points.${index}.${q}




	echo cat overlapper_reference.${index}.${q} ${index}.insertion_points
	cat overlapper_reference.${index}.${q} ${index}.insertion_points | sort > overlapper_reference_with_existing_insertions.${index}.${q}


	echo positions_within_10bp_of_reference.sh -p reference
	positions_within_10bp_of_reference.sh -p reference overlapper_reference_with_existing_insertions.${index}.${q} insertion_points.${index}.${q} > insertion_points.${index}.${q}.within_10bp_of_reference.reference_lines

	echo positions_within_10bp_of_reference.sh
	positions_within_10bp_of_reference.sh overlapper_reference_with_existing_insertions.${index}.${q} insertion_points.${index}.${q} > insertion_points.${index}.${q}.within_10bp_of_reference.sample_lines

	echo to_table.sh insertion_points.${index}.${q}.within_10bp_of_reference.reference_lines
	to_table.sh insertion_points.${index}.${q}.within_10bp_of_reference.reference_lines > insertion_points_near_reference.${index}.${q}.reference.csv

	echo to_table.sh insertion_points.${index}.${q}.within_10bp_of_reference.sample_lines
	to_table.sh insertion_points.${index}.${q}.within_10bp_of_reference.sample_lines > insertion_points_near_reference.${index}.${q}.sample.csv

	echo sort insertion_points_near_reference.${index}.${q}.reference.csv
	( head -1 insertion_points_near_reference.${index}.${q}.reference.csv && tail -n +2 insertion_points_near_reference.${index}.${q}.reference.csv | sort -t: -k1,1 -k2,2n ) > insertion_points_near_reference.${index}.${q}.reference.sorted.csv

	echo csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.reference.sorted.csv
	csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.reference.sorted.csv > insertion_points_near_reference.${index}.${q}.reference.sorted.grouped.csv

	echo sort insertion_points_near_reference.${index}.${q}.sample.csv
	( head -1 insertion_points_near_reference.${index}.${q}.sample.csv && tail -n +2 insertion_points_near_reference.${index}.${q}.sample.csv | sort -t: -k1,1 -k2,2n ) > insertion_points_near_reference.${index}.${q}.sample.sorted.csv

	echo csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.sample.sorted.csv
	csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.sample.sorted.csv > insertion_points_near_reference.${index}.${q}.sample.sorted.grouped.csv

done

mkdir extracted
mv compile* ${index}* insertion* overlap* extracted/
chmod -R -w extracted

