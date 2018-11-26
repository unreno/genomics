#!/usr/bin/env bash


for f1 in /raid/data/raw/ArrayExpress/E-GEOD-81089/*_1.fastq.gz ; do

	#	 NA20759.4.M_120208_3_2.fastq.gz
	f2=${f1/_1.fastq/_2.fastq}
	basename=${f1##*/}
	basename=${basename%_1.fastq.gz}	#	just 1 %, not 2
	echo $f1 $f2
	echo $basename

	#	Apparently NEED to use my combined index Homo_sapiens.GRCh38.rna which matches
	#	the ensembl stuff from sleuth and the following works ...
	#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
	#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz
	#	cat Homo_sapiens.GRCh38.cdna.all.fa.gz Homo_sapiens.GRCh38.ncrna.fa.gz > Homo_sapiens.GRCh38.rna.fa.gz
	#	kallisto index --index Homo_sapiens.GRCh38.rna.idx Homo_sapiens.GRCh38.rna.fa.gz

	#	Also, sleuth seems to need some bootstraps. Not sure how many. 100 takes a while. Use less next time?


	if [ -e ./${basename}.Homo_sapiens.GRCh38.rna ] ; then
		echo "Done already. Skipping."
	else
#		echo "Checking if download complete."
#		if [ -e $f1 ] ; then
#			echo "F1 exists."
#			echo "Checking complete."
#			gunzip -t $f1
#			f1status=$?
#			if [ $f1status -eq 0 ] ; then
#				if [ -e $f2 ] ; then
#					echo "F2 exists."
#					echo "Checking complete."
#					gunzip -t $f2
#					f2status=$?
#					if [ $f2status -eq 0 ] ; then 


						time kallisto quant -b 10 --threads 40 \
							--index /raid/refs/kallisto/Homo_sapiens.GRCh38.rna.idx \
							--output-dir ./${basename}.Homo_sapiens.GRCh38.rna \
							$f1 $f2

#							--output-dir ./${basename}.Homo_sapiens.GRCh38.rna \

						kallistostatus=$?
						if [ $kallistostatus -ne 0 ] ; then
							echo "Kallisto failed." 
							mv ${basename}.Homo_sapiens.GRCh38.rna ${basename}.Homo_sapiens.GRCh38.rna.FAILED
						fi


#					else
#						echo "F2 incomplete. Skipping."
#					fi
#				else
#					echo "F2 does not exist. Skipping."
#				fi
#			else
#				echo "F1 incomplete. Skipping."
#			fi
#		else
#			echo "F1 does not exist. Skipping."
#		fi
	fi

done

