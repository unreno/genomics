#!/usr/bin/env bash



#	create_ec2_instance.bash --profile herv --key ~/.aws/JakeHuman.pem --instance-type c4.2xlarge --volume-size 100 --NOT-DRY-RUN
#	ssh ...
#	cd .github/ccls/sequencing/
#	git pull
#	make install
#	cd .github/unreno/genomics/
#	git pull
#	make install
#	cd
#	sudo yum update
#	20180122.plink.bash

#	Making semi-parallel.
#	Can run multiple instances, just need to be different so they don't overwrite one another.
#	There is little error checking.

#	20180122.plink.bash --genome unknown --population eur --pheno phenoY
#	20180122.plink.bash --genome unknown --population amr --pheno phenoY
#	20180122.plink.bash --genome unknown --population afr --pheno phenoY
#	20180122.plink.bash --genome unknown --population eas --pheno phenoY
#	20180122.plink.bash --genome unknown --population sas --pheno phenoY





script=$(basename $0)
BASE=~/snpprocessing
REFS=$BASE/references
WORK=$BASE/working
S3_SOURCE=s3://herv/snp-20160701
S3_TARGET=s3://herv/snp-20180123

function usage(){
	echo
	echo "Usage:"
	echo
	echo "`basename $0` [--genome hg19_alt] [--population population] [--pheno pheno_name]"
	echo
	echo "Default:"
	echo "  genome ...... ${genome}"
	echo "  population .. ${population}"
	echo "  pheno ....... ${pheno_name}"
	echo
	echo "`basename $0` --genome hg19_alt --population eur --pheno chr17_ctg5_hap1_504028_F_PRE"
	echo
	exit 1
}

genome="hg19_alt"
population="eur"
pheno_name="testing"

while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		-g*|--g*)
			shift; genome=$1; shift ;;
		-po*|--po*)
			shift; population=$1; shift ;;
		-ph*|--ph*)
			shift; pheno_name=$1; shift ;;
		--)	#	just -- is a common and explicit "stop parsing options" option
			shift; break ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#[ -z ${pheno_name} ] && usage

