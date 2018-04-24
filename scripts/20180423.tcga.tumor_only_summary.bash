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
END{ print_record() }' <( zcat tumor_only.sorted.uniq.txt.gz ) TCGA*.snps.txt | gzip > tumor_only.summary_table.raw.csv.gz

datamash transpose -t, < <( zcat tumor_only.summary_table.raw.csv.gz ) | gzip > tumor_only.summary_table.csv.gz

