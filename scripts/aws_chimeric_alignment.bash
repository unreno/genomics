#!/usr/bin/env bash

threads=2
index="hg38_no_alts"
core="bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned"

#	If passed 1 fast[aq], check for chimeric reads.
#	If passed 2 fast[aq], also check for anchors with paired read run.

function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` [--threads 4] [--index hg19]"
	echo "[--core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned]"
	echo
	echo "Defaults:"
	echo "  threads ..... : $threads (for bowtie2)"
	echo "  index   ..... : $index (for bowtie2)"
	echo "  core    ..... : $core"
	echo
	echo "core is what is between \$PWD. and .pre_ltr.fasta"
	echo
	echo "Bowtie2 index must exist in \$BOWTIE2_INDEXES"
	echo
	echo "${index}.insertion_points must exist in \$PWD"
	echo "Contains a list of entries in the format ... chrY:6749856:EF"
	echo
	echo "Example:"
	echo "nohup aws_chimeric_alignment.bash --index hg19_no_alts > aws_chimeric_alignment.bash.out 2>&1 &"
	echo "nohup aws_chimeric_alignment.bash --index hg38_no_alts > aws_chimeric_alignment.bash.out 2>&1 &"
	echo
	exit
}

while [ $# -ne 0 ] ; do
	case $1 in
		-t|--t*)
			shift; threads=$1; shift ;;
		-i|--i*)
			shift; index=$1; shift ;;
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
if [ -e "${BOWTIE2_INDEXES}/${index}.1.bt2" ] ; then
	echo -e "\nIndex not found.\n\n"
	usage
fi

#	I think that the "exit" call in the usage function just ends the subshell.
#[ -e "${index}.insertion_points" ] || (echo -e "\nInsertion points list not found.\n\n" && usage)
if [ -e "${index}.insertion_points" ] ; then
	echo -e "\nInsertion points list not found.\n\n"
	usage
fi



find . -name \*pre\*fasta -execdir align_herv_k113_chimerics_to_index.sh --index ${index} --core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned \; > align_herv_k113_chimerics_to_index.sh.out



for q in 20 10 00 ; do
	echo $q

	echo compile_all_overlappers.sh --mapq $q --index ${index}
	compile_all_overlappers.sh --mapq $q --index ${index} \
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

#	don't think the leading $ is correct
	( head -1 insertion_points_near_reference.${index}.${q}.reference.csv && tail -n +2 insertion_points_near_reference.${index}.${q}.reference.csv | sort -t: -k1,1 -k2,2n ) > insertion_points_near_reference.${index}.${q}.reference.sorted.csv

	echo csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.reference.sorted.csv
	csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.reference.sorted.csv > insertion_points_near_reference.${index}.${q}.reference.sorted.grouped.csv

#	don't think the leading $ is correct
	( head -1 insertion_points_near_reference.${index}.${q}.sample.csv && tail -n +2 insertion_points_near_reference.${index}.${q}.sample.csv | sort -t: -k1,1 -k2,2n ) > insertion_points_near_reference.${index}.${q}.sample.sorted.csv

	echo csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.sample.sorted.csv
	csv_table_group_rows.sh insertion_points_near_reference.${index}.${q}.sample.sorted.csv > insertion_points_near_reference.${index}.${q}.sample.sorted.grouped.csv

done

mkdir extracted
mv compile* ${index}* insertion* overlap* extracted/
chmod -R -w extracted

