#!/usr/bin/env bash

function usage(){
	echo
	echo "Usage:"
	echo
	echo "`basename $0` population pheno_name chromosome"
	echo
	echo "Example:"
	echo "  `basename $0` eur chr17_ctg5_hap1_504028_F_PRE Y"
	echo
	exit 1
}
[ $# -ne 3 ] && usage

BASE=~/snpprocessing
REFS=$BASE/references
WORK=$BASE/working

#	It would be nice to avoid repeated copying, but that would take up much space.
#	So, start fresh every go
/bin/rm -rf $BASE

mkdir -p $REFS

[ -f $REFS/1kg_all_chroms_pruned_mds.mds ] ||
	aws s3 cp s3://herv/snp-20160620/1kg_all_chroms_pruned_mds.mds $REFS/
#	cp ~/plinking/test/input/1kg_all_chroms_pruned_mds.mds $REFS

#/bin/rm -rf $WORK
mkdir -p $WORK
cd $WORK

population=$1
pheno_name=$2
chromosome=$3

mkdir -p $REFS/pheno_files/${population}
[ -f $REFS/pheno_files/${population}/${pheno_name} ] ||
	aws s3 cp s3://herv/snp-20160620/pheno_files/${population}/${pheno_name} \
		$REFS/pheno_files/${population}/
#	cp ~/plinking/test/input/pheno_files/$population/$pheno_name \
#		$REFS/pheno_files/$population/


mkdir -p $REFS/pruned_vcfs/${population}
#	S3 and wildcards are challenging. Copy a dir, exclude everything, include only what you want.
#	Not elegant, but effective
#	--exclude "*" --include "*.log"
#	aws s3 cp s3://herv/snp-20160620/pruned_vcfs/$population/ --recursive --exclude "*" --include "ALL.chr${chromosome}.*.tar.gz" ./
[ -f $REFS/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed ] ||
	aws s3 cp s3://herv/snp-20160620/pruned_vcfs/$population/ALL.chr${chromosome}.tar.gz \
		$REFS/pruned_vcfs/${population}/
#		$REFS/pruned_vcfs/${population}/ --recursive \
#		--exclude "*" --include "ALL.chr${chromosome}.*.tar.gz"
#	cp ~/plinking/test/input/pruned_vcfs/${population}/ALL.chr${chromosome}.*.gz \
#		$REFS/pruned_vcfs/${population}/

#	untar/gunzip bed,bim,fam files
[ -f $REFS/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed ] ||
	tar -xvzC $REFS/pruned_vcfs/${population}/ \
		-f $REFS/pruned_vcfs/${population}/ALL.chr${chromosome}.*.gz

bedfile=`ls $REFS/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed`
bfile=${bedfile%.*} # drop the shortest suffix match to ".*" (the .bed extension)
bfile_base=${bedfile##*/}	#	drop the longest prefix match to "*/" (the path)
out_base_path="${bfile_base}.${population}"
	
plink --snps-only \
		--threads 8 \
		--allow-no-sex \
		--logistic hide-covar \
		--covar-name C1,C2,C3,C4,C5,C6 \
		--bfile ${bfile} \
		--pheno $REFS/pheno_files/${population}/${pheno_name} \
		--out ${out_base_path}.no.covar \
		--covar $REFS/1kg_all_chroms_pruned_mds.mds

#awk -F" " '{print $1,$2,$3,$9,$4,$7}' ${out_base_path}.no.covar.assoc.logistic > ${out_base_path}.for.plot.txt
#	space is default separator
awk '{print $1,$2,$3,$9,$4,$7}' ${out_base_path}.no.covar.assoc.logistic > ${out_base_path}.for.plot.txt

gzip --best ${out_base_path}.no.covar.log
aws s3 cp ${out_base_path}.no.covar.log.gz \
	s3://herv/snp-20160620/output/${population}/${pheno_name}/

gzip --best ${out_base_path}.for.plot.txt
aws s3 cp ${out_base_path}.for.plot.txt.gz \
	s3://herv/snp-20160620/output/${population}/${pheno_name}/

#	copy out plot.txt file to s3?

#	tar gzip plot.txt
#	aws s3 cp plot.txt s3://herv/snp-20160620/output/${population}/${pheno_name}/${bfile}

cd ~/
/bin/rm -rf $BASE

