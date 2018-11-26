#!/usr/bin/env bash

base=${1%.*}

echo $1 $base

samtools view -F 20 $1 | awk '
BEGIN{ FS=OFS="\t" }
{
	for(i=12;i<=NF;i++)
		if($i ~ /^AS:/)
			split($i,a,":")
	print $1,$3,$4,a[3]
}' > $base.forward.positions.csv

samtools view -F 4 -f 16 $1 | awk '
BEGIN{ FS=OFS="\t" }
{
	for(i=12;i<=NF;i++)
		if($i ~ /^AS:/)
			split($i,a,":")
	print $1,$3,$4+length($10),a[3]
}' > $base.reverse.positions.csv

