#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


for f1 in /raid/data/raw/gEUVADIS/*_1.fastq.gz ; do
	#	 NA20759.4.M_120208_3_2.fastq.gz
#	f2=${f1/_1.fastq/_2.fastq}
	basename=${f1##*/}

	oldbase=${basename%.*_1.fastq.gz}	#	just 1 %, not 2			#	SADLY, this is NOT unique for 4 samples

	newbase=${basename%_1.fastq.gz}

	echo $f1
	echo $oldbase
	echo $newbase


	rename "s/${oldbase}/${newbase}/" ${oldbase}*


done

echo "Done"
