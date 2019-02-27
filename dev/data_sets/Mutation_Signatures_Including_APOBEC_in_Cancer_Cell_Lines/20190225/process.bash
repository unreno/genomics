#!/usr/bin/env bash



wc -l CosmicCLP_MutantExport.tsv


awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" && $5 in c ){
	print $5, $18, $20, $23, $24, $25 > $5"-Step1.tsv"
}' CosmicCLP_MutantExport.tsv
wc -l *-Step1.tsv


awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" ){
	split($24,a,":");split(a[2],b,"-")
	if($20 ~ "Substitution" && b[1] == b[2] )
		print $5, $18, $20, $23, $24, $25
}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-Step2.tsv

awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" && $5 in c ){
	split($24,a,":");split(a[2],b,"-")
	if($20 ~ "Substitution" && b[1] == b[2] )
		print $5, $18, $20, $23, $24, $25 > $5"-Step2.tsv"
}' CosmicCLP_MutantExport.tsv

wc -l *-Step2.tsv



awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" ){
	split($24,a,":");split(a[2],b,"-");
	if($20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		print a[1], b[1], substr($18,length($18)-2,1), substr($18,length($18),1), $25, $5
		seen[$24]++ 
	}
}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-Step3_.tsv

awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" && $5 in c ){
	split($24,a,":");split(a[2],b,"-");
	if($20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		print a[1], b[1], substr($18,length($18)-2,1), substr($18,length($18),1), $25, $5 > $5"-Step3a.tsv";
		seen[$24]++ 
	}
}' CosmicCLP_MutantExport.tsv

for f in *-Step3a.tsv ; do n=${f/Step3a/Step3b}; sort -n $f > $n ;  done

wc -l *-Step3?.tsv





# I need to change if strand -
#	Also use toupper(...) 

#}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-Step4.tsv

echo "Creating Step4.tsv files"
awk 'BEGIN{FS="\t"; OFS="\t"; 
	comp["A"]="T";
	comp["T"]="A";
	comp["C"]="G";
	comp["G"]="C";
	comp["N"]="N";
	c["BC-3"]=c["BT-474"]=c["NALM-6"]=1
}
( $24 != "" && $5 in c ){
	split($24,a,":");split(a[2],b,"-"); 
	if( $24 != "" && $20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		chr=a[1];pos=b[1];
		if(chr==23) chr="X";
		if(chr==24) chr="Y";
		cmd="samtools faidx /raid/refs/fasta/hg38_num_noalts.fa "chr":"pos"-"pos" | tail -1 ";
		cmd|getline ref1;
		close(cmd);
		ref1=toupper(ref1)
		ref2=toupper(substr($18,length($18)-2,1));
		if($25 == "-") ref2=comp[ref2];
		alt=toupper(substr($18,length($18),1));
		if($25 == "-") alt=comp[alt];
		if( ref1 == ref2 ) {
			if( alt == ref1 ){
				print "Nonmutation?"
				print chr, pos, $25, ref1, ref2, alt;
			}else{
				print a[1], b[1], ref1, substr($18,length($18),1), $25, $5 > $5"-Step4.tsv"; seen[$24]++
			}
		}else{
			print "Nonmatching mutation?"
			print chr, pos, $25, ref1, ref2, alt;
		}
	}
}' CosmicCLP_MutantExport.tsv

wc -l *-Step4.tsv


#Nonmutations are instances in which the alternate (mutant) allele matches the reference genome at that position. 
#Nonmatching mutations are instances in which the reference allele does not match the reference genome at that position. 






echo "Creating CosmicCLP_MutantExport-NoSeen-Step4.tsv"
awk 'BEGIN{FS="\t"; OFS="\t"; 
	comp["A"]="T";
	comp["T"]="A";
	comp["C"]="G";
	comp["G"]="C";
	comp["N"]="N";
	c["BC-3"]=c["BT-474"]=c["NALM-6"]=1
}
( $24 != "" ){
	split($24,a,":");split(a[2],b,"-"); 
	if( $24 != "" && $20 ~ "Substitution" && b[1] == b[2] ){	#&& !seen[$24] ) {
		chr=a[1];pos=b[1];
		if(chr==23) chr="X";
		if(chr==24) chr="Y";
		cmd="samtools faidx /raid/refs/fasta/hg38_num_noalts.fa "chr":"pos"-"pos" | tail -1 ";
		cmd|getline ref1;
		close(cmd);
#		if( ref1 == ">:-" ) print $0
		if( length(ref1) != 1 ) print $0
		ref2=toupper(substr($18,length($18)-2,1));
		if($25 == "-") ref2=comp[ref2];
		if( toupper(ref1) == ref2 ) {
			print a[1], b[1], ref1, substr($18,length($18),1), $25, $5
#			seen[$24]++
		}
	}
}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-NoSeen-Step4.tsv


echo "Creating CosmicCLP_MutantExport-Step4.tsv"
awk 'BEGIN{FS="\t"; OFS="\t"; 
	comp["A"]="T";
	comp["T"]="A";
	comp["C"]="G";
	comp["G"]="C";
	comp["N"]="N";
	c["BC-3"]=c["BT-474"]=c["NALM-6"]=1
}
( $24 != "" ){
	split($24,a,":");split(a[2],b,"-"); 
	if( $24 != "" && $20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		chr=a[1];pos=b[1];
		if(chr==23) chr="X";
		if(chr==24) chr="Y";
		cmd="samtools faidx /raid/refs/fasta/hg38_num_noalts.fa "chr":"pos"-"pos" | tail -1 ";
		cmd|getline ref1;
		close(cmd);
		ref2=toupper(substr($18,length($18)-2,1));
		if($25 == "-") ref2=comp[ref2];
		if( toupper(ref1) == ref2 ) {
			print a[1], b[1], ref1, substr($18,length($18),1), $25, $5
			seen[$24]++
		}
	}
}' CosmicCLP_MutantExport.tsv > CosmicCLP_MutantExport-Step4.tsv


