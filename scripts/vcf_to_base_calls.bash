#!/usr/bin/env bash


#
#	DESIGNED FOR SNPs ONLY
#
#	bcftools view -i "TYPE='SNP'" GM_983899.output-HC.vcf.gz | awk -f ./vcf_to_allele_ratios.awk 
#


bcftools view --types snps ${@} | awk 'BEGIN{ FS=OFS="\t" 
	print "CHROM","POS","REF","TRIREF","DP","A","C","G","T"
}
( /^#/ ){ next; }
{
	split($9,info_i ,":")
	split($10,values,":")
	split("",info)

	for(i=1;i<=length(info_i);i++)
		info[info_i[i]]=values[i]

	if( info["DP"] > 0 ){
		split( info["AD"],INFO_AD,"," )

#	1	2760182	.	G	A,T	475.77	.
#	AC=1,1;AF=0.5,0.5;AN=2;DP=13;ExcessHet=3.0103;FS=0;MLEAC=1,1;MLEAF=0.5,0.5;MQ=30.13;QD=30;SOR=3.611
#	GT:AD:DP:GQ:PL
#	1/2:0,4,8:12:99:504,336,324,168,0,144

		split($5,alts,",")
		ad[$4]      = INFO_AD[1]
		ad[alts[1]] = INFO_AD[2]
		ad[alts[2]] = INFO_AD[3]
		ad[alts[3]] = INFO_AD[4]

#	3	185399649	.	A	G	64.28	.
#	AC=2;AF=1;AN=2;DP=0;ExcessHet=3.0103;FS=0;MLEAC=2;MLEAF=1;MQ=0;SOR=0.693
#	GT:AD:DP:GQ:PL
#	1/1:0,0:0:9:92,9,0

#		samtools = "samtools faidx /raid/refs/fasta/hg38.fa "$1":"$2-2"-"$2+2" "
#		while(samtools | getline triref ){};
#		close(samtools);

print $0
		#print $1, $2, $4, toupper(triref), total, ad["A"], ad["C"], ad["G"], ad["T"]
		print $1, $2, $4, toupper(triref), info["AD"], ad["A"], ad["C"], ad["G"], ad["T"]

	}
}' 
