BEGIN {
	FS=OFS="\t"
}
( NR == FNR ) {
	refs[$1]++;
	hkles[$1][$2][$3]=$4;
}
( NR != FNR && FNR == 1 ){
	printf("REF\tCHR\tPOS\tAS\t")
	asorti(refs)
	for(hkle in refs){
		printf("NEAREST %s\t",refs[hkle])
		printf("DIST NEAREST %s\t",refs[hkle])
		printf("AS NEAREST %s\t",refs[hkle])
#	for(hkle in hkles){
#		printf("NEAREST %s\t",hkle)
#		printf("DIST NEAREST %s\t",hkle)
	}
	printf("\n")
}
( NR != FNR ){
	printf("%s%s%s%s%s%s%s",$1,OFS,$2,OFS,$3,OFS,$4)
#	for(hkle in hkles){
#		if($2 in hkles[hkle]){
#			if( length(hkles[hkle][$2]) >= 0 ){
	for(hkle in refs){
		if($2 in hkles[refs[hkle]]){
			if( length(hkles[refs[hkle]][$2]) >= 0 ){
				nearest=999999999
				pos=0
				score="-"
#				for( position in hkles[hkle][$2] ){
				for( position in hkles[refs[hkle]][$2] ){
					diff = position-$3
					diff = ( diff < 0 ) ? -diff : diff
					if( diff < nearest ){
						nearest = diff
						pos = position
						score = hkles[refs[hkle]][$2][position]
					}
				}
				printf("%s%s",OFS,pos)
				printf("%s%s",OFS,nearest)
				printf("%s%s",OFS,score)
			} else {
				printf("%s-",OFS)
				printf("%s-",OFS)
				printf("%s-",OFS)
			}
		} else {
			printf("%s-",OFS)
			printf("%s-",OFS)
			printf("%s-",OFS)
		}
	}
	printf("\n")
}
