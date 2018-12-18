BEGIN {
	FS=OFS="\t"
}
#	buffer first file
( NR == FNR ) {
	refs[$1]++;	#	columns
	hkles[$1][$2][$3]=$4;	#	SVA_A	chr19	45647550	-723
}
#	upon first line of not-first file, print header
( NR != FNR && FNR == 1 ){
	printf("REF\t")	#CHR\tPOS\tAS\t")
	asorti(refs)
	for(hkle in refs){
		printf("%s - alignments that were <150 away (Hits)\t",refs[hkle])
		printf("%s - alignments that were >150 away (Off target)\t",refs[hkle])
		printf("%s - # of SVA which the primer did not align near (Misses)\t",refs[hkle])
	}
	printf("\n")
}
#	process each line in not-first file
( NR != FNR ){
#	print "---"
	rows[$1]++

	for(hkle in refs){
		if($2 in hkles[refs[hkle]]){
			if( length(hkles[refs[hkle]][$2]) >= 0 ){
				for( position in hkles[refs[hkle]][$2] ){
					diff = position-$3
					absdiff = ( diff < 0 ) ? -diff : diff
					if( absdiff < 150 ){
						hits[$1][refs[hkle]]++
#						print "HIT " $0
					} else {
						off_target[$1][refs[hkle]]++
#						print "OFF " $0
					}
#					print $1  " - "  $2 " - " $3 " - " hkle " - " refs[hkle]
#					print absdiff
				}
			}
		} else {
			misses[$1][refs[hkle]]++
#			print "MIS " $0
		}
	}
}
END {
#for( hit in hits ){
#	print hit
##	print hits[hit]
#	for(x in hits[hit]){
#		print x
#		print hits[hit][x]
#	}
#}
	asorti(rows)
	for(row in rows){
		printf("%s\t",rows[row]);
		for(hkle in refs){	#	columns
			printf("%s\t",hits[rows[row]][refs[hkle]])
			printf("%s\t",off_target[rows[row]][refs[hkle]])
			printf("%s\t",misses[rows[row]][refs[hkle]])
		}
		printf("\n")
	}
}
