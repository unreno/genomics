#!/usr/bin/env bash

set -v

function usage(){
	echo
	echo "Usage:"
	echo
	echo "`basename $0` [--genome hg19_alt] [--population population] [--pheno pheno_name]"
	echo
	echo "Default:"
	echo "  genome ...... ${genome}"
	echo "  population .. ${population}"
	echo
	echo "`basename $0` --genome hg19_alt --population eur --pheno chr17_ctg5_hap1_504028_F_PRE" 
	echo
	exit 1
}

genome="hg19_alt"
population="eur"

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

[ -z ${pheno_name} ] && usage
[ $# -ne 0 ] && usage


BASE=~/snpprocessing
REFS=$BASE/references
WORK=$BASE/working
S3=s3://herv/snp-20160701

#/bin/rm -rf $WORK

mkdir -p $REFS
mkdir -p $WORK
cd $WORK

#	Begin logging
{
	echo "Starting"
	date

	[ -f ${REFS}/1kg_all_chroms_pruned_mds.mds ] ||
		aws s3 cp ${S3}/1kg_all_chroms_pruned_mds.mds ${REFS}/

	#	The pheno files are small, but once run, no need to keep them.
	/bin/rm -rf ${REFS}/pheno_files/

	mkdir -p ${REFS}/pheno_files/${genome}/${population}

	[ -f ${REFS}/pheno_files/${genome}/${population}/${pheno_name} ] ||
		aws s3 cp ${S3}/pheno_files/${genome}/${population}/${pheno_name} \
			${REFS}/pheno_files/${genome}/${population}/


	#	Pruned vcfs are large. Delete entire tree if current population doesn't exist?
	#	This way, if population is same as previous run, already got it.
	[ -d ${REFS}/pruned_vcfs/${population} ] ||
		rm -rf ${REFS}/pruned_vcfs/

	mkdir -p ${REFS}/pruned_vcfs/

	[ -d ${REFS}/pruned_vcfs/${population} ] ||
		aws s3 cp ${S3}/pruned_vcfs/${population}.tar.gz \
			${REFS}/pruned_vcfs/

	[ -f ${REFS}/pruned_vcfs/${population}.tar.gz ] &&
		tar -xvzC ${REFS}/pruned_vcfs/ \
			-f ${REFS}/pruned_vcfs/${population}.tar.gz

	[ -f ${REFS}/pruned_vcfs/${population}.tar.gz ] &&
		rm -f ${REFS}/pruned_vcfs/${population}.tar.gz

	for bedfile in `ls ${REFS}/pruned_vcfs/${population}/ALL.chr*.bed` ; do

		bedfile_noext=${bedfile%.*} # drop the shortest suffix match to ".*" (the .bed extension)
		bedfile_core=${bedfile_noext##*/}	#	drop the longest prefix match to "*/" (the path)

		plink --snps-only \
				--threads 8 \
				--allow-no-sex \
				--logistic hide-covar \
				--covar-name C1,C2,C3,C4,C5,C6 \
				--bfile ${bedfile_noext} \
				--pheno ${REFS}/pheno_files/${genome}/${population}/${pheno_name} \
				--out ${bedfile_core}.no.covar \
				--covar ${REFS}/1kg_all_chroms_pruned_mds.mds

		awk '{print $1,$2,$3,$9,$4,$7}' ${bedfile_core}.no.covar.assoc.logistic > ${bedfile_core}.for.plot.txt

		mv ${bedfile_core}.no.covar.log ${pheno_name}.${bedfile_core}.no.covar.log

		#	Try to manage disk space as could be tight.
		rm ${bedfile_core}.no.covar.assoc.logistic

	done

	echo "CHR SNP BP P A1 OR" > ${pheno_name}.for.plot.all.txt
	grep -v "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt

	#grep -v "NA" ${pheno_name}.for.plot.all.txt | shuf -n 200000 > ${pheno_name}.for.qq.plot
	tail -n +2 ${pheno_name}.for.plot.all.txt | grep -v "NA" | shuf -n 200000 > ${pheno_name}.for.qq.plot

	awk '$4 < 0.10' ${pheno_name}.for.plot.all.txt > ${pheno_name}.for.manhattan.plot

	df -h .

	echo "Ending"
	date
} > ${pheno_name}.log 2>&1

tar cvf - ${pheno_name}.for.plot.all.txt \
	${pheno_name}.log \
	${pheno_name}.for.qq.plot \
	${pheno_name}.for.manhattan.plot \
	${pheno_name}.*.no.covar.log | gzip --best > ${pheno_name}.tar.gz

aws s3 cp ${pheno_name}.tar.gz \
	${S3}/output/${genome}/${population}/

cd ~/
#/bin/rm -rf $WORK

