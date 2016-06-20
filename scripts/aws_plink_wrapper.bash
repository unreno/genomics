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

mkdir -p ~/references/

[ -f ~/references/1kg_all_chroms_pruned_mds.mds ] ||
	aws s3 cp s3://herv/snp-20160620/1kg_all_chroms_pruned_mds.mds \
		~/references/
#	cp ~/plinking/test/input/1kg_all_chroms_pruned_mds.mds \
#		~/references/

#/bin/rm -rf ~/working/
mkdir -p ~/working/
cd ~/working/

population=$1
pheno_name=$2
chromosome=$3

mkdir -p ~/references/pheno_files/${population}
[ -f ~/references/pheno_files/${population}/${pheno_name} ] ||
	aws s3 cp s3://herv/snp-20160620/pheno_files/${population}/${pheno_name} \
		~/references/pheno_files/${population}/
#	cp ~/plinking/test/input/pheno_files/$population/$pheno_name \
#		~/references/pheno_files/$population/


mkdir -p ~/references/pruned_vcfs/${population}
#	S3 and wildcards are challenging. Copy a dir, exclude everything, include only what you want.
#	Not elegant, but effective
#	--exclude "*" --include "*.log"
#	aws s3 cp s3://herv/snp-20160620/pruned_vcfs/$population/ --recursive --exclude "*" --include "ALL.chr${chromosome}.*.tar.gz" ./
[ -f ~/references/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed ] ||
	aws s3 cp s3://herv/snp-20160620/pruned_vcfs/$population/ALL.chr${chromosome}.tar.gz \
		~/references/pruned_vcfs/${population}/
#		~/references/pruned_vcfs/${population}/ --recursive \
#		--exclude "*" --include "ALL.chr${chromosome}.*.tar.gz"
#	cp ~/plinking/test/input/pruned_vcfs/${population}/ALL.chr${chromosome}.*.gz \
#		~/references/pruned_vcfs/${population}/

#	untar/gunzip bed,bim,fam files
[ -f ~/references/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed ] ||
	tar -xvzC ~/references/pruned_vcfs/${population}/ \
		-f ~/references/pruned_vcfs/${population}/ALL.chr${chromosome}.*.gz

bedfile=`ls ~/references/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed`
bfile=${bedfile%.*} # drop the shortest suffix match to ".*" (the .bed extension)
bfile_base=${bedfile##*/}	#	drop the longest prefix match to "*/" (the path)
out_base_path="${bfile_base}.${population}"
	
plink --snps-only \
		--threads 8 \
		--allow-no-sex \
		--logistic hide-covar \
		--covar-name C1,C2,C3,C4,C5,C6 \
		--bfile ${bfile} \
		--pheno ~/references/pheno_files/${population}/${pheno_name} \
		--out ${out_base_path}.no.covar \
		--covar ~/references/1kg_all_chroms_pruned_mds.mds

#awk -F" " '{print $1,$2,$3,$9,$4,$7}' ${out_base_path}.no.covar.assoc.logistic > ${out_base_path}.for.plot.txt
#	space is default separator
awk '{print $1,$2,$3,$9,$4,$7}' ${out_base_path}.no.covar.assoc.logistic > ${out_base_path}.for.plot.txt

gzip --best ${out_base_path}.for.plot.txt

aws s3 cp ${out_base_path}.for.plot.txt.gz \
	s3://herv/snp-20160620/output/${population}/${pheno_name}/
#${out_base_path}.for.plot.txt.gz

#	copy out plot.txt file to s3?

#	tar gzip plot.txt
#	aws s3 cp plot.txt s3://herv/snp-20160620/output/${population}/${pheno_name}/${bfile}

#cd ~/
#/bin/rm -rf ~/working/

