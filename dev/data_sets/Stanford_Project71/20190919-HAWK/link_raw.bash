#!/usr/bin/env bash


mkdir -p fastq

for f in /raid/data/raw/Stanford_Project71/71*fastq.gz ; do
	#	71-7_S7_L001_R1_001.fastq.gz
	l=$( basename $f )
	l=${l#71-}
	l=${l/_001./.}
	l=${l/_S*_L001/}

	ln -s $f fastq/$l

done

