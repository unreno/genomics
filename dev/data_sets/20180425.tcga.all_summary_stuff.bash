#!/usr/bin/env bash


gawk '
function print_record(){ printf "%s",filename; for( r in sref ){ printf ",%d",pos[sref[r]] } printf "\n" }
BEGIN{ FS="\t"; FN=0 }
(  NR ==  1 ){ printf "-" }
( FNR == NR ){ ref[$1":"$2":"$3":"$4]=$5; next }
( FNR ==  1 && FN == 0){ FN++; asorti(ref,sref);
for( r in sref ){ printf( ",%s:%s", sref[r], ref[sref[r]] ) } printf "\n" }
( FNR ==  1 && length(filename) > 0 ){ print_record(); delete(pos); }
( FNR ==  1 ){ split(FILENAME,f,"."); filename=f[1]; delete(f) }
{ pos[$1":"$2":"$3":"$4]++ }
END{ print_record() }' <( zcat all.sorted.uniq.txt.gz ) TCGA*.snps.txt | gzip > all.summary_table.raw.csv.gz

datamash transpose -t, < <( zcat all.summary_table.raw.csv.gz ) | gzip > all.summary_table.csv.gz


gawk '
function print_record(){ printf "%s",filename; for( r in sref ){ printf ",%d",pos[sref[r]] } printf "\n" }
BEGIN{ FS="\t"; FN=0 }
(  NR ==  1 ){ printf "-" }
( FNR == NR ){ ref[$1":"$2":"$3":"$4]=$5; next }
( FNR ==  1 && FN == 0){ FN++; asorti(ref,sref);
for( r in sref ){ printf( ",%s:%s", sref[r], ref[sref[r]] ) } printf "\n" }
( FNR ==  1 && length(filename) > 0 ){ print_record(); delete(pos); }
( FNR ==  1 ){ split(FILENAME,f,"."); filename=f[1]; delete(f) }
{ pos[$1":"$2":"$3":"$4]++ }
END{ print_record() }' <( zcat all.sorted.uniq.pent.txt.gz ) TCGA*.snps.txt | gzip > all.summary_table.pent.raw.csv.gz


datamash transpose -t, < <( zcat all.summary_table.pent.raw.csv.gz ) | gzip > all.summary_table.pent.csv.gz



gawk '
function print_record(){ printf("%s",filename); for( r in sref ){ printf(",%d",pos[sref[r]]) }; for( p in pent ){ printf(",%d",sums[pent[p]]) }; printf "\n" }
BEGIN{ FS="\t"; FN=0; split("ACGT",b,""); split("", pent); 
  for(i=1;i<=length(b);i++) 
  for(j=1;j<=length(b);j++) 
  for(k=1;k<=length(b);k++) 
  for(l=1;l<=length(b);l++) 
  for(m=1;m<=length(b);m++) 
  for(n=1;n<=length(b);n++) 
  if( n != k )
    pent[length(pent)+1]=b[i] b[j] b[k] b[l] b[m] "-" b[n]
}
(  NR ==  1 ){ printf "-" }
( FNR == NR ){ ref[$1":"$2":"$3":"$4]=$5; next }
( FNR ==  1 && FN == 0){ FN++; asorti(ref,sref);
  for( r in sref ){ printf( ",%s:%s", sref[r], ref[sref[r]] ) }
  for( p in pent ){ printf( ",%s",pent[p] ) }
  printf "\n" }
( FNR ==  1 && length(filename) > 0 ){ print_record(); delete(pos); delete(sums) }
( FNR ==  1 ){ split(FILENAME,f,"."); filename=f[1]; delete(f) }
{ pos[$1":"$2":"$3":"$4]++; sums[ref[$1":"$2":"$3":"$4]"-"$4]++ }
END{ print_record() }' <( zcat all.sorted.uniq.pent.txt.gz ) TCGA-*.snps.txt | gzip > all.summary_table.pent.raw.with_sums.csv.gz

datamash transpose -t, < <( zcat all.summary_table.pent.raw.with_sums.csv.gz ) | gzip > all.summary_table.pent.with_sums.csv.gz



#TTTTT-G,123,108,123,108,155,82,165,124,96,96,129,116,119,103,114,100,54,39,161,130,86,80,149,90,120,100,136,122,142,120,134,101,137,120,106,121,96,92,109,90,123,100,144,112,122,101,125,96,116,115,106,96,109,92,101,92,108,103,134,100,56,40,122,108,109,89,130,106,104,95,120,109,111,108,107,94,114,98,143,97,115,85,104,101,115,109,106,106,119,95,101,108,133,103,125,99,106,102,109,104,97,111,58,50

#	TTTTT-G,39,165,107.5,107.808


gawk 'BEGIN{ OFS=FS=","; print "transition,minimum,maximum,median,mean" }
( $1 ~ /^.....-./ ){
	sum=0
	split("",counts)
	for(i=2;i<=NF;i++){
		counts[i-1]=$i
		sum+=$i
	}
	asort(counts)
	c=length(counts)
	if( (c % 2) == 1 ) {
		median = counts[c/2];
	} else {
		median = ( counts[c/2] + counts[(c/2)-1] ) / 2;
	}
	mean=sum/(NF-1)
	print $1,counts[1],counts[c],median,mean
}
' <( zcat all.summary_table.pent.with_sums.csv.gz ) | gzip > all.summary_table.pent.with_sums.aggregates.gz


