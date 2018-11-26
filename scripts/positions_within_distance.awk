{
	FS=OFS="\t";
	distance=150;
}
( NR == FNR ) {
	positions[$2][$3][$1]++
}
( NR != FNR && $2 in positions ) {
	found=NULL
	for( pos in positions[$2] )
		if( ( (pos-distance) < $3 ) && ( (pos+distance) > $3 ) ){
			found="true"
#     hkles=positions[$2][pos][1]
#     for(i=2;i<=length(positions[$2][pos]);i++)
#       hkles=hkles","positions[$2][pos][i]
#     print $1,$2,$3,pos,hkles

			hkles=""
			for( hkle in positions[$2][pos] )
				hkles = hkles","hkle
				print $1,$2,$3,pos,hkles
			}
	if( ! found ) print
}
( NR != FNR && !($2 in positions) ) {
	print
}
