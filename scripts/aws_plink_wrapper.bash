#!/usr/bin/env bash

function usage(){
	echo
	echo "Usage:"
	echo
	echo "`basename $0` [--index hg19_alt] [--population population] [--pheno pheno_name]"
	echo
	echo "Default:"
	echo "  index ....... hg19_alt"
	echo "  population .. eur"
	echo
#	echo "  `basename $0` eur chr17_ctg5_hap1_504028_F_PRE Y"
	echo
	exit 1
}

index="hg19_alt"
population="eur"

while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		-i*|--i*)
			shift; index=$1; shift ;;
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

[ $# -ne 0 ] && usage




exit




BASE=~/snpprocessing
REFS=$BASE/references
WORK=$BASE/working

#	It would be nice to avoid repeated copying, but that would take up much space.
#	So, start fresh every go
#/bin/rm -rf $BASE
/bin/rm -rf $WORK

mkdir -p $REFS

[ -f $REFS/1kg_all_chroms_pruned_mds.mds ] ||
	aws s3 cp s3://herv/snp-20160701/1kg_all_chroms_pruned_mds.mds $REFS/

#/bin/rm -rf $WORK
mkdir -p $WORK
cd $WORK

mkdir -p $REFS/pheno_files/${population}
[ -f $REFS/pheno_files/${population}/${pheno_name} ] ||
	aws s3 cp s3://herv/snp-20160701/pheno_files/${population}/${pheno_name} \
		$REFS/pheno_files/${population}/

mkdir -p $REFS/pruned_vcfs/${population}
[ -f $REFS/pruned_vcfs/${population}/ALL.chrX.*bed ] ||
	aws s3 cp s3://herv/snp-20160701/pruned_vcfs/$population/ \
		$REFS/pruned_vcfs/${population}/ --recursive \
		--exclude "*" --include "ALL.chr${chromosome}.*.tar.gz"




#	untar/gunzip bed,bim,fam files
#[ -f $REFS/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed ] ||
[ -f $REFS/pruned_vcfs/${population}/ALL.chrX.*bed ] ||
	tar -xvzC $REFS/pruned_vcfs/${population}/ \
		-f $REFS/pruned_vcfs/${population}/ALL.chr${chromosome}.*.gz



for bedfile in `ls $REFS/pruned_vcfs/${population}/ALL.chr${chromosome}.*bed` ; do

	bfile=${bedfile%.*} # drop the shortest suffix match to ".*" (the .bed extension)
	bfile_base=${bedfile##*/}	#	drop the longest prefix match to "*/" (the path)
	out_base_path="${bfile_base}.${population}"	#	this is just a core name (no path)
	#	ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.eur.pruned.bed.eur

	plink --snps-only \
			--threads 8 \
			--allow-no-sex \
			--logistic hide-covar \
			--covar-name C1,C2,C3,C4,C5,C6 \
			--bfile ${bfile} \
			--pheno $REFS/pheno_files/${population}/${pheno_name} \
			--out ${out_base_path}.no.covar \
			--covar $REFS/1kg_all_chroms_pruned_mds.mds

	awk '{print $1,$2,$3,$9,$4,$7}' ${out_base_path}.no.covar.assoc.logistic > ${out_base_path}.for.plot.txt

	#gzip --best ${out_base_path}.no.covar.log
	#aws s3 cp ${out_base_path}.no.covar.log.gz \
	#	s3://herv/snp-20160701/output/${population}/${pheno_name}/

	#gzip --best ${out_base_path}.for.plot.txt
	#aws s3 cp ${out_base_path}.for.plot.txt.gz \
	#	s3://herv/snp-20160701/output/${population}/${pheno_name}/

	#	copy out plot.txt file to s3?

	#	tar gzip plot.txt
	#	aws s3 cp plot.txt s3://herv/snp-20160701/output/${population}/${pheno_name}/${bfile}

done

#	baseN = $pheno_name
#	outfile = output path population/pheno_name/ ( actually blank in my version )

#cat ${outfile}/*.for.plot.txt | grep -v "CHR" > ${outfile}/${baseN}.for.plot.all.eur.txt
#rm ${outfile}/*.for.plot.txt
#echo "CHR SNP BP P A1 OR" > ${outfile}/header.txt
#cat ${outfile}/header.txt ${outfile}/${baseN}.for.plot.all.eur.txt> ${outfile}/temp
#mv ${outfile}/temp ${outfile}/${baseN}.for.plot.all.eur.txt
#rm ${outfile}/header.txt
#

#	file1 = pheno_name with path
#	baseN = $pheno_name
#
#grep -v "NA" $file1/$baseN.for.plot.all.txt > $file1/$baseN.for.plot.all.noNA.txt
#shuf -n 200000 $file1/$baseN.for.plot.all.noNA.txt > $baseN.for.qq.plot
#rm $file1/$baseN.for.plot.all.noNA.txt
#awk '$4 < 0.10' $file1/$baseN.for.plot.all.txt > $baseN.for.manhattan.plot
#
#
#. I suppose it goes without saying that I’d be real happy if you-all can just hand me the .for.plot.all.txt, .for.qq.plot, and .for.manhattan.plot files. plus log file

#	tar cfz - *.for.plot.all.txt *.for.qq.plot *.for.manhattan.plot
#		*.no.covar.log | gzip --best > ${pheno_name}.tar.gz
#aws s3 cp ${pheno_name}.tar.gz \
#	s3://herv/snp-20160701/output/${index}/${population}/

cd ~/
#/bin/rm -rf $BASE
/bin/rm -rf $WORK

