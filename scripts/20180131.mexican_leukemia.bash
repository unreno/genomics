#!/usr/bin/env bash



#	1- Upload raw data to amazon
#	2- Create .bam file while filtering to hg38
#	3- Download BAM files and remove from Amazon 
#	4- BALSTn for non human
#	5- Diamond protein homology for reads with bad BLASTn hits
#	6- Chop out ERG section of BAM files (Maybe done locally?)



#	Filter out most human

#	BOWTIE2_INDEXES
#	export BOWTIE2_INDEXES=/Users/jakewendt/BOWTIE2_INDEXES

#-r--r--r-- 1 jakewendt 596573517 Jan 18 15:36 24_S10_L001_R1_001.fastq.gz
#-r--r--r-- 1 jakewendt 638346591 Jan 18 15:43 24_S10_L001_R2_001.fastq.gz
#	
#	bowtie2 --very-sensitive -x hg38 \
#		-1 24_S10_L001_R1_001.fastq.gz \
#		-2 24_S10_L001_R2_001.fastq.gz \
#		--un-conc 24_S10_L001-unconc-hg38-very-sensitive.fastq \
#		-S /dev/null &
#	
#	single threaded bowtie2 took 110 minutes




#	While the above works, if we are going to select a sub region
#	of the aligned, we'll need the output sam/bam


bowtie2 --threads 4 --very-sensitive -x hg38 \
	-1 24_S10_L001_R1_001.fastq.gz \
	-2 24_S10_L001_R2_001.fastq.gz \
	| samtools view --threads 3 -o 24_S10_L001.default.bam -

#	Note, bowtie's threads is the actual count. Samtools is "in addition to 1". Stupid.

#	Its gotta be sorted if selecting a region

samtools sort --threads 3 -o 24_S10_L001.by_position.bam 24_S10_L001.default.bam
samtools sort --threads 3 -n -o 24_S10_L001.by_name.bam 24_S10_L001.default.bam


#	need an index to extract a region
samtools index 24_S10_L001.by_position.bam

#	hg38 gene
#			samtools view -h -b -o "$bam_base.ERG.bam" "raw/$bam" "chr21:38367261-38662045"
#	hg38 gene with 1000 base pair extension
#			samtools view -h -b -o "$bam_base.ERG.bam" "raw/$bam" "chr21:38366261-38663045"

samtools view -h -b -o 24_S10_L001.ERG.bam 24_S10_L001.by_position.bam "chr21:38366261-38663045"



#	-F 2 = NOT PROPER_PAIR
samtools fasta -F 2 --threads 3 -N -1 24_S10_L001.nonhg38.1.fasta -2 24_S10_L001.nonhg38.2.fasta

cat 24_S10_L001.nonhg38.1.fasta 24_S10_L001.nonhg38.2.fasta > 24_S10_L001.nonhg38.fasta





















#	export BLASTDB=/Users/jakewendt/BLAST_DBS


#	makeblastdb -dbtype nucl -in viral.fasta -out viral -title viral -parse_seqids

blastn -query 24_S10_L001.nonhg38.fasta -db viral -num_threads 8 -out 24_S10_L001.nonhg38.blastn.txt


#				cmd="$prefix $command $negative_gilist -query $file -db $db $dust \
#					-num_alignments $num_alignments -num_descriptions $num_descriptions \
#					-evalue $evalue -outfmt $outfmt \
#					-out $file.${command}_${db_base_name}.txt $options $suffix"


#	ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/



#	diamond makedb --in nt.fasta --db nt --threads 8 

#	diamond blastx --threads 8 --db nt --query reads.fna --out matches.m8

#	https://github.com/bbuchfink/diamond/blob/master/diamond_manual.pdf

diamond blastx --db ~/DIAMOND/viral --query 24_S10_L001.nonhg38.fasta --out 24_S10_L001.nonhg38.diamond.txt



