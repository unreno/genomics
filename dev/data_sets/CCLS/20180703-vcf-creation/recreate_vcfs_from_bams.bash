#!/usr/bin/env bash

fasta_ref=/raid/refs/fasta/hg38.test.fa

for f in /raid/data/raw/20170804-Adam/sorted_BAM/*.sorted.bam ; do
	b=${f%.sorted.bam}
	b=${b##*/}
	echo $f $b

#	mpileup is HUUUGE as it contains EVERYTHING and takes at least 24 hours
#	definitely not worth keeping so pipe it to the call
#	also, if not keeping then no sense compressing. output uncompressed (bcf?)

#	bcftools mpileup --output-type z --output $b.mpileup.vcf.gz \
#		--fasta-ref $fasta_ref $f && \
#	bcftools call  --output-type z --output $b.call.vcf.gz \
#		--multiallelic-caller --variants-only $b.mpileup.vcf.gz && \



#	bcftools mpileup --output-type u --fasta-ref $fasta_ref $f | \
#	bcftools call  --output-type z --output $b.call.vcf.gz \
#		--multiallelic-caller --variants-only && \
#	bcftools index $b.call.vcf.gz && \
	bcftools annotate --annotations /raid/refs/vcf/common_all_20180418.vcf.gz \
		--output-type z --output $b.variants.vcf.gz \
		--columns ID,INFO \
		$b.call.vcf.gz && \
	bcftools index $b.variants.vcf.gz && \
	bcftools annotate --rename-chrs /raid/refs/vcf/num_to_chr.txt \
		--output-type z --output $b.renamed.vcf.gz \
		$b.variants.vcf.gz && \
	bcftools index $b.renamed.vcf.gz && \
	bcftools annotate --annotations /raid/refs/genes/genes.bed.gz \
		--columns CHROM,FROM,TO,GENE \
		--header-lines <(echo '##INFO=<ID=GENE,Number=1,Type=String,Description="Gene name">') \
		--output-type z --output $b.genes.vcf.gz \
		$b.renamed.vcf.gz && \
	bcftools index $b.genes.vcf.gz && \
	bcftools annotate --rename-chrs /raid/refs/vcf/chr_to_num.txt \
		--output-type z --output $b.final.vcf.gz \
		$b.genes.vcf.gz && \
	echo "Done with $b" &

#	bcftools index $b.variants.vcf.gz && \
#	bcftools annotate --annotations /raid/refs/genes/genes.noalt.num.bed.gz \

done





