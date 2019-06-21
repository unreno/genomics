#!/usr/bin/env bash


#
#	DESIGNED FOR SNPs ONLY
#
#	bcftools view -i "TYPE='SNP'" GM_983899.output-HC.vcf.gz | awk -f ./vcf_to_allele_ratios.awk 
#
#	1	266358	.	G	T	.	PASS
#	CONTQ=93;DP=301;ECNT=1;GERMQ=743;MBQ=29,27;MFRL=363,306;MMQ=44,43;MPOS=24;NALOD=2.04;NLOD=32.13;POPAF=4.61;SAAF=0.01,0.03,0.033;SAPP=0.038,0.001872,0.96;TLOD=6.11
#	GT:AD:AF:DP:F1R2:F2R1
#	0/1:178,6:0.037:184:94,6:84,0
#	1	269057	.	A	G	.	PASS
#	CONTQ=93;DP=140;ECNT=1;GERMQ=260;MBQ=26,28;MFRL=370,343;MMQ=24,36;MPOS=41;NALOD=0.263;NLOD=11.48;POPAF=6;SAAF=0,0.091,0.091;SAPP=0.229,0.002886,0.768;TLOD=9.28
#	GT:AD:AF:DP:F1R2:F2R1
#	0/1:80,8:0.093:88:36,5:44,3



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
		ad["A"]=ad["C"]=ad["G"]=ad["T"]=0
		ad[$4]      = INFO_AD[1]
		ad[alts[1]] = INFO_AD[2]
		ad[alts[2]] = INFO_AD[3]
		ad[alts[3]] = INFO_AD[4]

		samtools = "samtools faidx /raid/refs/fasta/hg38.num.fa "$1":"$2-1"-"$2+1" "
		while(samtools | getline triref ){};
		close(samtools);

		#print $0

		#print $1, $2, $4, toupper(triref), total, ad["A"], ad["C"], ad["G"], ad["T"]
		print $1, $2, $4, toupper(triref), info["DP"], ad["A"], ad["C"], ad["G"], ad["T"]

	}
}' 
