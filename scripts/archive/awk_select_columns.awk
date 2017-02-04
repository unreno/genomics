#	awk -f awk_select_columns.awk column_list_file tsv_file
BEGIN {
	FS="\t"
}
#	first file (columns list)
(NR==FNR){
	columns[$1]++
}
#	all other files (tsv data file)
(NR!=FNR && FNR==1){
	delete select_column_positions
	for(i = 1; i <= NF; i++) { 
		for( column in columns ){
			if( match( $i, column ) ){
				select_column_positions[i]++;
			}
		}
	}
}
(NR!=FNR){
	for(i = 1; i <= NF; i++) { 
		if( select_column_positions[i] > 0 ){
			printf "%s,",$i
		}
	}
	printf "\n"
}
