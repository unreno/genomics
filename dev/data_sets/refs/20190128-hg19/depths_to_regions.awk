#NC_001664.4	7659	3
#	samtools depth NC_001664.4.bam | awk -f depths_to_regions.awk
#
#	If depth is empty this doesn't really work
#
BEGIN{
	FS="\t"
}
( !last_position ){
	printf $1":"$2
	last_position=$2
}
( last_position ){
	if( $2 > last_position+1 ){
		printf "-"last_position" "$1":"$2
	}
}
{
	last_position=$2
}
END{
	printf "-"last_position"\n"
}
