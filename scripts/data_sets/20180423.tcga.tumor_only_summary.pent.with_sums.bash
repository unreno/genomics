#!/usr/bin/env bash



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
END{ print_record() }' <( zcat tumor_only.sorted.uniq.pent.txt.gz ) TCGA-*.snps.txt | gzip > tumor_only.summary_table.pent.raw.with_sums.csv.gz

datamash transpose -t, < <( zcat tumor_only.summary_table.pent.raw.with_sums.csv.gz ) | gzip > tumor_only.summary_table.pent.with_sums.csv.gz





