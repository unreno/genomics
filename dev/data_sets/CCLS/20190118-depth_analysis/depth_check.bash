#!/usr/bin/env bash


#samtools depth -a -r 4:9601586-9601646 186069.recaled.PP.bam | awk '
#samtools depth -a -r 12:43000000-44000000 186069.recaled.PP.bam | awk '
#samtools depth -a -r 12:43000000-44000000 186069.recaled.bam | awk '

for f in /raid/data/raw/CCLS_983899/*983899.hg38.num*bam /raid/data/raw/CCLS/bam/*983899.recaled*bam ; do
	echo $f
	samtools depth -a -r 21 $f | awk '
		BEGIN{
			FS="\t"
			last_chr=""
		}
		( $1 != last_chr ){	#	RESET
			c=100
			overlap=0
			chr_row_count=0
			delete last_5_counts[0]
		}
		{ chr_row_count++ }
		( chr_row_count < 6 ){ # BUFFER and SKIP


			next;
		}


		( $3 < 100 && $3 < c-10 ){
			#	overlap ended
			if( overlap && overlap > 6 && overlap < 9 ){
				print zero
				print first
				print last
				print $0
				print ""
			}
			overlap=0;
		}
		( $3 < 100 && $3 > c+10 ){
			#	overlap started
			overlap=1;
			zero=previous
			first=$0
		}
		( overlap ){
			last=$0
			overlap+=1
		}
		{
			c=$3
			previous=$0
		}'
done
