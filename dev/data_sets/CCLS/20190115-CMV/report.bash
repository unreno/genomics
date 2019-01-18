#!/usr/bin/env bash

echo -e "subject\tvirus\tcount"

for f in */*.aligned_count.txt ; do
#GM_983899/GM_983899.KF297339.1.aligned_count.txt 		0

	b=$( basename $f .aligned_count.txt )
	c=$( cat $f )

	s=${b%%.*}
	v=${b#*.}

	desc=$( head -1 /raid/refs/fasta/virii/${v}.fasta )

	echo -e $s"\t"$desc"\t"$c
	

done
