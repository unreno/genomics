#!/usr/bin/env bash

#set -v
set -x

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
WORK=$BASE/working
S3=s3://herv/snp-20160701

/bin/rm -rf $WORK

mkdir -p $WORK
cd $WORK

#	Begin logging
{
	echo "Starting ..."
	date

	aws s3 cp ${S3}/output/${genome}/${population}/${pheno_name}.for.manhattan.plot.gz ./
	gunzip ${pheno_name}.for.manhattan.plot.gz

	aws s3 cp ${S3}/output/${genome}/${population}/${pheno_name}.for.qq.plot.gz ./
	gunzip ${pheno_name}.for.qq.plot.gz

	manhattan_qq_plot.r -m ${pheno_name}.for.manhattan.plot -q ${pheno_name}.for.qq.plot 

	[ -f ${pheno_name}.for.manhattan.plot.png ] &&
		aws s3 cp ${pheno_name}.for.manhattan.plot.png \
			${S3}/output/${genome}/${population}/

	echo "Ending ..."
	date
} > ${pheno_name}.for.manhattan.plot.log 2>&1

aws s3 cp ${pheno_name}.for.manhattan.plot.log \
	${S3}/output/${genome}/${population}/

cd ~/
#/bin/rm -rf $WORK

