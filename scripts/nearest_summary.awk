#
#	awk -f nearest_summary.awk \
#		svas.hg38_no_alts.vs.reverse.positions.csv \
#		sva_primers.hg38_no_alts.vs.reverse.positions.csv \
#		> sva_primers.nearest_sva.hg38_no_alts.vs.reverse.summary.csv
#
BEGIN {
	FS=OFS="\t"
}
{
	#	SVA_A	chr19	45647550	-723
	element=$1
	chromosome=$2
	position=$3
	score=$4
}
#	buffer first file (reference)
( NR == FNR ) {
#	I could filter on alignment scores (SVAs are -300 to -900)
#( NR == FNR && score > -800 ) {
	hkles[element]++;
	hkle_alignments[element][chromosome][position]=score;
}
#	first line of not-first file
( NR != FNR && FNR == 1 ){
	asorti(hkles,sorted_hkles)
}
#	process each line in not-first file
( NR != FNR ){
#	I could filter on alignment scores (Primers are 0 to -8)
#( NR != FNR && score == 0 ){
	primers[element]++

	for(hkle in sorted_hkles){
		#	sorted_hkles[hkle] ... SVA_A, SVA_B, ...
		if(chromosome in hkle_alignments[sorted_hkles[hkle]]){
#	not necessary. 
#			if( length(hkle_alignments[sorted_hkles[hkle]][chromosome]) >= 0 ){
				for( target_position in hkle_alignments[sorted_hkles[hkle]][chromosome] ){
					diff = target_position - position
					absdiff = ( diff < 0 ) ? -diff : diff
					if( absdiff < 150 ){
						hits[element][sorted_hkles[hkle]]++
					} else {
						off_target[element][sorted_hkles[hkle]]++
					}
				}
#			}
		} else {
			missed_chromosomes[element][sorted_hkles[hkle]][chromosome]++
#			misses[element][sorted_hkles[hkle]]++
		}
	}
}
END {
	printf("REF\talignments")	#CHR\tPOS\tAS\t")
	for(hkle in sorted_hkles){
		printf("\t%s - (%d) # alignments that were <150 away (Hits)",sorted_hkles[hkle],hkles[sorted_hkles[hkle]])
		printf("\t%s - # alignments that were >150 away (Off target)",sorted_hkles[hkle])
		printf("\t%s - # alignments of HKLE which the primer did not align near (Misses)",sorted_hkles[hkle])
	}
	printf("\n")
#
#	add "Any SVA" ???
#
	asorti(primers,sorted_primers)
	for(primer in sorted_primers){
		printf("%s\t%s",sorted_primers[primer],primers[sorted_primers[primer]]);
		for(hkle in sorted_hkles){	#	columns
			printf("\t%s",hits[sorted_primers[primer]][sorted_hkles[hkle]])
			printf("\t%s",off_target[sorted_primers[primer]][sorted_hkles[hkle]])

			missed=0
			if(sorted_hkles[hkle] in missed_chromosomes[sorted_primers[primer]]){
				for(missed_chromosome in missed_chromosomes[sorted_primers[primer]][sorted_hkles[hkle]]){
					if(missed_chromosome in hkle_alignments[sorted_hkles[hkle]]){
						missed+=length(hkle_alignments[sorted_hkles[hkle]][missed_chromosome])
					}
				}
			}
			printf("\t%s",missed)

		}
		printf("\n")
	}
}
