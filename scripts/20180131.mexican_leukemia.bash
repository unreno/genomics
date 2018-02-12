#!/usr/bin/env bash


#	Be verbose
set -x

#	exit on any error
set -e


date


[ $# -eq 1 ] || exit

#base=24_S10_L001
base=$1


{

#	Minimize pipes to save memory?
#	Or use pipes to save disk space?


#	1- Upload raw data to amazon
#	2- Create .bam file while filtering to hg38
#	3- Download BAM files and remove from Amazon 
#	4- BALSTn for non human
#	5- Diamond protein homology for reads with bad BLASTn hits
#	6- Chop out ERG section of BAM files (Maybe done locally?)



#	Filter out most human

#	BOWTIE2_INDEXES
#	export BOWTIE2_INDEXES=/Users/jakewendt/BOWTIE2_INDEXES

#-r--r--r-- 1 jakewendt 596573517 Jan 18 15:36 ${base}_R1_001.fastq.gz
#-r--r--r-- 1 jakewendt 638346591 Jan 18 15:43 ${base}_R2_001.fastq.gz
#	
#	bowtie2 --very-sensitive -x hg38 \
#		-1 ${base}_R1_001.fastq.gz \
#		-2 ${base}_R2_001.fastq.gz \
#		--un-conc ${base}-unconc-hg38-very-sensitive.fastq \
#		-S /dev/null &
#	
#	single threaded bowtie2 took 110 minutes


#	--un-conc IS THE SAME AS NOT PROPER_PAIR


#	While the above works, if we are going to select a sub region
#	of the aligned, we'll need the output sam/bam


time bowtie2 --threads 4 --very-sensitive -x hg38 \
	-1 ${base}_R1_001.fastq.gz \
	-2 ${base}_R2_001.fastq.gz \
	-S ${base}.sam
chmod -w ${base}.sam
samtools view --threads 3 -o ${base}.bam ${base}.sam
chmod -w ${base}.bam
#	rm ${base}.sam

#	This took a couple hours.


#	Note, bowtie's threads is the actual count. Samtools is "in addition to 1". Stupid.

#	Its gotta be sorted if selecting a region

samtools sort --threads 3 -o ${base}.by_position.bam ${base}.bam
chmod -w ${base}.by_position.bam

samtools sort --threads 3 -n -o ${base}.by_name.bam ${base}.bam
chmod -w ${base}.by_name.bam

#	These sorts take only a few minutes.


#	need an index to extract a region (here -@ is the actual number of threads)
#samtools index -@ 4 ${base}.by_position.bam
samtools index ${base}.by_position.bam
chmod -w ${base}.by_position.bam.bai

#	hg38 gene
#			samtools view -h -b -o "$bam_base.ERG.bam" "raw/$bam" "chr21:38367261-38662045"
#	hg38 gene with 1000 base pair extension
#			samtools view -h -b -o "$bam_base.ERG.bam" "raw/$bam" "chr21:38366261-38663045"

samtools view -h -b -o ${base}.ERG.bam ${base}.by_position.bam "chr21:38366261-38663045"
chmod -w ${base}.ERG.bam



#	-F 2 = NOT PROPER_PAIR
#samtools fasta -F 2 --threads 3 -N -1 ${base}.nonhg38.1.fasta -2 ${base}.nonhg38.2.fasta ${base}.by_name.bam
#cat ${base}.nonhg38.1.fasta ${base}.nonhg38.2.fasta | gzip --best > ${base}.nonhg38.fasta.gz

samtools fasta -F 2 --threads 3 -N ${base}.by_name.bam > ${base}.nonhg38.fasta
chmod -w ${base}.nonhg38.fasta
gzip --best < ${base}.nonhg38.fasta > ${base}.nonhg38.fasta.gz
chmod -w ${base}.nonhg38.fasta.gz





export BLASTDB=/Users/jakewendt/BLAST_DBS


#	makeblastdb -dbtype nucl -in viral.fasta -out viral -title viral -parse_seqids

#blastn -query <( zcat ${base}.nonhg38.fasta.gz ) -db viral -num_threads 8 -out ${base}.nonhg38.blastn.txt

#blastn -query <( zcat ${base}.nonhg38.fasta.gz ) -db viral -num_threads 8 2> ${base}.nonhg38.blastn.STDERR.txt | gzip --best > ${base}.nonhg38.blastn.txt.gz

#blastn -query <( zcat ${base}.nonhg38.fasta.gz ) -db viral -num_threads 8 2> /dev/null | gzip --best > ${base}.nonhg38.blastn.txt.gz

time blastn -query ${base}.nonhg38.fasta -db viral -num_threads 8 2> /dev/null > ${base}.nonhg38.blastn.txt
chmod -w ${base}.nonhg38.blastn.txt
gzip --best < ${base}.nonhg38.blastn.txt > ${base}.nonhg38.blastn.txt.gz
chmod -w ${base}.nonhg38.blastn.txt.gz

#blastn -query ${base}.nonhg38.fasta -db viral -num_threads 8 -out ${base}.nonhg38.blastn.txt


#				cmd="$prefix $command $negative_gilist -query $file -db $db $dust \
#					-num_alignments $num_alignments -num_descriptions $num_descriptions \
#					-evalue $evalue -outfmt $outfmt \
#					-out $file.${command}_${db_base_name}.txt $options $suffix"


#	ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/



time tblastx -query ${base}.nonhg38.fasta -db viral -num_threads 8 2> /dev/null > ${base}.nonhg38.tblastx.txt
chmod -w ${base}.nonhg38.tblastx.txt
gzip --best < ${base}.nonhg38.tblastx.txt > ${base}.nonhg38.tblastx.txt.gz
chmod -w ${base}.nonhg38.tblastx.txt.gz



#	MAKE SURE THAT THE SOURCE FASTA IS A PROTEIN FASTA AND NOT NUCEOTIDES
#	I used EMBOSS's transeq
#	transeq viral.fasta viral.protein.fasta
#	diamond makedb --in viral.protein.fasta --db viral



#	diamond makedb --in nt.fasta --db nt --threads 8 

#	diamond blastx --threads 8 --db nt --query reads.fna --out matches.m8

#	https://github.com/bbuchfink/diamond/blob/master/diamond_manual.pdf

#diamond blastx --db ~/DIAMOND/viral --query ${base}.nonhg38.fasta --out ${base}.nonhg38.diamond.txt

#diamond blastx --db ~/DIAMOND/viral --query <( zcat ${base}.nonhg38.fasta.gz ) --out ${base}.nonhg38.diamond.txt

#diamond blastx --db ~/DIAMOND/viral --query <( zcat ${base}.nonhg38.fasta.gz ) 2> ${base}.nonhg38.diamond.STDERR.txt | gzip --best > ${base}.nonhg38.diamond.txt.gz

#diamond blastx --db ~/DIAMOND/viral --query <( zcat ${base}.nonhg38.fasta.gz ) 2> /dev/null | gzip --best > ${base}.nonhg38.diamond.txt.gz

time diamond blastx --outfmt 0 --threads 8  --db ~/DIAMOND/viral --query ${base}.nonhg38.fasta 2> /dev/null > ${base}.nonhg38.diamond.txt
chmod -w ${base}.nonhg38.diamond.txt
gzip --best < ${base}.nonhg38.diamond.txt > ${base}.nonhg38.diamond.txt.gz
chmod -w ${base}.nonhg38.diamond.txt.gz


date

} > ${base}.log 2>&1