#	
#	Usage: bcftools mpileup [options] in1.bam [in2.bam [...]]
#	
#	Input options:
#	  -6, --illumina1.3+      quality is in the Illumina-1.3+ encoding
#	  -A, --count-orphans     do not discard anomalous read pairs
#	  -b, --bam-list FILE     list of input BAM filenames, one per line
#	  -B, --no-BAQ            disable BAQ (per-Base Alignment Quality)
#	  -C, --adjust-MQ INT     adjust mapping quality; recommended:50, disable:0 [0]
#	  -d, --max-depth INT     max per-file depth; avoids excessive memory usage [250]
#	  -E, --redo-BAQ          recalculate BAQ on the fly, ignore existing BQs
#	  -f, --fasta-ref FILE    faidx indexed reference sequence file
#	      --no-reference      do not require fasta reference file
#	  -G, --read-groups FILE  select or exclude read groups listed in the file
#	  -q, --min-MQ INT        skip alignments with mapQ smaller than INT [0]
#	  -Q, --min-BQ INT        skip bases with baseQ/BAQ smaller than INT [13]
#	  -r, --regions REG[,...] comma separated list of regions in which pileup is generated
#	  -R, --regions-file FILE restrict to regions listed in a file
#	      --ignore-RG         ignore RG tags (one BAM = one sample)
#	  --rf, --incl-flags STR|INT  required flags: skip reads with mask bits unset []
#	  --ff, --excl-flags STR|INT  filter flags: skip reads with mask bits set
#	                                            [UNMAP,SECONDARY,QCFAIL,DUP]
#	  -s, --samples LIST      comma separated list of samples to include
#	  -S, --samples-file FILE file of samples to include
#	  -t, --targets REG[,...] similar to -r but streams rather than index-jumps
#	  -T, --targets-file FILE similar to -R but streams rather than index-jumps
#	  -x, --ignore-overlaps   disable read-pair overlap detection
#	
#	Output options:
#	  -a, --annotate LIST     optional tags to output; '?' to list []
#	  -g, --gvcf INT[,...]    group non-variant sites into gVCF blocks according
#	                          to minimum per-sample DP
#	      --no-version        do not append version and command line to the header
#	  -o, --output FILE       write output to FILE [standard output]
#	  -O, --output-type TYPE  'b' compressed BCF; 'u' uncompressed BCF;
#	                          'z' compressed VCF; 'v' uncompressed VCF [v]
#	      --threads INT       number of extra output compression threads [0]
#	
#	SNP/INDEL genotype likelihoods options:
#	  -e, --ext-prob INT      Phred-scaled gap extension seq error probability [20]
#	  -F, --gap-frac FLOAT    minimum fraction of gapped reads [0.002]
#	  -h, --tandem-qual INT   coefficient for homopolymer errors [100]
#	  -I, --skip-indels       do not perform indel calling
#	  -L, --max-idepth INT    maximum per-file depth for INDEL calling [250]
#	  -m, --min-ireads INT    minimum number gapped reads for indel candidates [1]
#	  -o, --open-prob INT     Phred-scaled gap open seq error probability [40]
#	  -p, --per-sample-mF     apply -m and -F per-sample for increased sensitivity
#	  -P, --platforms STR     comma separated list of platforms for indels [all]
#	
#	Notes: Assuming diploid individuals.
#	
#	
#	
#	
#	
#	
#	
#	About:   SNP/indel variant calling from VCF/BCF. To be used in conjunction with samtools mpileup.
#	         This command replaces the former "bcftools view" caller. Some of the original
#	         functionality has been temporarily lost in the process of transition to htslib,
#	         but will be added back on popular demand. The original calling model can be
#	         invoked with the -c option.
#	Usage:   bcftools call [options] <in.vcf.gz>
#	
#	File format options:
#	       --no-version                do not append version and command line to the header
#	   -o, --output <file>             write output to a file [standard output]
#	   -O, --output-type <b|u|z|v>     output type: 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]
#	       --ploidy <assembly>[?]      predefined ploidy, 'list' to print available settings, append '?' for details
#	       --ploidy-file <file>        space/tab-delimited list of CHROM,FROM,TO,SEX,PLOIDY
#	   -r, --regions <region>          restrict to comma-separated list of regions
#	   -R, --regions-file <file>       restrict to regions listed in a file
#	   -s, --samples <list>            list of samples to include [all samples]
#	   -S, --samples-file <file>       PED file or a file with an optional column with sex (see man page for details) [all samples]
#	   -t, --targets <region>          similar to -r but streams rather than index-jumps
#	   -T, --targets-file <file>       similar to -R but streams rather than index-jumps
#	       --threads <int>             number of extra output compression threads [0]
#	
#	Input/output options:
#	   -A, --keep-alts                 keep all possible alternate alleles at variant sites
#	   -f, --format-fields <list>      output format fields: GQ,GP (lowercase allowed) []
#	   -F, --prior-freqs <AN,AC>       use prior allele frequencies
#	   -g, --gvcf <int>,[...]          group non-variant sites into gVCF blocks by minimum per-sample DP
#	   -i, --insert-missed             output also sites missed by mpileup but present in -T
#	   -M, --keep-masked-ref           keep sites with masked reference allele (REF=N)
#	   -V, --skip-variants <type>      skip indels/snps
#	   -v, --variants-only             output variant sites only
#	
#	Consensus/variant calling options:
#	   -c, --consensus-caller          the original calling method (conflicts with -m)
#	   -C, --constrain <str>           one of: alleles, trio (see manual)
#	   -m, --multiallelic-caller       alternative model for multiallelic and rare-variant calling (conflicts with -c)
#	   -n, --novel-rate <float>,[...]  likelihood of novel mutation for constrained trio calling, see man page for details [1e-8,1e-9,1e-9]
#	   -p, --pval-threshold <float>    variant if P(ref|D)<FLOAT with -c [0.5]
#	   -P, --prior <float>             mutation rate (use bigger for greater sensitivity), use with -m [1.1e-3]
#	
#	
#	
#	
#	
#	
#	
#	
#	
#	
#	
#	About:   Annotate and edit VCF/BCF files.
#	Usage:   bcftools annotate [options] <in.vcf.gz>
#	
#	Options:
#	   -a, --annotations <file>       VCF file or tabix-indexed file with annotations: CHR\tPOS[\tVALUE]+
#	       --collapse <string>        matching records by <snps|indels|both|all|some|none>, see man page for details [some]
#	   -c, --columns <list>           list of columns in the annotation file, e.g. CHROM,POS,REF,ALT,-,INFO/TAG. See man page for details
#	   -e, --exclude <expr>           exclude sites for which the expression is true (see man page for details)
#	   -h, --header-lines <file>      lines which should be appended to the VCF header
#	   -I, --set-id [+]<format>       set ID column, see man page for details
#	   -i, --include <expr>           select sites for which the expression is true (see man page for details)
#	   -k, --keep-sites               leave -i/-e sites unchanged instead of discarding them
#	   -m, --mark-sites [+-]<tag>     add INFO/tag flag to sites which are ("+") or are not ("-") listed in the -a file
#	       --no-version               do not append version and command line to the header
#	   -o, --output <file>            write output to a file [standard output]
#	   -O, --output-type <b|u|z|v>    b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]
#	   -r, --regions <region>         restrict to comma-separated list of regions
#	   -R, --regions-file <file>      restrict to regions listed in a file
#	       --rename-chrs <file>       rename sequences according to map file: from\tto
#	   -s, --samples [^]<list>        comma separated list of samples to annotate (or exclude with "^" prefix)
#	   -S, --samples-file [^]<file>   file of samples to annotate (or exclude with "^" prefix)
#	   -x, --remove <list>            list of annotations (e.g. ID,INFO/DP,FORMAT/DP,FILTER) to remove (or keep with "^" prefix). See man page for details
#	       --threads <int>            number of extra output compression threads [0]
#	
#	https://samtools.github.io/bcftools/bcftools-man.html#annotate

