#!/usr/bin/env bash

awk 'BEGIN{ FS=OFS=",";split("",subjects); }
( NR == FNR ){ 
#	if( $1 in subjects ){
#		subjects[$1][length(subjects[$1])+1] = $2
#	} else {
#		subjects[$1][1] = $2
#	}
	subjects[$1][$2]++
}
( NR != FNR && FNR == 1 ){ print "sample",$0 }
( NR != FNR && $1 in subjects ){ 
	for( sample in subjects[$1] ){
		print sample","$0
	}
}' select_subjects.txt all_subjects_info.csv > subjects_info.csv

#}' select_subjects.txt /raid/data/raw/gEUVADIS/subjects_info.csv > subjects_info.csv

