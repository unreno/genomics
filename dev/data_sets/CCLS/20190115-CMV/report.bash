#!/usr/bin/env bash

echo -e "subject\tvirus\tcount"

for f in */*.aligned_count.txt ; do
#GM_983899/GM_983899.KF297339.1.aligned_count.txt 		0

	b=$( basename $f .aligned_count.txt )
	c=$( cat $f )

	s=${b%%.*}
	v=${b#*.}

	echo -e $s"\t"$v"\t"$c
	

done
