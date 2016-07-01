#!/usr/bin/env bash

#basedir=~/s3/herv/snp-20160620
basedir=~/s3/herv/snp-20160701

#	Aliases don't work here, but redefining it should
echo "alias awsq='mysql_queue.bash --defaults_file ~/.awsqueue.cnf'"

#	Recommend piping the output to sh

#for population in `ls -1d $basedir/pheno_files/* | xargs -n 1 basename` ; do
for population in eur amr afr eas sas ; do	#	5
#for population in eur ; do

	for genome in hg19_alt ; do


#	Given file sizes and such, it'd be better if genome were in population dir
#		rather than population in genome dir.
#	Then during processing the population files wouldn't have to be downloaded multiple times.



		for pheno_name in `ls -1d ${basedir}/pheno_files/${genome}/${population}/* | xargs -n 1 basename` ; do
	
#		for chromosome in `seq 1 22 && echo X && echo Y` ; do

			echo "awsq push 'aws_plink_wrapper.bash --genome ${genome} --pop ${population} --pheno ${pheno_name}"
#			echo "awsq push 'aws_plink_wrapper.bash --genome hg19_alt --pop ${population} --pheno ${pheno_name} --chromosome ${chromosome}'"
#			echo "awsq push 'aws_plink_wrapper.bash ${population} ${pheno_name} ${chromosome}'"

		done
	done
done

