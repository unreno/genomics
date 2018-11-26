#!/usr/bin/env bash

echo "In development"

echo "Potential Filter on optional field with some logic required ( otherwise, just grep )"

echo "samtools view -h sva_primers.hg38_no_alts.vs.bam | awk 'BEGIN{FS=OFS="\t"}( /^@/ ){print}{ for(i=12;i<=NF;i++){ print $i }      }'"

