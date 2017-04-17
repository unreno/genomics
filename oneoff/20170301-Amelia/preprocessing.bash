#!/usr/bin/env bash

#	I have two VCF files - one from the CCLS and one from the 1000 genomes chr22. I need to trim each file so that:
#
#	They only contain biallelic SNPs
#	There are no duplicated names or positions
#	There are no missing ALT or REF alleles (fields 4 and 5)
#	and All variants present in one file are also present in the other
#		(i.e. they contain the exact same variants)
#
#	One complication that is preventing me from using existing software is that they have different SNP names, so all matching has to be done on position.
#


#####Remove non-biallellic and duplicates using Bash from reference
#bialleleic

#awk '($4 =="A" || $4 =="T" || $4 =="C" || $4 =="G") && ($5 =="A" || $5 =="T" || $5 =="C" || $5 =="G") {print $2}' ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > 1kg.biallelic.positions.keep.txt

#	In awk, "in hash" can be used to compare a value to the keys in said hash.
#	So, in the following v is a hash, A, T, C and G are the keys, which need to be assigned a value
#	This can then be used in a condition like ( $4 in v ).
#	Of course, we could be more verbose and call "v" "values",
#		but that's just too many extra keystrokes.
#	Not sure if its faster or even cleaner, but it is a bit shorter.
#	Yay code golf.

awk 'BEGIN{ v["A"]=v["T"]=v["C"]=v["G"]=0; }
(($4 in v) && ($5 in v)){ print $2 }' ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > 1kg.biallelic.positions.keep.txt

#fgrep -w -f 1kg.biallelic.positions.keep.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > 1kg.chr22.nobi.vcf

awk '(NR==FNR){ values[$1]=0 }( (NR!=FNR) && ( $2 in values ) ){ print }' 1kg.biallelic.positions.keep.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > 1kg.chr22.nobi.vcf


#	Changed "#" to "^#". Using an anchor like this can speed things up.

#keep header
grep "^#" ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > 1kg.vcf.header.txt

#duplicates
cut -f2 1kg.chr22.nobi.vcf | uniq -c > temp.to.cut
awk '$1 ==1 {print $2}' temp.to.cut > 1kg.dup.ids

#	fgrep is just way too slow, at least for me.
#fgrep -w -v -f 1kg.dup.ids 1kg.chr22.nobi.vcf > 1kg.chr22.nobi.nodup.vcf

awk '(NR==FNR){ values[$1]=0 }( (NR!=FNR) && !( $2 in values ) ){ print }' 1kg.dup.ids 1kg.chr22.nobi.vcf > 1kg.chr22.nobi.nodup.vcf








#######

awk 'BEGIN{ v["A"]=v["T"]=v["C"]=v["G"]=0; }
(($4 in v) && ($5 in v)){ print $2 }' ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > 1kg.biallelic.positions.keep.txt

awk '(NR==FNR){ values[$1]=0 }
( (NR!=FNR) && ( $2 in values ) ){ print $2 }' 1kg.biallelic.positions.keep.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf | sort | uniq -u > 1kg.biallelic.positions.keep.nodups.txt

awk '(NR==FNR){ values[$1]=0 }
( /^#/ ){ print; next }
( (NR!=FNR) && ( $2 in values ) ){ print }' 1kg.biallelic.positions.keep.nodups.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > 1kg.chr22.nobi.nodup.vcf




#awk '(NR==FNR){ values[$1]=0 }
#( /^#/ ){ print; next }
#( (NR!=FNR) && ( $2 in values ) ){ print }' ALL.positions.keep.nodups.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > ALL.nodup.vcf
#
#awk '(NR==FNR){ values[$1]=0 }
#( /^#/ ){ print; next }
#( (NR!=FNR) && ( $2 in values ) ){ print }' apobec.positions.keep.nodups.txt apobec.region.no.del.imputed.plink.vcf > apobec.nodup.vcf





awk 'BEGIN{ v["A"]=v["T"]=v["C"]=v["G"]=0; }
(($4 in v) && ($5 in v)){ print $2 }' ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > ALL.positions.keep.txt

awk '(NR==FNR){ values[$1]=0 }
( (NR!=FNR) && ( $2 in values ) ){ print $2 }' ALL.positions.keep.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf | sort | uniq -u > ALL.positions.keep.nodups.txt


awk 'BEGIN{ v["A"]=v["T"]=v["C"]=v["G"]=0; }
(($4 in v) && ($5 in v)){ print $2 }' apobec.region.no.del.imputed.plink.vcf > apobec.positions.keep.txt

awk '(NR==FNR){ values[$1]=0 }
( (NR!=FNR) && ( $2 in values ) ){ print $2 }' apobec.positions.keep.txt apobec.region.no.del.imputed.plink.vcf | sort | uniq -u > apobec.positions.keep.nodups.txt



cat ALL.positions.keep.nodups.txt apobec.positions.keep.nodups.txt | sort | uniq -d > positions.keep.nodups.both.txt


awk '(NR==FNR){ values[$1]=0 }
( /^#/ ){ print; next }
( (NR!=FNR) && ( $2 in values ) ){ print }' positions.keep.nodups.both.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > ALL.nodup.both.vcf

awk '(NR==FNR){ values[$1]=0 }
( /^#/ ){ print; next }
( (NR!=FNR) && ( $2 in values ) ){ print }' positions.keep.nodups.both.txt apobec.region.no.del.imputed.plink.vcf > apobec.nodup.both.vcf

