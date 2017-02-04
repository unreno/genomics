#	
#	awk -f find_in_geno_range.awk ct_cuttree_Q20sites.csv all_repeatmasker_data_from_ucsc.txt > ct_cuttree_Q20sites_merged_offset_blank.csv
#	
#	awk -f find_in_geno_range.awk -v offset=0 ct_cuttree_Q20sites.csv all_repeatmasker_data_from_ucsc.txt > ct_cuttree_Q20sites_merged_offset_i100.csv
#	
#	awk -f find_in_geno_range.awk -v offset=100 ct_cuttree_Q20sites.csv all_repeatmasker_data_from_ucsc.txt > ct_cuttree_Q20sites_merged_offset_100.csv
#	
#	awk -f find_in_geno_range.awk -v offset=200 ct_cuttree_Q20sites.csv all_repeatmasker_data_from_ucsc.txt > ct_cuttree_Q20sites_merged_offset_200.csv
#	

@include "join"
BEGIN {
	if ( offset == "" ) offset = 0
}
(NR==FNR){
	#	$1 could be .... chr6_ssto_hap7_4079511_F_POST
	split($1,parts,"_")
	#	parts could then be [ chr6, ssto, hap7, 4079511, F, POST ]
	chr = join(parts,1,length(parts)-3,"_")
	position = parts[length(parts)-2]
	line[chr][position]=$0
	positions[chr][length(positions[parts[1]])+1]=position
}
(NR!=FNR){
	if( length(positions[$6]) > 0 ) {	#	doesn't always exist
		for(pos in positions[$6]){
			if( positions[$6][pos] > ( $7 - offset ) && positions[$6][pos] < ( $8 + offset ) ){
				print line[$6][positions[$6][pos]]"\t"$0
			}
		}
	}
}
