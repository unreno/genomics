#!/usr/bin/env bash

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables

#	for some reason, zcat | head returns 141 which causes this to stop script
#set -o pipefail 

set -x

mkdir -p mutations_v3
cd mutations_v3


ln -s ../signatures.v3.rda
ln -s ../sample_types.csv

\rm -f mut_all_sort.tmp
zcat ../983899.somatic/983899.strelka.filtered.count_trinuc_muts.txt.gz | head -n 1 > mut_all_sort.txt
for sample in 983899 268325 439338 63185 634370 ; do
	zcat ../${sample}.somatic/${sample}.strelka.filtered.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
done
sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
\rm mut_all_sort.tmp
cp mut_all_sort.txt mut_all_sort-strelka.txt

../Mutation-Signatures.r
mv mutations.pdf mutations-strelka.pdf
mv mutations.csv mutations-strelka.csv

mkdir mutations-strelka
cd mutations-strelka
pdftk ../mutations-strelka.pdf burst
for pdf in *pdf ; do
png=$( basename $pdf .pdf )
gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
done
\rm pg_*pdf
cd ..




\rm -f mut_all_sort.tmp
zcat ../983899.somatic/983899.mutect.filtered.snps.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
for sample in 983899 268325 439338 63185 634370 ; do
zcat ../${sample}.somatic/${sample}.mutect.filtered.snps.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
done
sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
\rm mut_all_sort.tmp
cp mut_all_sort.txt mut_all_sort-mutect.txt

../Mutation-Signatures.r
mv mutations.pdf mutations-mutect.pdf
mv mutations.csv mutations-mutect.csv

mkdir mutations-mutect
cd mutations-mutect
pdftk ../mutations-mutect.pdf burst
for pdf in *pdf ; do
png=$( basename $pdf .pdf )
gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
done
\rm pg_*pdf
cd ..


#	\rm -f mut_all_sort.tmp
#	zcat ../983899.somatic/983899.recaled.mpileup*.GNOMAD_AF.Bias.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
#	for sample in GM_983899 GM_268325 GM_439338 GM_63185 GM_634370 983899 268325 439338 63185 634370 120207 122997 186069 201771 209605 266836 321666 341203 36077 492023 495910 506458 530196 607654 673944 73753 780690 811386 813891 833536 853767 866648 868614 871719 900420 919207 972727 99776 ; do
#	zcat ../*.somatic/${sample}.recaled.mpileup*GNOMAD_AF.Bias.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-Bias.txt
#	
#	../Mutation-Signatures.r
#	mv mutations.pdf mutations-Bias.pdf
#	mv mutations.csv mutations-Bias.csv
#	
#	mkdir mutations-Bias
#	cd mutations-Bias
#	pdftk ../mutations-Bias.pdf burst
#	for pdf in *pdf ; do
#	png=$( basename $pdf .pdf )
#	gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..



for AF in 0.20 0.25 0.30 0.35 0.40 0.45 ; do

	\rm -f mut_all_sort.tmp
	zcat ../983899.somatic/983899.recaled.mpileup*.${AF}.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
	for sample in GM_983899 GM_268325 GM_439338 GM_63185 GM_634370 983899 268325 439338 63185 634370 120207 122997 186069 201771 209605 266836 321666 341203 36077 492023 495910 506458 530196 607654 673944 73753 780690 811386 813891 833536 853767 866648 868614 871719 900420 919207 972727 99776 ; do
	zcat ../*.somatic/${sample}.recaled.mpileup*.${AF}.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
	done
	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
	\rm mut_all_sort.tmp
	cp mut_all_sort.txt mut_all_sort-manual-${AF}.txt

	../Mutation-Signatures.r
	mv mutations.pdf mutations-manual-${AF}.pdf
	mv mutations.csv mutations-manual-${AF}.csv

	mkdir mutations-manual-${AF}
	cd mutations-manual-${AF}
	pdftk ../mutations-manual-${AF}.pdf burst
	for pdf in *pdf ; do
	png=$( basename $pdf .pdf )
	gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
	done
	\rm pg_*pdf
	cd ..

done

