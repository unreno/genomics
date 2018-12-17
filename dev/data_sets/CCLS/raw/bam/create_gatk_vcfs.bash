#!/usr/bin/env bash


gatk HaplotypeCaller --input GM_983899.recaled.bam --output GM_983899.recaled.vcf.gz --reference /raid/refs/fasta/hg38.num.fa --dbsnp /raid/refs/vcf/dbsnp_146.hg38.num.MT.vcf.gz > GM_983899.recaled.vcf.gz.out 2> GM_983899.recaled.vcf.gz.err &

gatk HaplotypeCaller --input 983899.recaled.bam --output 983899.recaled.vcf.gz --reference /raid/refs/fasta/hg38.num.fa --dbsnp /raid/refs/vcf/dbsnp_146.hg38.num.MT.vcf.gz > 983899.recaled.vcf.gz.out 2> 983899.recaled.vcf.gz.err &

gatk HaplotypeCaller --input GM_983899.recaled.PP.bam --output GM_983899.recaled.PP.vcf.gz --reference /raid/refs/fasta/hg38.num.fa --dbsnp /raid/refs/vcf/dbsnp_146.hg38.num.MT.vcf.gz > GM_983899.recaled.PP.vcf.gz.out 2> GM_983899.recaled.PP.vcf.gz.err &

gatk HaplotypeCaller --input 983899.recaled.PP.bam --output 983899.recaled.PP.vcf.gz --reference /raid/refs/fasta/hg38.num.fa --dbsnp /raid/refs/vcf/dbsnp_146.hg38.num.MT.vcf.gz > 983899.recaled.PP.vcf.gz.out 2> 983899.recaled.PP.vcf.gz.err &


