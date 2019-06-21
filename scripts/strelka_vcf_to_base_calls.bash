#!/usr/bin/env bash

#
#	DESIGNED FOR SNPs ONLY
#	DESIGNED FOR STRELKA VCFs ONLY
#
#	bcftools view -i "TYPE='SNP'" STRELKA.vcf.gz | awk -f ./strelka_vcf_to_allele_ratios.awk 
#
#  samtools = "samtools faidx /raid/refs/fasta/hg38.fa "$1":"$2-2"-"$2+2" "
#  while(samtools | getline x ){};
#  close(samtools);
#  print $1,$2,$3,$4,toupper(x)

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
	
			samtools = "samtools faidx /raid/refs/fasta/hg38.fa "$1":"$2-2"-"$2+2" "
			while(samtools | getline triref ){};
			close(samtools);

			#print "CHROM","POS","REF","TRIREF","DP","A","C","G","T"
			print $1, $2, $4, toupper(triref), total, ad["A"], ad["C"], ad["G"], ad["T"]
		}
	}
}'
