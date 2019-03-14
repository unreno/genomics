BEGIN{
	FS=OFS="\t"
}
( /^#/ ){ print; next; }
{
#	1	4474389	rs760998717	G	GTTTTTTTTT	186.73	.	AC=1;AF=0.500;AN=2;BaseQRankSum=-1.857;ClippingRankSum=-0.027;DB;DP=32;ExcessHet=3.0103;FS=2.021;MLEAC=1;MLEAF=0.500;MQ=60.34;MQRankSum=-0.212;QD=6.44;ReadPosRankSum=-0.133;SOR=1.276	GT:AD:DP:GQ:PL	0/1:21,8:29:99:224,0,858
#	print $8,$9,$10

	split($9,info_i ,":")
	split($10,values,":")
	split("",info)

	#print $9,$10
	for(i=1;i<=length(info_i);i++){
		info[info_i[i]]=values[i]
		#print(info_i[i],values[i])
	}
	#print( info["GT"] )
	split( info["GT"],gt,"/" )
	split( info["AD"],ad,"," )

	for( i=1;i<=length(gt);i++){
		print( gt[i], ad[i], info["DP"], ad[i]/info["DP"] )
	}

}
