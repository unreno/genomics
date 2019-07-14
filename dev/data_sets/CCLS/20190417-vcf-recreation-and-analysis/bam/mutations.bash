#!/usr/bin/env bash

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables

#	for some reason, zcat | head returns 141 which causes this to stop script. Would like to find alternate method.
#set -o pipefail 

set -x

date=$( date "+%Y%m%d%H%M%S" )
dir="mutations-${date}"
mkdir ${dir}
cd ${dir}
start_dir=${PWD}	#	includes full path

#for version in v2 v3 ; do
for version in v3 ; do
	cd ${start_dir}
	mkdir -p ${version}
	cd ${version}

	ln -s ../../signatures.v3.rda
	ln -s ../../sample_types.csv





#	\rm -f mut_all_sort.tmp
#	zcat ../../983899.somatic/983899.strelka.filtered.REF-ALT2.count_trinuc_muts.txt.gz | head -n 1 > mut_all_sort.txt
#	for sample in 983899 268325 439338 63185 634370 ; do
#		zcat ../../${sample}.somatic/${sample}.strelka.filtered.REF-ALT2.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-strelka-ALT2.txt
#
#	../../Mutation-Signatures-${version}.r
#	mv mutations.pdf mutations-strelka-ALT2.pdf
#	mv mutations.csv mutations-strelka-ALT2.csv
#
#	mkdir mutations-strelka-ALT2
#	cd mutations-strelka-ALT2
#	pdftk ../mutations-strelka-ALT2.pdf burst
#	for pdf in *pdf ; do
#		png=$( basename $pdf .pdf )
#		gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..





#	\rm -f mut_all_sort.tmp
#	zcat ../../983899.somatic/983899.strelka.filtered.count_trinuc_muts.txt.gz | head -n 1 > mut_all_sort.txt
#	for sample in 983899 268325 439338 63185 634370 ; do
#		zcat ../../${sample}.somatic/${sample}.strelka.filtered.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-strelka.txt
#
#	../../Mutation-Signatures-${version}.r
#	mv mutations.pdf mutations-strelka.pdf
#	mv mutations.csv mutations-strelka.csv
#
#	mkdir mutations-strelka
#	cd mutations-strelka
#	pdftk ../mutations-strelka.pdf burst
#	for pdf in *pdf ; do
#	png=$( basename $pdf .pdf )
#	gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..





