#!/usr/bin/env bash

awk 'BEGIN{ FS=OFS="," }
( NR == FNR ){ subjects[$0]++ }
( NR != FNR && FNR == 1 ){ print }
( NR != FNR && $1 in subjects ){ print 
}' subjects.txt "/raid/data/raw/1000genomes/20130606_sample_info - Sample Info.csv" > subjects_info.csv

