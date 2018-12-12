#!/usr/bin/env bash

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables

set -o pipefail

#/raid/data/raw/CCLS/bam/GM_268325.recaled.bam
#/raid/data/raw/CCLS/bam/GM_439338.recaled.bam
#/raid/data/raw/CCLS/bam/GM_63185.recaled.bam
#/raid/data/raw/CCLS/bam/GM_634370.recaled.bam
#/raid/data/raw/CCLS/bam/GM_983899.recaled.bam

#for f1 in /raid/data/raw/ArrayExpress/E-GEOD-81089/*_1.fastq.gz ; do
for normalbam in /raid/data/raw/CCLS/bam/GM_*.recaled.bam ; do


		tumorbam=${normalbam/GM_/}
		echo $normalbam
		echo $tumorbam

		for bam in $normalbam $tumorbam ; do
			echo $bam
			base=$( basename $bam .recaled.bam )


			if [ -f "${base}.sorted.bam" ] && [ ! -w "${base}.sorted.bam" ] ; then
				echo "Write protected ${base}.sorted.bam exists. Skipping."
			else
				echo "Sorting $bam ${base}.sorted.bam"
				samtools sort -@ 39 -o "${base}.sorted.bam" $bam
				chmod a-w "${base}.sorted.bam"
			fi

			if [ -f "${base}.2.fastq.gz" ] && [ ! -w "${base}.2.fastq.gz" ] ; then
				echo "Write protected ${base}.2.fastq.gz exists. Skipping."
			else
				echo "Extracting fastq's ${base}.?.fastq.gz"
				samtools fastq -@ 39 \
					-0 "${base}.0.fastq.gz" \
					-1 "${base}.1.fastq.gz" \
					-2 "${base}.2.fastq.gz" "${base}.sorted.bam"
				chmod a-w ${base}*fastq.gz
			fi

			if [ -e "${base}.Homo_sapiens.GRCh38.rna" ] && [ ! -w "${base}.Homo_sapiens.GRCh38.rna" ] ; then
				echo "Write protected ${base}.Homo_sapiens.GRCh38.rna exists. Skipping"
			else
				echo "Running kallisto"

				kallisto quant -b 10 --threads 10 \
					--index /raid/refs/kallisto/Homo_sapiens.GRCh38.rna.idx \
					--output-dir ./${base}.Homo_sapiens.GRCh38.rna \
					"${base}.1.fastq.gz" "${base}.2.fastq.gz"

				kallistostatus=$?
				if [ $kallistostatus -ne 0 ] ; then
					echo "Kallisto failed." 
					mv ${basename}.Homo_sapiens.GRCh38.rna ${basename}.Homo_sapiens.GRCh38.rna.FAILED
				fi
			fi

		done






#		#	 NA20759.4.M_120208_3_2.fastq.gz
#		f2=${f1/_1.fastq/_2.fastq}
#		basename=${f1##*/}
#		basename=${basename%_1.fastq.gz}	#	just 1 %, not 2
#		echo $f1 $f2
#		echo $basename
#	
#		#	Apparently NEED to use my combined index Homo_sapiens.GRCh38.rna which matches
#		#	the ensembl stuff from sleuth and the following works ...
#		#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
#		#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz
#		#	cat Homo_sapiens.GRCh38.cdna.all.fa.gz Homo_sapiens.GRCh38.ncrna.fa.gz > Homo_sapiens.GRCh38.rna.fa.gz
#		#	kallisto index --index Homo_sapiens.GRCh38.rna.idx Homo_sapiens.GRCh38.rna.fa.gz
#	
#		#	Also, sleuth seems to need some bootstraps. Not sure how many. 100 takes a while. Use less next time?
#	
#	
#		if [ -e ./${basename}.Homo_sapiens.GRCh38.rna ] ; then
#			echo "Done already. Skipping."
#		else
#	#		echo "Checking if download complete."
#	#		if [ -e $f1 ] ; then
#	#			echo "F1 exists."
#	#			echo "Checking complete."
#	#			gunzip -t $f1
#	#			f1status=$?
#	#			if [ $f1status -eq 0 ] ; then
#	#				if [ -e $f2 ] ; then
#	#					echo "F2 exists."
#	#					echo "Checking complete."
#	#					gunzip -t $f2
#	#					f2status=$?
#	#					if [ $f2status -eq 0 ] ; then 
#	
#	
#							time kallisto quant -b 10 --threads 40 \
#								--index /raid/refs/kallisto/Homo_sapiens.GRCh38.rna.idx \
#								--output-dir ./${basename}.Homo_sapiens.GRCh38.rna \
#								$f1 $f2
#	
#	#							--output-dir ./${basename}.Homo_sapiens.GRCh38.rna \
#	
#							kallistostatus=$?
#							if [ $kallistostatus -ne 0 ] ; then
#								echo "Kallisto failed." 
#								mv ${basename}.Homo_sapiens.GRCh38.rna ${basename}.Homo_sapiens.GRCh38.rna.FAILED
#							fi
#	
#	
#	#					else
#	#						echo "F2 incomplete. Skipping."
#	#					fi
#	#				else
#	#					echo "F2 does not exist. Skipping."
#	#				fi
#	#			else
#	#				echo "F1 incomplete. Skipping."
#	#			fi
#	#		else
#	#			echo "F1 does not exist. Skipping."
#	#		fi
#		fi

done

