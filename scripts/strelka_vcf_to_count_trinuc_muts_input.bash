#!/usr/bin/env bash


#
#	DESIGNED FOR SNPs ONLY
#	DESIGNED FOR STRELKA VCFs ONLY
#
#	bcftools view -i "TYPE='SNP'" STRELKA.vcf.gz | awk -f ./strelka_vcf_to_allele_ratios.awk 
#
#	bcftools +split PATH/somatic.snvs.vcf.gz -Oz -o STRELKA_OUT_DIR
#
#	Sadly, Strelka vcfs are different enough that the original script won't work
#
#	1	1130964	.	G	T	.	PASS	SOMATIC;QSS=36;TQSS=1;NT=ref;QSS_NT=36;TQSS_NT=1;SGT=GG->GT;DP=115;MQ=60;MQ0=0;ReadPosRankSum=0.94;SNVSB=0;SomaticEVS=9.2	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	67:0:0:0:0,0:0,0:62,62:5,5
#	1	1266389	.	C	A	.	PASS	SOMATIC;QSS=31;TQSS=2;NT=ref;QSS_NT=31;TQSS_NT=2;SGT=CC->AC;DP=103;MQ=60;MQ0=0;ReadPosRankSum=-0.32;SNVSB=0;SomaticEVS=8.36	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	58:3:0:0:5,5:50,54:0,0:0,0
#	1	1541286	.	C	A	.	PASS	SOMATIC;QSS=31;TQSS=1;NT=ref;QSS_NT=31;TQSS_NT=1;SGT=CC->AC;DP=104;MQ=60;MQ0=0;ReadPosRankSum=0.11;SNVSB=0;SomaticEVS=7.84	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	64:0:0:0:5,5:59,59:0,0:0,0
#	1	1795180	.	C	A	.	PASS	SOMATIC;QSS=29;TQSS=1;NT=ref;QSS_NT=29;TQSS_NT=1;SGT=CC->AC;DP=92;MQ=60;MQ0=0;ReadPosRankSum=1.37;SNVSB=0;SomaticEVS=7.37	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	63:0:0:0:4,4:58,58:0,0:1,1
#	1	1814815	.	A	G	.	PASS	SOMATIC;QSS=44;TQSS=1;NT=ref;QSS_NT=44;TQSS_NT=1;SGT=AA->AG;DP=68;MQ=60.67;MQ0=0;ReadPosRankSum=1.4;SNVSB=0;SomaticEVS=9.59	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	46:2:0:0:34,36:0,0:10,10:0,0
#	1	1870299	.	C	A	.	PASS	SOMATIC;QSS=29;TQSS=1;NT=ref;QSS_NT=29;TQSS_NT=1;SGT=CC->AC;DP=104;MQ=60;MQ0=0;ReadPosRankSum=0.65;SNVSB=0;SomaticEVS=7.19	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	71:0:0:0:5,5:66,66:0,0:0,0
#	1	2133499	.	T	C	.	PASS	SOMATIC;QSS=30;TQSS=1;NT=ref;QSS_NT=30;TQSS_NT=1;SGT=TT->CT;DP=64;MQ=60;MQ0=0;ReadPosRankSum=-0.63;SNVSB=0;SomaticEVS=11.24	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	33:1:0:0:0,0:6,7:0,0:26,26
#	1	2296529	.	G	T	.	PASS	SOMATIC;QSS=30;TQSS=1;NT=ref;QSS_NT=30;TQSS_NT=1;SGT=GG->GT;DP=139;MQ=60;MQ0=0;ReadPosRankSum=-0.18;SNVSB=0;SomaticEVS=7.33	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	91:0:0:0:0,0:0,0:85,85:6,6
#	1	2831945	.	G	T	.	PASS	SOMATIC;QSS=36;TQSS=2;NT=ref;QSS_NT=36;TQSS_NT=2;SGT=GG->GT;DP=101;MQ=60;MQ0=0;ReadPosRankSum=2.28;SNVSB=0;SomaticEVS=9.54	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	53:1:0:0:0,0:0,0:47,48:5,5
#	1	3105055	.	T	G	.	PASS	SOMATIC;QSS=78;TQSS=1;NT=ref;QSS_NT=78;TQSS_NT=1;SGT=TT->GT;DP=104;MQ=59.94;MQ0=0;ReadPosRankSum=-1.53;SNVSB=0;SomaticEVS=13.66	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	52:0:0:0:2,2:0,0:8,8:42,42
#	


bcftools view --types snps ${@} | awk 'BEGIN{ FS=OFS="\t" }
}
( /^#/ ){ next; }
{
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
		split(info["AU"],a,",")
		split(info["CU"],c,",")
		split(info["GU"],g,",")
		split(info["TU"],t,",")

		total=a[format["TQSS"]]+c[format["TQSS"]]+g[format["TQSS"]]+t[format["TQSS"]]

		if( total > 0 ) {
	
			split("",ad)
			ad["A"]=a[format["TQSS"]]
			ad["C"]=c[format["TQSS"]]
			ad["G"]=g[format["TQSS"]]
			ad["T"]=t[format["TQSS"]]
	
			ref_ad=alt_ad1=alt_ad2=alt_ad3=0

			ref_ad=ad[$4]
			delete ad[$4]
			alt_ad1=ad[$5]
			delete ad[$5]
			
			asort(ad)

			alt_ad2=ad[2]
			alt_ad3=ad[1]

			if( ref_ad > 0 && alt_ad2 > 0 )
				print $1,$2,$4, $alt2, "+", sample
		}

	}

}'
