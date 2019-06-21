#!/usr/bin/env bash

#
#	DESIGNED FOR SNPs ONLY
#	DESIGNED FOR STRELKA VCFs ONLY
#
#	bcftools view -i "TYPE='SNP'" STRELKA.vcf.gz | awk -f ./strelka_vcf_to_allele_ratios.awk 
#
#	1	1130964	.	G	T	.	PASS
#	SOMATIC;QSS=36;TQSS=1;NT=ref;QSS_NT=36;TQSS_NT=1;SGT=GG->GT;DP=115;MQ=60;MQ0=0;ReadPosRankSum=0.94;SNVSB=0;SomaticEVS=9.2
#	DP:FDP:SDP:SUBDP:AU:CU:GU:TU
#	67:0:0:0:0,0:0,0:62,62:5,5
#	1	1266389	.	C	A	.	PASS
#	SOMATIC;QSS=31;TQSS=2;NT=ref;QSS_NT=31;TQSS_NT=2;SGT=CC->AC;DP=103;MQ=60;MQ0=0;ReadPosRankSum=-0.32;SNVSB=0;SomaticEVS=8.36
#	DP:FDP:SDP:SUBDP:AU:CU:GU:TU
#	58:3:0:0:5,5:50,54:0,0:0,0

bcftools view --types snps ${@} | awk 'BEGIN{ FS=OFS="\t" 
	print "CHROM","POS","REF","TRIREF","DP","A","C","G","T"
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
	
			samtools = "samtools faidx /raid/refs/fasta/hg38.num.fa "$1":"$2-1"-"$2+1" "
			while(samtools | getline triref ){};
			close(samtools);

			#print $0

			#print "CHROM","POS","REF","TRIREF","DP","A","C","G","T"
			print $1, $2, $4, toupper(triref), total, ad["A"], ad["C"], ad["G"], ad["T"]
		}
	}
}'
