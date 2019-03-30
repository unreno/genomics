#
#	DESIGNED FOR SNPs ONLY
#
#	bcftools view -i "TYPE='SNP'" GM_983899.output-HC.vcf.gz | awk -f mpileup_vcf_allele_filter.awk
#
BEGIN{ 
	FS=OFS="\t" 
	if( min == "" ) min=0.05
	if( max == "" ) max=0.20
}
( /^#/ ){ print; next; }
{

#	1	10009	.	A	G,C,<*>	0	.	DP=28;I16=21,1,0,2,623,17873,38,722,917,39439,71,2561,155,1265,50,1250;QS=0.942511,0.0287443,0.0287443,0;VDB=0.06;SGB=-0.453602;RPB=0.704545;MQB=0.522727;MQSB=0.891154;BQB=0;MQ0F=0	PL:DP:SP:ADF:ADR:AD	0,50,166,50,163,166,66,169,169,172:24:20:21,0,0,0:1,1,1,0:22,1,1,0


	ref_ad=alt_ad1=alt_ad2=alt_ad3=0
	split($9,info_i ,":")
	split($10,values,":")
	split("",info)

	for(i=1;i<=length(info_i);i++)
		info[info_i[i]]=values[i]

	#split( info["GT"],INFO_GT,"/" )
	split( info["AD"],INFO_AD,"," )

#	for( i=1;i<=length(INFO_GT);i++){
#		if( INFO_GT[i] == 0 ) ref_ad  = INFO_AD[1]
#		if( INFO_GT[i] == 1 ) alt_ad1 = INFO_AD[2]
#		if( INFO_GT[i] == 2 ) alt_ad2 = INFO_AD[3]
#		if( INFO_GT[i] == 3 ) alt_ad3 = INFO_AD[4]
#	}

#		ref_ad  = INFO_AD[1]
		alt_ad1 = INFO_AD[2]
#		alt_ad2 = INFO_AD[3]
#		alt_ad3 = INFO_AD[4]

#		print info["DP"]
#		print ref_ad
#		print alt_ad1
#		print

#	DP can be 0, but realistically, I filter on it before this

	if( ( info["DP"] > 10 ) && ( ( alt_ad1 >= 3 && alt_ad1/info["DP"] >= min && alt_ad1/info["DP"] <= max ) ) )
		print

#	if( ( info["DP"] > 10 ) && ( ( alt_ad1 > 3 && alt_ad1/info["DP"] <= 0.45 ) || ( alt_ad2 > 3 && alt_ad2/info["DP"] <= 0.45 ) || ( alt_ad3 > 3 && alt_ad3/info["DP"] <= 0.45 ) ) )
#		print


#This brings up another important point. I saw you have been using a DP threshold of 5. I think it is more common to use a DP of at least 8, and given the high sequencing coverage in our data I would suggest a DP threshold of 10. Along with that, we should also use a minimum AD_ALT threshold of 3, i.e. a mutation has to be called in at least 3 reads out of 10.

}
