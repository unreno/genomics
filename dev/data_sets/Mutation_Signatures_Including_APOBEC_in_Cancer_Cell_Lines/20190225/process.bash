#!/usr/bin/env bash



wc -l CosmicCLP_MutantExport.tsv


awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $5 in c ){
	print $5, $18, $20, $23, $24, $25 > $5"-Step1.tsv"
}' CosmicCLP_MutantExport.tsv
wc -l *-Step1.tsv


awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
{
	split($24,a,":");split(a[2],b,"-")
	if($20 ~ "Substitution" && b[1] == b[2] )
		print $5, $18, $20, $23, $24, $25
}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-Step2.tsv

awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $5 in c ){
	split($24,a,":");split(a[2],b,"-")
	if($20 ~ "Substitution" && b[1] == b[2] )
		print $5, $18, $20, $23, $24, $25 > $5"-Step2.tsv"
}' CosmicCLP_MutantExport.tsv

wc -l *-Step2.tsv



awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
{
	split($24,a,":");split(a[2],b,"-");
	if($20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		print a[1], b[1], substr($18,length($18)-2,1), substr($18,length($18),1), $25, $5 > $5"-Step3a.tsv";
		seen[$24]++ 
	}
}' CosmicCLP_MutantExport.tsv

awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $5 in c ){
	split($24,a,":");split(a[2],b,"-");
	if($20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		print a[1], b[1], substr($18,length($18)-2,1), substr($18,length($18),1), $25, $5 > $5"-Step3a.tsv";
		seen[$24]++ 
	}
}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-Step3_.tsv

for f in *-Step3a.tsv ; do n=${f/Step3a/Step3b}; sort -n $f > $n ;  done

wc -l *-Step3?.tsv





# I need to change if strand -
#	Also use toupper(...) 

awk 'BEGIN{FS="\t"; OFS="\t"; 
	comp["A"]="T";
	comp["T"]="A";
	comp["C"]="G";
	comp["G"]="C";
	comp["N"]="N";
	c["BC-3"]=c["BT-474"]=c["NALM-6"]=1
}
{
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
			print chr, pos, $25, ref1, ref2;
		}
	}
}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-Step4.tsv

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
			print chr, pos, $25, ref1, ref2;
		}
	}
}' CosmicCLP_MutantExport.tsv