#	\rm -f mut_all_sort.tmp
#	zcat ../../983899.somatic/983899.mutect.filtered.tumor.snps.passed.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
#	for sample in 983899 268325 439338 63185 634370 ; do
#		zcat ../../${sample}.somatic/${sample}.mutect.filtered.tumor.snps.passed.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-mutect.txt
#
#	../../Mutation-Signatures-${version}.r
#	mv mutations.pdf mutations-mutect.pdf
#	mv mutations.csv mutations-mutect.csv
#
#	mkdir mutations-mutect
#	cd mutations-mutect
#	pdftk ../mutations-mutect.pdf burst
#	for pdf in *pdf ; do
#		png=$( basename $pdf .pdf )
#		gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..





	for minAF in 0.10 0.20 0.30 ; do
	for maxAF in 0.40 0.45 ; do
	for gAF in 0.0001 0.001 0.01 ; do

		core=recaled.mpileup.MQ60.call.SNP.DP20-200.gnomad.gAF0-${gAF}.Bias

		\rm -f mut_all_sort.tmp

		ls -l ../../983899.somatic/983899.${core}.AF${minAF}-${maxAF}.count_trinuc_muts.txt.gz

		zcat ../../983899.somatic/983899.${core}.AF${minAF}-${maxAF}.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
	#	for sample in GM_983899 GM_268325 GM_439338 GM_63185 GM_634370 983899 268325 439338 63185 634370 ; do
		for sample in 983899 268325 439338 63185 634370 120207 122997 186069 201771 209605 266836 321666 341203 36077 492023 495910 506458 530196 607654 673944 73753 780690 811386 813891 833536 853767 866648 868614 871719 900420 919207 972727 99776 ; do
			zcat ../../*.somatic/${sample}.${core}.AF${minAF}-${maxAF}.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
		done
		sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
		\rm mut_all_sort.tmp
		cp mut_all_sort.txt mut_all_sort-manual-${gAF}-${minAF}-${maxAF}.txt

		../../Mutation-Signatures-${version}.r
		mv mutations.pdf mutations-manual-${gAF}-${minAF}-${maxAF}.pdf
		mv mutations.csv mutations-manual-${gAF}-${minAF}-${maxAF}.csv

		mkdir mutations-manual-${gAF}-${minAF}-${maxAF}
		cd mutations-manual-${gAF}-${minAF}-${maxAF}
		pdftk ../mutations-manual-${gAF}-${minAF}-${maxAF}.pdf burst
		for pdf in *pdf ; do
			png=$( basename $pdf .pdf )
			gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
		done
		\rm pg_*pdf
		cd ..

	done	#	gAF
	done	#	maxAF
	done	#	minAF





#	for AF in 0.20 0.25 0.30 0.35 0.40 0.45 ; do
#
#		\rm -f mut_all_sort.tmp
#		zcat ../../983899.somatic/983899.recaled.mpileup*.AF0.04-${AF}.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
#		for sample in GM_983899 GM_268325 GM_439338 GM_63185 GM_634370 983899 268325 439338 63185 634370 ; do
#			zcat ../../*.somatic/${sample}.recaled.mpileup*.AF0.04-${AF}.count_trinuc_muts.txt.gz | tail -n +2 >> mut_all_sort.tmp
#		done
#		sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#		\rm mut_all_sort.tmp
#		cp mut_all_sort.txt mut_all_sort-manual-0.04-${AF}.txt
#
#		../../Mutation-Signatures-${version}.r
#		mv mutations.pdf mutations-manual-0.04-${AF}.pdf
#		mv mutations.csv mutations-manual-0.04-${AF}.csv
#
#		mkdir mutations-manual-0.04-${AF}
#		cd mutations-manual-0.04-${AF}
#		pdftk ../mutations-manual-0.04-${AF}.pdf burst
#		for pdf in *pdf ; do
#			png=$( basename $pdf .pdf )
#			gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#		done
#		\rm pg_*pdf
#		cd ..
#
#	done





#	\rm -f mut_all_sort.tmp
#	zcat ../../983899.somatic/983899.strelka.filtered.count_trinuc_muts.txt.gz | head -n 1 > mut_all_sort.txt
#	for sample in 983899 268325 439338 63185 634370 ; do
#		zcat ../../${sample}.somatic/${sample}.strelka.filtered.count_trinuc_muts.txt.gz | tail -n +2 | grep "^X" >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-strelka-X.txt
#
#	../../Mutation-Signatures-${version}.r
#	mv mutations.pdf mutations-strelka-X.pdf
#	mv mutations.csv mutations-strelka-X.csv
#
#	mkdir mutations-strelka-X
#	cd mutations-strelka-X
#	pdftk ../mutations-strelka-X.pdf burst
#	for pdf in *pdf ; do
#		png=$( basename $pdf .pdf )
#		gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..




#	\rm -f mut_all_sort.tmp
#	zcat ../../983899.somatic/983899.strelka.filtered.count_trinuc_muts.txt.gz | head -n 1 > mut_all_sort.txt
#	for sample in 983899 268325 439338 63185 634370 ; do
#		zcat ../../${sample}.somatic/${sample}.strelka.filtered.count_trinuc_muts.txt.gz | tail -n +2 | grep -vs "^X" >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-strelka-notX.txt
#
#	../../Mutation-Signatures-${version}.r
#	mv mutations.pdf mutations-strelka-notX.pdf
#	mv mutations.csv mutations-strelka-notX.csv
#
#	mkdir mutations-strelka-notX
#	cd mutations-strelka-notX
#	pdftk ../mutations-strelka-notX.pdf burst
#	for pdf in *pdf ; do
#		png=$( basename $pdf .pdf )
#		gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..





#	\rm -f mut_all_sort.tmp
#	zcat ../../983899.somatic/983899.mutect.filtered.tumor.snps.passed.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
#	for sample in 983899 268325 439338 63185 634370 ; do
#		zcat ../../${sample}.somatic/${sample}.mutect.filtered.tumor.snps.passed.count_trinuc_muts.txt.gz | tail -n +2 | grep "^X" >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-mutect-X.txt
#
#	../../Mutation-Signatures-${version}.r
#	mv mutations.pdf mutations-mutect-X.pdf
#	mv mutations.csv mutations-mutect-X.csv
#
#	mkdir mutations-mutect-X
#	cd mutations-mutect-X
#	pdftk ../mutations-mutect-X.pdf burst
#	for pdf in *pdf ; do
#		png=$( basename $pdf .pdf )
#		gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..



#	\rm -f mut_all_sort.tmp
#	zcat ../../983899.somatic/983899.mutect.filtered.tumor.snps.passed.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
#	for sample in 983899 268325 439338 63185 634370 ; do
#		zcat ../../${sample}.somatic/${sample}.mutect.filtered.tumor.snps.passed.count_trinuc_muts.txt.gz | tail -n +2 | grep -vs "^X" >> mut_all_sort.tmp
#	done
#	sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#	\rm mut_all_sort.tmp
#	cp mut_all_sort.txt mut_all_sort-mutect-notX.txt
#
#	../../Mutation-Signatures-${version}.r
#	mv mutations.pdf mutations-mutect-notX.pdf
#	mv mutations.csv mutations-mutect-notX.csv
#
#	mkdir mutations-mutect-notX
#	cd mutations-mutect-notX
#	pdftk ../mutations-mutect-notX.pdf burst
#	for pdf in *pdf ; do
#		png=$( basename $pdf .pdf )
#		gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#	done
#	\rm pg_*pdf
#	cd ..




#	for AF in 0.20 0.25 0.30 0.35 0.40 0.45 ; do
#
#		\rm -f mut_all_sort.tmp
#		zcat ../../983899.somatic/983899.recaled.mpileup*.0.04-${AF}.count_trinuc_muts.txt.gz | head -1 > mut_all_sort.txt
#		for sample in GM_983899 GM_268325 GM_439338 GM_63185 GM_634370 983899 268325 439338 63185 634370 ; do
#			zcat ../../*.somatic/${sample}.recaled.mpileup*.0.04-${AF}.count_trinuc_muts.txt.gz | tail -n +2 | grep "^X" >> mut_all_sort.tmp
#		done
#		sort -k1,1 -k2,2n mut_all_sort.tmp >> mut_all_sort.txt
#		\rm mut_all_sort.tmp
#		cp mut_all_sort.txt mut_all_sort-manual-0.04-${AF}-X.txt
#
#		../../Mutation-Signatures-${version}.r
#		mv mutations.pdf mutations-manual-0.04-${AF}-X.pdf
#		mv mutations.csv mutations-manual-0.04-${AF}-X.csv
#
#		mkdir mutations-manual-0.04-${AF}-X
#		cd mutations-manual-0.04-${AF}-X
#		pdftk ../mutations-manual-0.04-${AF}-X.pdf burst
#		for pdf in *pdf ; do
#			png=$( basename $pdf .pdf )
#			gs -sDEVICE=png16m -dTextAlphaBits=4 -r300 -o ${png}.png ${pdf}
#		done
#		\rm pg_*pdf
#		cd ..
#
#	done

done
