#!/usr/bin/env bash


#Need to change if strand -?
#toupper(ref) 

awk 'BEGIN{FS="\t"; OFS="\t"; 
	comp["A"]="T";
	comp["T"]="A";
	comp["C"]="G";
	comp["G"]="C";
	comp["N"]="N";
	c["BC-3"]=c["BT-474"]=c["NALM-6"]=1
}
( $5 in c ){ 
	split($24,a,":");split(a[2],b,"-"); 
	if($20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		chr=a[1];pos=b[1];
		if(chr==23)chr="X";
		if(chr==24)chr="Y";
		cmd="samtools faidx /raid/refs/fasta/hg38_num_noalts.fa "chr":"pos"-"pos" | tail -1 ";
		cmd|getline ref1;
		close(cmd);
		ref2=substr($18,length($18)-2,1);
		if( ref1 == ref2 ) {
			print a[1], b[1], ref1, substr($18,length($18),1), $25, $5 > $5"-Step4.tsv"; seen[$24]++
		}else{
			print chr, pos, ref1, ref2;
		}
	}
}' CosmicCLP_MutantExport.tsv

