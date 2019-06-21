#!/usr/bin/env bash


#
#	DESIGNED FOR SNPs ONLY
#
#	bcftools view -i "TYPE='SNP'" GM_983899.output-HC.vcf.gz | awk -f ./vcf_to_allele_ratios.awk 
#


bcftools view --types snps ${@} | awk 'BEGIN{ FS=OFS="\t" 
	print "CHROM","POS","REF_RATIO","ALT1_RATIO","ALT2_RATIO","ALT3_RATIO"
}
( /^#/ ){ next; }
{
	#	1	4474389	rs760998717	G	GTTTTTTTTT	186.73	.
	#	AC=1;AF=0.500;AN=2;BaseQRankSum=-1.857;ClippingRankSum=-0.027;DB;DP=32;ExcessHet=3.0103;FS=2.021;MLEAC=1;
	#		MLEAF=0.500;MQ=60.34;MQRankSum=-0.212;QD=6.44;ReadPosRankSum=-0.133;SOR=1.276
	#	GT:AD:DP:GQ:PL
	#	0/1:21,8:29:99:224,0,858

	ref_ad=alt_ad1=alt_ad2=alt_ad3=0
	split($9,info_i ,":")
	split($10,values,":")
	split("",info)

	for(i=1;i<=length(info_i);i++)
		info[info_i[i]]=values[i]

	split( info["AD"],INFO_AD,"," )

	#	could be
	#	1	2760182	.	G	A,T	475.77	.
	#	AC=1,1;AF=0.5,0.5;AN=2;DP=13;ExcessHet=3.0103;FS=0;MLEAC=1,1;MLEAF=0.5,0.5;MQ=30.13;QD=30;SOR=3.611
	#	GT:AD:DP:GQ:PL
	#	1/2:0,4,8:12:99:504,336,324,168,0,144
	#

	ref_ad  = INFO_AD[1]
	alt_ad1 = INFO_AD[2]
	alt_ad2 = INFO_AD[3]
	alt_ad3 = INFO_AD[4]

	#if( info["DP"] == 0 )print
	#	DP can be 0 ????
	#	3	185399649	.	A	G	64.28	.
	#	AC=2;AF=1;AN=2;DP=0;ExcessHet=3.0103;FS=0;MLEAC=2;MLEAF=1;MQ=0;SOR=0.693
	#	GT:AD:DP:GQ:PL
	#	1/1:0,0:0:9:92,9,0

	if( info["DP"] > 0 ){
		print $1, $2, ref_ad/info["DP"], alt_ad1/info["DP"], alt_ad2/info["DP"], alt_ad3/info["DP"]
	}
}' 
