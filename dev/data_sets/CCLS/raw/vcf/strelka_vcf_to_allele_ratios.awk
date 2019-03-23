#
#	DESIGNED FOR SNPs ONLY
#
#	bcftools view -i "TYPE='SNP'" GM_983899.output-HC.vcf.gz | awk -f ./vcf_to_allele_ratios.awk 
#
#	bcftools +split PATH/somatic.snvs.vcf.gz -Oz -o STRELKA_OUT_DIR
#
#	Sadly, Strelka vcfs are different enough that the original script won't work
#
#	1	1130964	.	G	T	.	PASS	SOMATIC;QSS=36;TQSS=1;NT=ref;QSS_NT=36;TQSS_NT=1;SGT=GG->GT;DP=115;MQ=60;MQ0=0;ReadPosRankSum=0.94;SNVSB=0;SomaticEVS=9.2	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	48:0:0:0:0,0:0,0:48,48:0,0
#
BEGIN{ FS=OFS="\t" 
	#print "REF_RATIO","ALT1_RATIO","ALT2_RATIO","ALT3_RATIO"
	print "A_RATIO","C_RATIO","G_RATIO","T_RATIO"
}
( /^#/ ){ next; }
{

	ref_ad=alt_ad1=alt_ad2=alt_ad3=0
	split($8,format_i ,";")
	split($9,info_i ,":")
	split($10,values,":")
	split("",info)
	split("",format)

	for(i=1;i<=length(info_i);i++)
		info[info_i[i]]=values[i]

	for(i=1;i<=length(format_i);i++){
		split(format_i[i],f,"=")
		format[f[1]]=f[2]
	}

	if( info["DP"] > 0 ){
#print
#print format["TQSS"]
		split(info["AU"],a,",")
		split(info["CU"],c,",")
		split(info["GU"],g,",")
		split(info["TU"],t,",")
		
		total=a[format["TQSS"]]+c[format["TQSS"]]+g[format["TQSS"]]+t[format["TQSS"]]
		#print a[format["TQSS"]], c[format["TQSS"]], g[format["TQSS"]], t[format["TQSS"]]
		print a[format["TQSS"]]/total, c[format["TQSS"]]/total, g[format["TQSS"]]/total, t[format["TQSS"]]/total
	}

}
