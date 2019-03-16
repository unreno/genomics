#
#	zcat GM_983899.output-HC.vcf.gz | awk -f ./vcf_filter.awk 
#
BEGIN{ FS=OFS="\t" }
( /^#/ ){ print; next; }
{
#	1	4474389	rs760998717	G	GTTTTTTTTT	186.73	.	AC=1;AF=0.500;AN=2;BaseQRankSum=-1.857;ClippingRankSum=-0.027;DB;DP=32;ExcessHet=3.0103;FS=2.021;MLEAC=1;MLEAF=0.500;MQ=60.34;MQRankSum=-0.212;QD=6.44;ReadPosRankSum=-0.133;SOR=1.276	GT:AD:DP:GQ:PL	0/1:21,8:29:99:224,0,858

	ref_ad=alt_ad1=alt_ad2=alt_ad3=0
	split($9,info_i ,":")
	split($10,values,":")
	split("",info)

	for(i=1;i<=length(info_i);i++)
		info[info_i[i]]=values[i]

	split( info["GT"],INFO_GT,"/" )
	split( info["AD"],INFO_AD,"," )

	for( i=1;i<=length(INFO_GT);i++){
		if( INFO_GT[i] == 0 ) ref_ad += INFO_AD[i]
		if( INFO_GT[i] == 1 ) alt_ad1 += INFO_AD[i]
		if( INFO_GT[i] == 2 ) alt_ad2 += INFO_AD[i]
		if( INFO_GT[i] == 3 ) alt_ad3 += INFO_AD[i]
	}

#if( alt_ad2 > 0 ){
#	print( "Ref ratio ",ref_ad/info["DP"]," : Alt1 ratio ", alt_ad1/info["DP"]," : Alt2 ratio ", alt_ad2/info["DP"]," : Alt3 ratio ", alt_ad3/info["DP"])
#}

	if( ( info["DP"] > 10 ) && ( ( alt_ad1 > 3 && alt_ad1/info["DP"] <= 0.45 ) || ( alt_ad2 > 3 && alt_ad2/info["DP"] <= 0.45 ) || ( alt_ad3 > 3 && alt_ad3/info["DP"] <= 0.45 ) ) )
		print

#This brings up another important point. I saw you have been using a DP threshold of 5. I think it is more common to use a DP of at least 8, and given the high sequencing coverage in our data I would suggest a DP threshold of 10. Along with that, we should also use a minimum AD_ALT threshold of 3, i.e. a mutation has to be called in at least 3 reads out of 10.


	

#	sometimes GT is 1/1. Merge them
#	1	0	9	0
#	1	9	9	1
#	1	0	3	0
#	1	3	3	1
#	1	0	5	0
#	1	5	5	1
#	0	67	80	0.8375
#	1	13	80	0.1625

}