[ $# -ne 0 ] && usage

set -x

mkdir -p $REFS

log=${script}.${population}.${genome}.${pheno_name}.log

#	Begin logging
{
	echo "Starting ..."
	date

#	for population in eur amr afr eas sas ; do	#	5

#		for genome in unknown ; do

			#	Given file sizes and such, it'd be better if genome were in population dir
			#		rather than population in genome dir.
			#	Then during processing the population files wouldn't have to be downloaded multiple times.

			#		for pheno_name in `ls -1d ${basedir}/pheno_files/${genome}/${population}/* | xargs -n 1 basename` ; do

#			for pheno_name in phenoY ; do




#/bin/rm -rf $WORK
mkdir -p $WORK/$population/$genome/$pheno_name
cd $WORK/$population/$genome/$pheno_name




				[ -f ${REFS}/1kg_all_chroms_pruned_mds.mds ] ||
					aws s3 cp ${S3_SOURCE}/1kg_all_chroms_pruned_mds.mds ${REFS}/

#				#	The pheno files are small, but once run, no need to keep them.
#				/bin/rm -rf ${REFS}/pheno_files/
#
#				mkdir -p ${REFS}/pheno_files/${genome}/${population}
#
#				[ -f ${REFS}/pheno_files/${genome}/${population}/${pheno_name} ] ||
#					aws s3 cp ${S3_SOURCE}/pheno_files/${genome}/${population}/${pheno_name} \
#						${REFS}/pheno_files/${genome}/${population}/

				[ -f ${REFS}/${pheno_name} ] ||
					aws s3 cp ${S3_TARGET}/${pheno_name} ${REFS}/

#				#	Pruned vcfs are large. Delete entire tree if current population doesn't exist?
#				#	This way, if population is same as previous run, already got it.
#				[ -d ${REFS}/pruned_vcfs/${population} ] ||
#					rm -rf ${REFS}/pruned_vcfs/

				mkdir -p ${REFS}/pruned_vcfs/

				[ -d ${REFS}/pruned_vcfs/${population} ] ||
					aws s3 cp ${S3_SOURCE}/pruned_vcfs/${population}.tar.gz \
						${REFS}/pruned_vcfs/

				[ -f ${REFS}/pruned_vcfs/${population}.tar.gz ] &&
					tar -xvzC ${REFS}/pruned_vcfs/ \
						-f ${REFS}/pruned_vcfs/${population}.tar.gz

				[ -f ${REFS}/pruned_vcfs/${population}.tar.gz ] &&
					rm -f ${REFS}/pruned_vcfs/${population}.tar.gz

				for bedfile in $( ls ${REFS}/pruned_vcfs/${population}/ALL.chr*.bed ) ; do

					bedfile_noext=${bedfile%.*} # drop the shortest suffix match to ".*" (the .bed extension)
					bedfile_core=${bedfile_noext##*/}	#	drop the longest prefix match to "*/" (the path)

#Note: --hide-covar flag deprecated.  Use e.g. '--linear hide-covar'.
#Note: --standard-beta flag deprecated.  Use e.g. '--linear standard-beta'.

#							--standard-beta \
#							--linear 
#							--hide-covar \

#	Using 1 thread (no multithreaded calculations invoked).

					plink --threads 8 \
							--snps-only \
							--allow-no-sex \
							--linear standard-beta hide-covar \
							--covar-name C1,C2,C3,C4,C5,C6 \
							--bfile ${bedfile_noext} \
							--pheno ${REFS}/${pheno_name} \
							--out ${bedfile_core}.no.covar \
							--covar ${REFS}/1kg_all_chroms_pruned_mds.mds

#							--pheno ${REFS}/pheno_files/${genome}/${population}/${pheno_name} \

#					awk '{print $1,$2,$3,$9,$4,$7}' ${bedfile_core}.no.covar.assoc.logistic > ${bedfile_core}.for.plot.txt

					awk '{print $1,$2,$3,$9,$4,$7}' ${bedfile_core}.no.covar.assoc.linear > ${bedfile_core}.for.plot.txt

					mv ${bedfile_core}.no.covar.log ${pheno_name}.${bedfile_core}.no.covar.log

					#	Try to manage disk space as could be tight.
#					rm ${bedfile_core}.no.covar.assoc.logistic
					rm ${bedfile_core}.no.covar.assoc.linear
					rm ${bedfile_core}.no.covar.nosex

				done	#	for bedfile

				#	Not keeping for.plot.all.txt so doesn't need a header
				#echo "CHR SNP BP P A1 OR" > ${pheno_name}.for.plot.all.txt
				#grep -v "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
				#grep --invert-match --no-filename "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
				grep --invert-match --no-filename "CHR" *.for.plot.txt > ${pheno_name}.for.plot.all.txt

				#	No wildcards, so don't need to specify --no-filename
				grep --invert-match "NA" ${pheno_name}.for.plot.all.txt | shuf -n 200000 > ${pheno_name}.for.qq.plot
				#	If not keeping header, don't need to skip the first line anymore!
				#tail -n +2 ${pheno_name}.for.plot.all.txt | grep -v "NA" | shuf -n 200000 > ${pheno_name}.for.qq.plot

				#	Keeping the NA rows now
				grep "NA" ${pheno_name}.for.plot.all.txt > ${pheno_name}.NA.txt

				awk '$4 < 0.10' ${pheno_name}.for.plot.all.txt > ${pheno_name}.for.manhattan.plot

				df -h .

				gzip --best ${pheno_name}.NA.txt
				aws s3 cp ${pheno_name}.NA.txt.gz \
						${S3_TARGET}/output/${genome}/${population}/

				gzip --best ${pheno_name}.log
				aws s3 cp ${pheno_name}.log.gz \
						${S3_TARGET}/output/${genome}/${population}/

				gzip --best --keep ${pheno_name}.for.qq.plot
				aws s3 cp ${pheno_name}.for.qq.plot.gz \
						${S3_TARGET}/output/${genome}/${population}/

				gzip --best --keep ${pheno_name}.for.manhattan.plot
				aws s3 cp ${pheno_name}.for.manhattan.plot.gz \
						${S3_TARGET}/output/${genome}/${population}/

				tar cvf - ${pheno_name}.*.no.covar.log | gzip --best > ${pheno_name}.no.covar.logs.tar.gz
				aws s3 cp ${pheno_name}.no.covar.logs.tar.gz \
					${S3_TARGET}/output/${genome}/${population}/



				manhattan_qq_plot.r \
					-m ${pheno_name}.for.manhattan.plot \
					-q ${pheno_name}.for.qq.plot

#					-q ${pheno_name}.for.qq.plot > ${pheno_name}.for.manhattan.plot.log


				[ -f ${pheno_name}.for.manhattan.plot.png ] &&
					aws s3 cp ${pheno_name}.for.manhattan.plot.png \
						${S3_TARGET}/output/${genome}/${population}/

#				[ -f ${pheno_name}.for.manhattan.plot.log ] &&
#					aws s3 cp ${pheno_name}.for.manhattan.plot.log \
#						${S3_TARGET}/output/${genome}/${population}/





#			done	#	for pheno_name in phenoY.txt ; do

			#
			#	tar cvf - ${pheno_name}.for.plot.all.txt \
			#		${pheno_name}.log \
			#		${pheno_name}.for.qq.plot \
			#		${pheno_name}.for.manhattan.plot \
			#		${pheno_name}.*.no.covar.log | gzip --best > ${pheno_name}.tar.gz
			#
			#	aws s3 cp ${pheno_name}.tar.gz \
			#		${S3}/output/${genome}/${population}/
			#
#			cd ~/
			#/bin/rm -rf $WORK

#		done	#	for genome in unknown ; do

#	done	#	for population in eur amr afr eas sas ; do	#	5

	echo "Ending ..."
	date
} > ${log} 2>&1
#} > ${pheno_name}.log 2>&1

gzip --best ${log}

[ -f ${log}.gz ] &&
	aws s3 cp ${log}.gz ${S3_TARGET}/

