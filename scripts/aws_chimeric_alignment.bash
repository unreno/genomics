#!/usr/bin/env bash

set -x


x=hg38_no_alts

#	Is BOWTIE2_INDEXES set?

#	export BOWTIE2_INDEXES=~/s3/herv/indexes/
#	: ${BOWTIE2_INDEXES:="/Volumes/cube/working/indexes"}

#	Does the index exist?

#	ls ${BOWTIE2_INDEXES}/${x}*bt2

#	Does the list of insertion_points exist

#	ln -s ../../${x}.insertion_points.sorted








exit

find . -name \*pre\*fasta -execdir align_herv_k113_chimerics_to_index.sh --index ${x} --core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned \; > align_herv_k113_chimerics_to_index.sh.out

ln -s ../../${x}.insertion_points.sorted

for q in 20 10 00 ; do
	echo $q

	compile_all_overlappers.sh --mapq $q --index ${x} \
		--core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned

	q="Q${q}"

	insertion_points_to_table.sh --skip-table \*${q}\*points > insertion_points_to_table.${q}.irrelevant

	mv tmpfile.\*${q}\*points.* insertion_points.${x}.${q}

	cat overlapper_reference.${x}.${q} ${x}.insertion_points.sorted | sort > overlapper_reference_with_existing_insertions.${x}.${q}

	positions_within_10bp_of_reference.sh -p reference overlapper_reference_with_existing_insertions.${x}.${q} insertion_points.${x}.${q} > insertion_points.${x}.${q}.within_10bp_of_reference.reference_lines

	positions_within_10bp_of_reference.sh overlapper_reference_with_existing_insertions.${x}.${q} insertion_points.${x}.${q} > insertion_points.${x}.${q}.within_10bp_of_reference.sample_lines

	to_table.sh insertion_points.${x}.${q}.within_10bp_of_reference.reference_lines > insertion_points_near_reference.${x}.${q}.reference.csv

	to_table.sh insertion_points.${x}.${q}.within_10bp_of_reference.sample_lines > insertion_points_near_reference.${x}.${q}.sample.csv

	$( head -1 insertion_points_near_reference.${x}.${q}.reference.csv && tail -n +2 insertion_points_near_reference.${x}.${q}.reference.csv | sort -t: -k1,1 -k2,2n ) > insertion_points_near_reference.${x}.${q}.reference.sorted.csv

	csv_table_group_rows.sh insertion_points_near_reference.${x}.${q}.reference.sorted.csv > insertion_points_near_reference.${x}.${q}.reference.sorted.grouped.csv

	$(head -1 insertion_points_near_reference.${x}.${q}.sample.csv && tail -n +2 insertion_points_near_reference.${x}.${q}.sample.csv | sort -t: -k1,1 -k2,2n ) > insertion_points_near_reference.${x}.${q}.sample.sorted.csv

	csv_table_group_rows.sh insertion_points_near_reference.${x}.${q}.sample.sorted.csv > insertion_points_near_reference.${x}.${q}.sample.sorted.grouped.csv

done

mkdir extracted
mv align* compile* ${x}* insertion* overlap* extracted/
chmod -R -w extracted