#	first line
#-,TCGA-02-2483-01A,TCGA-02-2483-10A,TCGA-02-2485-01A,TCGA-02-2485-10A,TCGA-06-0124-01A,TCGA-06-0124-10A,TCGA-06-0125-01A,TCGA-06-0125-10A,TCGA-06-0128-01A,TCGA-06-0128-10A,TCGA-06-0145-01A,TCGA-06-0145-10A,TCGA-06-0152-01A,TCGA-06-0152-10A,TCGA-06-0155-01B,TCGA-06-0155-10A,TCGA-06-0157-01A,TCGA-06-0157-10A,TCGA-06-0171-01A,TCGA-06-0171-10A,TCGA-06-0185-01A,TCGA-06-0185-10B,TCGA-06-0190-01A,TCGA-06-0190-10B,TCGA-06-0208-01A,TCGA-06-0208-10A,TCGA-06-0210-01A,TCGA-06-0210-10A,TCGA-06-0211-01A,TCGA-06-0211-10A,TCGA-06-0214-01A,TCGA-06-0214-10A,TCGA-06-0221-01A,TCGA-06-0221-10A,TCGA-06-0648-01A,TCGA-06-0648-10A,TCGA-06-0686-01A,TCGA-06-0686-10A,TCGA-06-0744-01A,TCGA-06-0744-10A,TCGA-06-0745-01A,TCGA-06-0745-10A,TCGA-06-0877-01A,TCGA-06-0877-10A,TCGA-06-0881-01A,TCGA-06-0881-10A,TCGA-06-1086-01A,TCGA-06-1086-10A,TCGA-06-2557-01A,TCGA-06-2557-10A,TCGA-06-2570-01A,TCGA-06-2570-10A,TCGA-06-5411-01A,TCGA-06-5411-10A,TCGA-06-5415-01A,TCGA-06-5415-10A,TCGA-14-0786-01B,TCGA-14-0786-10A,TCGA-14-1034-01A,TCGA-14-1034-10A,TCGA-14-1401-01A,TCGA-14-1401-10A,TCGA-14-1402-01A,TCGA-14-1402-10A,TCGA-14-1454-01A,TCGA-14-1454-10A,TCGA-14-1459-01A,TCGA-14-1459-10A,TCGA-14-1823-01A,TCGA-14-1823-10A,TCGA-14-2554-01A,TCGA-14-2554-10A,TCGA-15-1444-01A,TCGA-15-1444-10A,TCGA-16-1063-01B,TCGA-16-1063-10A,TCGA-16-1460-01A,TCGA-16-1460-10A,TCGA-19-1389-01A,TCGA-19-1389-10D,TCGA-19-2620-01A,TCGA-19-2620-10A,TCGA-19-2624-01A,TCGA-19-2624-10A,TCGA-19-2629-01A,TCGA-19-2629-10A,TCGA-19-5960-01A,TCGA-19-5960-10A,TCGA-26-1438-01A,TCGA-26-1438-10A,TCGA-26-5132-01A,TCGA-26-5132-10A,TCGA-26-5135-01A,TCGA-26-5135-10A,TCGA-27-1831-01A,TCGA-27-1831-10A,TCGA-27-2523-01A,TCGA-27-2523-10A,TCGA-27-2528-01A,TCGA-27-2528-10A,TCGA-32-1970-01A,TCGA-32-1970-10A,TCGA-41-5651-01A,TCGA-41-5651-10A


#	last line
#TTTTT-G,123,108,123,108,155,82,165,124,96,96,129,116,119,103,114,100,54,39,161,130,86,80,149,90,120,100,136,122,142,120,134,101,137,120,106,121,96,92,109,90,123,100,144,112,122,101,125,96,116,115,106,96,109,92,101,92,108,103,134,100,56,40,122,108,109,89,130,106,104,95,120,109,111,108,107,94,114,98,143,97,115,85,104,101,115,109,106,106,119,95,101,108,133,103,125,99,106,102,109,104,97,111,58,50

#	TTTTT-G,39,165,107.5,107.808

#	ASSUMING sorted ... tumor,normal,tumor,normal,...

gawk 'BEGIN{ OFS=FS=","; print "transition,tumor_minimum,normal_minimum,tumor_maximum,normal_maximum,tumor_median,normal_median,tumor_mean,normal_mean" }
( $1 ~ /^.....-./ ){
	tumor_sum=normal_sum=0
	split("",tumor_counts)
	split("",normal_counts)
	for(i=2;i<=NF;i++){
		if( ( i % 2 ) == 1 ) {
			normal_counts[i-1]=$i
			normal_sum+=$i
		} else {
			tumor_counts[i-1]=$i
			tumor_sum+=$i
		}
	}
	asort(tumor_counts)
	asort(normal_counts)
	c=length(tumor_counts)	#	same for normal
	if( (c % 2) == 1 ) {
		tumor_median = tumor_counts[c/2];
		normal_median = normal_counts[c/2];
	} else {
		tumor_median = ( tumor_counts[c/2] + tumor_counts[(c/2)-1] ) / 2;
		normal_median = ( normal_counts[c/2] + normal_counts[(c/2)-1] ) / 2;
	}
	tumor_mean=tumor_sum/(c-1)
	normal_mean=normal_sum/(c-1)
	print $1,tumor_counts[1],normal_counts[1],tumor_counts[c],normal_counts[c],tumor_median,normal_median,tumor_mean,normal_mean
}
' <( zcat all.summary_table.pent.with_sums.csv.gz ) | gzip > all.summary_table.pent.with_sums.tumor_normal_aggregates.gz


