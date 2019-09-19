#!/usr/bin/env bash



for f in /raid/data/raw/Stanford_Project71/71*fastq.gz ; do
	#	71-7_S7_L001_R1_001.fastq.gz
	#l=$( basename $f )
	l=$( basename $f .gz )
	l=${l#71-}
	l=${l/_001./.}
	l=${l/S*_L001_/}

	#ln -s $f fastq/$l

	gunzip -c $f > fastq/$l

done

