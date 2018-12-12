#!/usr/bin/env bash

for f in *.count.txt ; do

b=${f%.*}	#	remove extension

gawk 'BEGIN{FS=OFS="\t"}
( FNR == NR ){ positions[$1][$2][$3][$4]++; next }
( FNR == 1  ){ 
  printf $0
  for( class in positions ){
    printf "\tnearest %1$s\tnearest %1$s position\tnearest %1$s dist", class
  }
  printf "\tnearest HERVAny\tnearest HERVAny position\tnearest HERVAny dist"
  printf "\n"
}
( FNR > 1   ){
  c=$1
  p=$2
  printf $0
  nearest_name_any=nearest_pos_any=nearest_dist_any=abs_nearest_dist_any=""
  for( class in positions ){
    nearest_name=nearest_pos=nearest_dist=abs_nearest_dist=""
    for( name in positions[class] ){
      if( length(positions[class][name][c]) > 0 ){
        for( pos in positions[class][name][c] ){
          dist=pos-p
          abs_dist=( dist < 0.0 )?-dist:dist
          if( nearest_dist == "" || abs_dist < abs_nearest_dist ){
            nearest_name=name; nearest_pos=pos; nearest_dist=dist; abs_nearest_dist=abs_dist;
          }
          if( nearest_dist_any == "" || abs_dist < abs_nearest_dist_any ){
            nearest_name_any=name; nearest_pos_any=pos; nearest_dist_any=dist; abs_nearest_dist_any=abs_dist;
          }
        }
      }
    }
    printf "\t%s\t%s\t%s", nearest_name, nearest_pos, nearest_dist
  }
  printf "\t%s\t%s\t%s", nearest_name_any, nearest_pos_any, nearest_dist_any
  printf "\n"
}
' /raid/data/working/20170804-Adam/20180531-vcf-snp-analysis/20180615-FAKE/hg38.FAKE.20180615.positions.txt $f > $b.with_nearests.FAKE.csv &

#' /raid/data/working/20170804-Adam/20180531-vcf-snp-analysis/hg38.hervd.20180614.OR.class.positions.txt $f > $b.with_nearests.hervd.csv &


done


