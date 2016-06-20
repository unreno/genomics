#!/usr/bin/env bash

basedir=~/plinking/test/input

#for population in `ls -1d $basedir/pheno_files/* | xargs -n 1 basename` ; do
#for population in eur amr afr eas sas ; do	#	5
for population in eur ; do

	for pheno_name in `ls -1d $basedir/pheno_files/$population/* | xargs -n 1 basename` ; do
	
		for chromosome in `seq 1 23 && echo X && echo Y` ; do

			echo "aws_plink_wrapper.bash ${population} ${pheno_name} ${chromosome}"

		done
	done
done
