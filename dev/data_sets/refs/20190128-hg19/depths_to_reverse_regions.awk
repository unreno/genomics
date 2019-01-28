#NC_001664.4	7659	3
#	samtools depth NC_001664.4.bam | awk -f depths_to_reverse_regions.awk
#
#	If depth is empty this doesn't really work
#
BEGIN{
	FS="\t"
}
( !last_position ){
	if( $2 > 1 ){
		printf $1":1-"$2-1" "
	}
	last_position=$2
}
( last_position ){
	if( $2 > last_position+1 ){
		printf $1":"last_position+1"-"$2-1" "
	}
}
{
	last_position=$2
}
END{
	printf $1":"last_position+1"-10000000\n"
}

