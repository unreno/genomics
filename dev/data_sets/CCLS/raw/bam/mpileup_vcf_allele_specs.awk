#
#	DESIGNED FOR SNPs ONLY
#
#	bcftools view -i "TYPE='SNP'" 983899.recaled.mpileup-strelka/0001.vcf | awk -f mpileup_vcf_allele_specs.awk
#
BEGIN{ FS=OFS="\t" 
#	print "REF_RATIO","ALT1_RATIO","ALT2_RATIO","ALT3_RATIO"
	print "DP","REF_COUNT","ALT_COUNT","ALT_RATIO"
}
( /^#/ ){ next; }
{
#	1	10009	.	A	G,C,<*>	0	.	DP=28;I16=21,1,0,2,623,17873,38,722,917,39439,71,2561,155,1265,50,1250;QS=0.942511,0.0287443,0.0287443,0;VDB=0.06;SGB=-0.453602;RPB=0.704545;MQB=0.522727;MQSB=0.891154;BQB=0;MQ0F=0	PL:DP:SP:ADF:ADR:AD	0,50,166,50,163,166,66,169,169,172:24:20:21,0,0,0:1,1,1,0:22,1,1,0

	split($9,info_i ,":")
	split($10,values,":")
	split("",info)

	for(i=1;i<=length(info_i);i++)
		info[info_i[i]]=values[i]

	split( info["AD"],INFO_AD,"," )

	print info["DP"], INFO_AD[1], INFO_AD[1]/info["DP"] , INFO_AD[2], INFO_AD[2]/info["DP"] , INFO_AD[3], INFO_AD[3]/info["DP"]

}
