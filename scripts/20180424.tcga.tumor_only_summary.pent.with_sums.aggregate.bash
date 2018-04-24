#!/usr/bin/env bash

#TTTTT-G,123,108,123,108,155,82,165,124,96,96,129,116,119,103,114,100,54,39,161,130,86,80,149,90,120,100,136,122,142,120,134,101,137,120,106,121,96,92,109,90,123,100,144,112,122,101,125,96,116,115,106,96,109,92,101,92,108,103,134,100,56,40,122,108,109,89,130,106,104,95,120,109,111,108,107,94,114,98,143,97,115,85,104,101,115,109,106,106,119,95,101,108,133,103,125,99,106,102,109,104,97,111,58,50

#	TTTTT-G,39,165,107.5,107.808


gawk 'BEGIN{ OFS=FS=","; print "transition,minimum,maximum,median,mean" }
( $1 ~ /^.....-./ ){
	minimum=9999999
	maximum=sum=0
	split("",counts)
	for(i=2;i<=NF;i++){
		counts[i-1]=$i
		sum+=$i
		if( $i < minimum ) minimum=$i
		if( $i > maximum ) maximum=$i
	}
	asort(counts)
	c=length(counts)
	if( (c % 2) == 1 ) {
		median = counts[ int(c/2) ];
	} else {
		median = ( counts[c/2] + counts[c/2-1] ) / 2;
	}
	mean=sum/(NF-1)
	print $1,minimum,maximum,median,mean
}
' <( zcat tumor_only.summary_table.pent.with_sums.csv.gz ) | gzip > tumor_only.summary_table.pent.with_sums.aggregates.gz


