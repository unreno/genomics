#!/usr/bin/env bash



for f in *.snps.txt; do
  n=${f%.txt}
  echo "Filtering $f to $n.filtered.txt"
awk 'BEGIN{FS=OFS="\t"}{
  x="";
  if( $1 == "MT" ) $1="M";
  cmd = "mysql --user root --skip-auto-rehash --skip-column-names --batch --execute \"SELECT alleles, alleleFreqs FROM snp150 WHERE class = '"'"'single'"'"' AND locType = '"'"'exact'"'"' AND chrom = '"'"'chr"$1"'"'"' AND chromEnd = "$2" AND refNCBI = '"'"'"$3"'"'"'\" hg38";
  while(cmd | getline x ){};	#	assuming only 1 match. true?
  close(cmd);
  if( x == "" ) print
}' $f > $n.filtered.txt &
done


