#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

wd=$PWD

#	bwa seems to require its indexes in the same directory as the source fasta?
#	or maybe that's just these perl scripts?
#	regardless, the Human and TE files need to be indexed in the same dir.

/home/jake/.github/jakewendt/ERVcaller/ERVcaller_v1.4.pl \
	-i 983899.recaled \
	-f .bam \
	-H /raid/refs/fasta/hg38.num.fa.gz \
	-T /home/jake/.github/jakewendt/ERVcaller/Database/HERVK.fa \
	-I /raid/data/raw/CCLS/bam/ \
	-O /raid/data/working/CCLS/20190405-ERVCaller/ \
	-t 40 -S 20 -BWA_MEM


#	Step 2 seems to be finding (-f 4 -F 264)
#	unmapped and mate mapped and not secondary
#	and putting them in 983899.recaled_su.bam

#	-f 8 -F 260 
#	Mapped and mate unmapped and not secondary
#	-> 983899.recaled_sm.bam

#	included SE_MEI not installed. Fails, but doesn't stop.

#~~~~ paired-end reads in bam format were loaded
#sh: 1: extractSoftclipped: not found
#[bam_sort_core] merging from 0 files and 39 in-memory blocks...
#[M::bam2fq_mainloop] discarded 0 singletons
#[M::bam2fq_mainloop] processed 6550378 reads
#
#gzip: 983899.recaled_soft.fastq.gz: unexpected end of file
#
#Chimeric and split reads...
#=====================================
#[E::bwa_idx_load] fail to locate the index files
#[E::bwa_idx_load] fail to locate the index files
#
#Improper reads...
#=====================================



#       -i|input_sampleID <STR>			Sample ID (required)
#       -f|file_suffix <STR>			The suffix of the input data, including: zipped FASTQ file (i.e., .fq.gz, and fastq.gz),
#						unzipped FASTQ file (i.e., .fq, and fastq),
#						BAM file (.bam), and a bam file list (.list; with "-multiple_BAM") (required). Default: .bam
#       -H|Human_reference_genome <STR>		The FASTA file of the human reference genome (required)
#       -T|TE_reference_genomes <STR>		The TE library (FASTA) used for screening (required)
#       -I|Input_directory <STR>			The directory of input data. Default: Not specified (current working directory)
#       -O|Output_directory <STR>		The directory for output data. Default: Not specified (current working directory)
#       -n|number_of_reads <INT>			The minimum number of reads support a TE insertion. Default: 3
#       -d|data_type <STR>			Data type, including: WGS, RNA-seq. Default: WGS
#       -s|sequencing_type <STR>			Type of sequencing data, including: paired-end, single-end. Default: paired-end
#       -l|length_insertsize <FLOAT>		Insert size length (bp). It will be estimated if it is not specified
#       -L|L_std_insertsize <FLOAT>		Standard deviation of insert size length (bp). It will be estimated if it is not specified
#       -r|read_len <INT>			Read length (bp), including: 100, 150, and 250 bp. Default: 100
#       -t|threads <INT>				The number of threads will be used. Default: 1
#       -S|Split <INT>				The minimum length for split reads. A longer length is recommended with longer read length. Default: 20
#       -m|multiple_BAM				If multiple BAM files are used as the input (input bam file need to be indexed). Default: not specified
#       -B|BWA_MEM				If the bam file is generated using aligner BWA_MEM. Default: Not specified
#       -G|Genotype				Genotyping function (input bam file need to be indexed). Default: not specified
#       -h|help					Print this help