#    # Remove three fields
#    bcftools annotate -x ID,INFO/DP,FORMAT/DP file.vcf.gz
#
#    # Remove all INFO fields and all FORMAT fields except for GT and PL
#    bcftools annotate -x INFO,^FORMAT/GT,FORMAT/PL file.vcf
#
#    # Add ID, QUAL and INFO/TAG, not replacing TAG if already present
#    bcftools annotate -a src.bcf -c ID,QUAL,+TAG dst.bcf
#
#    # Carry over all INFO and FORMAT annotations except FORMAT/GT
#    bcftools annotate -a src.bcf -c INFO,^FORMAT/GT dst.bcf
#
#    # Annotate from a tab-delimited file with six columns (the fifth is ignored),
#    # first indexing with tabix. The coordinates are 1-based.
#    tabix -s1 -b2 -e2 annots.tab.gz
#    bcftools annotate -a annots.tab.gz -h annots.hdr -c CHROM,POS,REF,ALT,-,TAG file.vcf
#
#    # Annotate from a tab-delimited file with regions (1-based coordinates, inclusive)
#    tabix -s1 -b2 -e3 annots.tab.gz
#    bcftools annotate -a annots.tab.gz -h annots.hdr -c CHROM,FROM,TO,TAG inut.vcf
#
#    # Annotate from a bed file (0-based coordinates, half-closed, half-open intervals)
#    bcftools annotate -a annots.bed.gz -h annots.hdr -c CHROM,FROM,TO,TAG input.vcf
