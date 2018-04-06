#!/usr/bin/env bash

index=~/s3/herv/indexes/build37

for vcf in $( find ~/s3/1000genomes/phase3/ -name \*vcf.gz ) ; do
	echo $vcf

#/Users/jakewendt/s3/1000genomes/phase3//data/HG00477/cg_data/HG00477_lcl_SRR826683.wgs.COMPLETE_GENOMICS.20130401.snps_indels_svs_meis.high_coverage.genotypes.vcf.gz


	base=$( basename $vcf )
#	base=${base%%_*}
	base=${base%%.*}
	echo $base

#	for t in 'CT' 'GA'; do
#		from=${t: 0:1}	#	first letter
#		to=${t: -1:1}		#	last letter
#
#		#	collect chromosome and position
#		zcat $vcf | awk -F"\t" '\
#			( !/^#/ && $4 == "'${from}'" && $5 == "'${to}'"){ \
#				print $1"\t"$2
#			}' > ${base}.${o}.${t}.txt
#
#		#	collect chromosome, position and the upcased trinucleotide centered about that position
#		#	using the while(){} loop in awk is to return the last line from samtools faidx
#		zcat $vcf | awk -F"\t" '\
#			( !/^#/ && $4 == "'${from}'" && $5 == "'${to}'"){ \
#				while("samtools faidx '${index}'.fa "$1":"$2-1"-"$2+1" " | getline x ){}; \
#				print $1"\t"$2"\t"toupper(x) \
#			}' > ${base}.${o}.${t}.tri.txt
#
#	done	#	for t


#	My build37 contains >chr1
#	So does the referenced version?
#	ftp://ftp.completegenomics.com/ReferenceFiles/build37.fa.bz2
#	1000genomes vcfs (referenced to build37) contains just the number so add "chr"

	if [ ! -f ${base}.txt ] ; then

		#	This version takes only a few seconds per file
		zcat $vcf | awk -F"\t" '\
			( !/^#/ && ( ( $4 == "C" && $5 == "T" ) || ( $4 == "G" && $5 == "A" ) ) ){ \
				print $1"\t"$2"\t"$4"\t"$5
			}' > ${base}.txt

	fi

	#	There are limits as to the number of open files or pipes.
	#	the samtools call from within awk MUST be explicitly closed otherwise errors like ...
	#		awk: cmd. line:3: (FILENAME=- FNR=289293) fatal: cannot open pipe 
	#			`samtools faidx /Users/jakewendt/s3/herv/indexes/build37.fa chr1:79714090-79714092 ' (Too many open files)
	#	Changed style from ...
	#		while("samtools faidx '${index}'.fa chr"$1":"$2-1"-"$2+1" " | getline x ){}; \
	#	... to ...
	#		samtools = "samtools faidx '${index}'.fa chr"$1":"$2-1"-"$2+1" "
	#		while(samtools | getline x ){}; \
	#		close(samtools);

#	if [ ! -f ${base}.tri.txt ] ; then

		#samtools faidx /Users/jakewendt/s3/herv/indexes/build37.fa chr1:79714090-79714092

#			mkdir -p faidx
##			for transition in $( cat ${base}.txt ) ; do #	 no
#				c=${transition%%	*}
#				p=${transition#*	}
#				p=${p%%	*}
#				if [ ! -f "${c}:${p}" ] ; then
#				#samtools faidx /Users/jakewendt/s3/herv/indexes/build37.fa chr1:79714090-79714092 > asdfasf
#				fi
#			done

#awk -F\| 'system("test -f " $2)==0 { print $2 }'





#		#	This version takes a few hours per file ( about 0.05 sec per position )
#		zcat $vcf | awk -F"\t" '\
#			( !/^#/ && ( ( $4 == "C" && $5 == "T" ) || ( $4 == "G" && $5 == "A" ) ) ){ \
#				samtools = "samtools faidx '${index}'.fa chr"$1":"$2-1"-"$2+1" "
#				while(samtools | getline x ){}; \
#				close(samtools);
#				print $1"\t"$2"\t"$4"\t"$5"\t"toupper(x) \
#			}' > ${base}.tri.txt

#	fi

done
