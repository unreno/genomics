#!/usr/bin/env bash

REFS=~/20180126.plink_testing/
population=eur	#eas	#	amr
pheno_name=phenoY

log=$(basename $0).log

{

	for bedfile in $( ls ${REFS}/pops/${population}/ALL.chr*.bed ) ; do

		bedfile_noext=${bedfile%.*} # drop the shortest suffix match to ".*" (the .bed extension)
		bedfile_core=${bedfile_noext##*/}	#	drop the longest prefix match to "*/" (the path)

		plink --snps-only \
				--allow-no-sex \
				--linear standard-beta hide-covar \
				--bfile ${bedfile_noext} \
				--pheno ${REFS}/${pheno_name} \
				--out ${bedfile_core}.no.covar \
				--covar-name C1,C2,C3,C4,C5,C6 \
				--covar ${REFS}/1kg_all_chroms_pruned_mds.mds
#				--out ${bedfile_core}.no.covar

		#	 CHR         SNP         BP   A1       TEST    NMISS       BETA         STAT            P 
		awk '{print $1,$2,$3,$9,$4,$7}' ${bedfile_core}.no.covar.assoc.linear > ${bedfile_core}.for.plot.txt

		mv ${bedfile_core}.no.covar.log ${pheno_name}.${bedfile_core}.no.covar.log

rm ${bedfile_core}.no.covar.assoc.linear
rm ${bedfile_core}.no.covar.nosex

	done	#	for bedfile

	tail --silent --lines +2 *.for.plot.txt > ${pheno_name}.for.plot.all.txt

	grep --invert-match "NA" ${pheno_name}.for.plot.all.txt | shuf -n 200000 > ${pheno_name}.for.qq.plot

	grep "NA" ${pheno_name}.for.plot.all.txt > ${pheno_name}.NA.txt

	awk '$4 < 0.10' ${pheno_name}.for.plot.all.txt > ${pheno_name}.for.manhattan.plot

	manhattan_qq_plot.r \
		-m ${pheno_name}.for.manhattan.plot \
		-q ${pheno_name}.for.qq.plot

} > ${log} 2>&1
