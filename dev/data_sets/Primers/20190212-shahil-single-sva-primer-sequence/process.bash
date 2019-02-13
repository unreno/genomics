#!/usr/bin/env bash



for ref in SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do
	echo $ref

	#	These reads overlap by 1, which by default would make them not a proper pair.
	#	Not entirely relevant here, but the --dovetail option alleviates this restriction.
	bowtie2 --all --ff --dovetail --xeq -f -x $ref --very-sensitive -1 sva_primer.10.fa -2 sva_primer.11.fa | samtools view -o $ref.bam -

done

bowtie2 --ff -X 50 --all --dovetail --xeq -f -x hg38_no_alts --very-sensitive -1 sva_primer.10.fa -2 sva_primer.11.fa | samtools view -o SVA_10-11.bam -

