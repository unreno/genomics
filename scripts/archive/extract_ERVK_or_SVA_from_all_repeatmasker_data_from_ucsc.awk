#
#	bin	swScore	milliDiv	milliDel	milliIns	genoName	genoStart	genoEnd	genoLeft	strand	repName	repClass	repFamily	repStart	repEnd	repLeft	id
#
( NR == 1 ) || ( $13 == "ERVK" ) || ( $11 ~ /^SVA_/ ){
	print
}
