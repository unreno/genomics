#!/usr/bin/env bash

set -e  # exit if any command fails
set -u  # Error on usage of unset variables
set -o pipefail


cosmic_file=/raid/refs/cosmic/CosmicCLP_MutantExport_v81.tsv


wc -l ${cosmic_file}


echo "From https://academic.oup.com/jncics/article/2/1/pky002/4942295"

echo "Step 1: Download, organize, and filter raw mutation data: The fields cell line name (column 5), mutation (column 18), mutation type (column 20), version of the reference genome (column 23), chromosome position of the mutation (column 24), and DNA strand (column 25) were extracted from the “CosmicCLP_MutantExport.tsv” file using the following command:"


awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" && $5 in c ){
	print $5, $18, $20, $23, $24, $25 > $5"-Step1.tsv"
}' ${cosmic_file}
wc -l *-Step1.tsv


echo "Step 2: Removal of all non-single-base substitution mutations: All mutations that are not single-base substitutions (eg, insertions, deletions, and complex multibase substitutions) were filtered out of the table, leaving single-base substitution mutations annotated as nonsense, missense, or coding silent substitutions. This essential filtering step reduced the number of mutations in BT-474, BC-3, and NALM-6 from 1595 to 1407, 1537 to 1371, and 3291 to 2962, respectively."

echo 
echo "Not all substitutions are 1 single-base, and not all single-base mutations are substitutions."


awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" ){
	split($24,a,":");split(a[2],b,"-")
	if($20 ~ "Substitution" && b[1] == b[2] )
		print $5, $18, $20, $23, $24, $25
}' ${cosmic_file} > CosmicCLP_MutantExport-Step2.tsv

awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" && $5 in c ){
	split($24,a,":");split(a[2],b,"-")
	if($20 ~ "Substitution" && b[1] == b[2] )
		print $5, $18, $20, $23, $24, $25 > $5"-Step2.tsv"
}' ${cosmic_file}

wc -l *-Step2.tsv


echo "Step 3: Additional filtering to remove nonunique chromosomal positions and file reformatting: All nonunique chromosome positions were filtered out of each cell line individually, which ensures that each mutation has only one associated chromosomal position within a cell line. A tab-separated file was created with chromosome number (eg, “chr1”), chromosomal position, reference allele, alternate (mutant) allele, strand of the substitution, and sample (cell line name) as columns. This table was reordered as follows for subsequent analyses: chr1-chr9, chrX, chrY, chr10-chr22, then by ascending chromosomal position, and it was then saved as a text file. This step reduced mutation numbers in BT-474, BC-3, and NALM-6 from 1407 to 1021, 1371 to 963, and 2962 to 2110, respectively."


echo 
echo "I guess here were assuming that the mutation is the same?"

#	TODO

echo "This doesn't seem correct."
echo

awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" ){
	split($24,a,":");split(a[2],b,"-");
	if($20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		print a[1], b[1], substr($18,length($18)-2,1), substr($18,length($18),1), $25, $5
		seen[$24]++ 
	}
}' ${cosmic_file} > CosmicCLP_MutantExport-Step3_.tsv

awk 'BEGIN{FS="\t"; OFS="\t"; c["BC-3"]=c["BT-474"]=c["NALM-6"]=1}
( $24 != "" && $5 in c ){
	split($24,a,":");split(a[2],b,"-");
	if($20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		print a[1], b[1], substr($18,length($18)-2,1), substr($18,length($18),1), $25, $5 > $5"-Step3a.tsv";
		seen[$24]++ 
	}
}' ${cosmic_file}

for f in *-Step3a.tsv ; do n=${f/Step3a/Step3b}; sort -n $f > $n ;  done

wc -l *-Step3?.tsv




echo "Step 4: Filter out “nonmutations” and “nonmatching mutations”: The hg38 reference genome (FastA file, GCA_000001405.2) was used to filter out nonmutations and nonmatching mutations (downloaded from http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/ on July 16, 2017). Nonmutations are instances in which the alternate (mutant) allele matches the reference genome at that position. Nonmatching mutations are instances in which the reference allele does not match the reference genome at that position. These anomalies were filtered out of the single-base substitution mutation data set. This step caused a modest reduction in mutation numbers in a small number of cell lines. For instance, the numbers above for BT-474 and BC-3 were unchanged, but the number for NALM-6 reduced from 2110 to 2108. These single-base substation numbers were used to plot medians in Figure 1, and raw values are listed for each trinucleotide context in Supplementary Table 1 (available online). Following the filtering steps described above, the total single-base substitution mutation count across all cell lines was 663 075."

echo "I don't get how you could have a reference allele not matching the reference genome."

echo "The addition of 'samtools faidx' makes this script take quite a while."


echo 
echo "These use chromosome "23" and "24". I'll have to figure out what these are. X and Y I'm guessing."
echo



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
				print chr, b[1], ref1, substr($18,length($18),1), $25, $5 > $5"-Step4.tsv"; seen[$24]++
			}
		}else{
			print "Nonmatching mutation?"
			print chr, pos, $25, ref1, ref2, alt;
		}
	}
}' ${cosmic_file}

wc -l *-Step4.tsv


#Nonmutations are instances in which the alternate (mutant) allele matches the reference genome at that position. 
#Nonmatching mutations are instances in which the reference allele does not match the reference genome at that position. 





#	
#	echo "Creating CosmicCLP_MutantExport-NoSeen-Step4.tsv"
#	awk 'BEGIN{FS="\t"; OFS="\t"; 
#		comp["A"]="T";
#		comp["T"]="A";
#		comp["C"]="G";
#		comp["G"]="C";
#		comp["N"]="N";
#		c["BC-3"]=c["BT-474"]=c["NALM-6"]=1
#	}
#	( $24 != "" ){
#		split($24,a,":");split(a[2],b,"-"); 
#		if( $24 != "" && $20 ~ "Substitution" && b[1] == b[2] ){	#&& !seen[$24] ) {
#			chr=a[1];pos=b[1];
#			if(chr==23) chr="X";
#			if(chr==24) chr="Y";
#			cmd="samtools faidx /raid/refs/fasta/hg38_num_noalts.fa "chr":"pos"-"pos" | tail -1 ";
#			cmd|getline ref1;
#			close(cmd);
#			#if( length(ref1) != 1 ) print $0
#			ref2=toupper(substr($18,length($18)-2,1));
#			if($25 == "-") ref2=comp[ref2];
#			if( toupper(ref1) == ref2 ) {
#				print chr, b[1], ref1, substr($18,length($18),1), $25, $5
#	#			seen[$24]++
#			}
#		}
#	}' ${cosmic_file} > CosmicCLP_MutantExport-NoSeen-Step4.tsv
#	
#	wc -l *-Step4.tsv
#	
#	
#	echo "Creating CosmicCLP_MutantExport-Step4.tsv"
#	awk 'BEGIN{FS="\t"; OFS="\t"; 
#		comp["A"]="T";
#		comp["T"]="A";
#		comp["C"]="G";
#		comp["G"]="C";
#		comp["N"]="N";
#		c["BC-3"]=c["BT-474"]=c["NALM-6"]=1
#	}
#	( $24 != "" ){
#		split($24,a,":");split(a[2],b,"-"); 
#		if( $24 != "" && $20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
#			chr=a[1];pos=b[1];
#			if(chr==23) chr="X";
#			if(chr==24) chr="Y";
#			cmd="samtools faidx /raid/refs/fasta/hg38_num_noalts.fa "chr":"pos"-"pos" | tail -1 ";
#			cmd|getline ref1;
#			close(cmd);
#			ref2=toupper(substr($18,length($18)-2,1));
#			if($25 == "-") ref2=comp[ref2];
#			if( toupper(ref1) == ref2 ) {
#				print chr, b[1], ref1, substr($18,length($18),1), $25, $5
#				seen[$24]++
#			}
#		}
#	}' ${cosmic_file} > CosmicCLP_MutantExport-Step4.tsv
#	
#	wc -l *-Step4.tsv
#	



echo "From https://github.com/mcjarvis/Mutation-Signatures-Including-APOBEC-in-Cancer-Cell-Lines-JNCI-CS-Supplementary-Scripts/blob/master/README_mutation_processing_commands"


echo "Producing Step 4 for all cell lines ..."

# From the 5-field mutation file (chr, pos, ref, alt, sample):
#
# Execute all commands in a new directory that's one level below your perl and ref files, and contains your mutation file:
#
# 1. Split file into each separate cell line, keeping the header
#	awk  'NR==1 {h=$0; next} !seen[$5]++{ f="FILE_"FILENAME"_"$5".txt";print h > f } { print >> f; close(f)}' cosmic_mut.txt


#	This is off. The paper produces cosmic_mut.txt 
#
#	The field separator isn't defined and the data has spaces so won't parse correctly.
#	Also, and perhaps more important, $5 IS NOT THE CELL LINE NAME.
#	And lastly, the coding is wrong. f will be incorrectly set to the last cell line.
#	More, some $1 contain slashes which can't be in files.
#
#	awk ′BEGIN{FS="\t"; OFS="\t"}; 0 !∼ /^#/ {print $5, $18, $20, $23, $24, $25}′CosmicCLP_MutantExport.tsv > cosmic_mut.txt
#
#	Sample name                cell line name (column 5)
#	Mutation CDS               mutation (column 18)
#	Mutation Description       mutation type (column 20)
#	GRCh                       version of the reference genome (column 23)
#	Mutation genome position   chromosome position of the mutation (column 24)
#	strand                     DNA strand (column 25)
#
#	That is NOT (chr, pos, ref, alt, sample)
#
#	So, I assume that the output of this step are the output to the previous process's Step 4.
#
#	In addition, count_trinuc_muts_v8.pl does not appear to want the header line.
#
#
#	And the Step 4 files contain the strand column.
#	Can I just remove it?
#	Should I complement the reference and alternates if -?
#



#awk: cmd. line:15: (FILENAME=CosmicCLP_MutantExport.tsv FNR=36042) fatal: cannot open pipe `samtools faidx /raid/refs/fasta/hg38_num_noalts.fa 1:170719880-170719880 | tail -1 ' (Too many open files)
#	Gotta close the files every time we write to them, so we need to append them so we need to delete them first.

\rm -f *-Step4a.tsv

awk 'BEGIN{FS="\t"; OFS="\t"
	comp["A"]="T"
	comp["T"]="A"
	comp["C"]="G"
	comp["G"]="C"
	comp["N"]="N"
}
( $24 != "" ){
	split($24,a,":");split(a[2],b,"-")
	if( $24 != "" && $20 ~ "Substitution" && b[1] == b[2] && !seen[$24] ) {
		chr=a[1];pos=b[1]
		if(chr==23) chr="X"
		if(chr==24) chr="Y"
		cmd="samtools faidx /raid/refs/fasta/hg38_num_noalts.fa "chr":"pos"-"pos" | tail -1 "
		cmd|getline ref1
		close(cmd)
		ref1=toupper(ref1)
		ref2=toupper(substr($18,length($18)-2,1))
		if($25 == "-") ref2=comp[ref2]
		alt=toupper(substr($18,length($18),1))
		if($25 == "-") alt=comp[alt]
		if( ref1 == ref2 ) {
			if( alt == ref1 ){
				print "Nonmutation?"
				print chr, pos, $25, ref1, ref2, alt
			}else{
				file=$5
				gsub("/","_",file)
				print chr, b[1], ref1, substr($18,length($18),1), $25, $5 >> file"-Step4a.tsv"
				close(file"-Step4a.tsv"); seen[$24]++
			}
		}else{
			print "Nonmatching mutation?"
			print chr, pos, $25, ref1, ref2, alt
		}
	}
}' ${cosmic_file}

wc -l *-Step4a.tsv

echo "Sorting ..."
for f in *-Step4a.tsv ; do n=${f/Step4a/Step4b}; sort -n $f > $n ;  done



#
#	cosmic_mut.txt does not include the strand column so I will use awk to remove it
#
#	TODO May need to complement the associated reference and alternates.
#

cat *-Step4b.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$4,$6}' > cosmic_mut.txt





# 2. Run "count_trinuc_muts_v7.pl" script on every file
#	for i in *.txt; do perl ../count_trinuc_muts_v7.pl pvcf ../hg38.fa $i; done

#for i in {BC-3,BT-474,NALM-6}-Step4.tsv; do ./count_trinuc_muts_v8.pl pvcf /raid/refs/fasta/hg38_num_noalts.fa $i; done
for i in *-Step4b.tsv; do ./count_trinuc_muts_v8.pl pvcf /raid/refs/fasta/hg38_num_noalts.fa $i; done

rename 's/tsv.\d*.count/count/' *-Step4b.tsv.*.count.txt




# 3. Concatenate files together, and check that the file has the same number of mutations as the initial mutation file
#	head -1 *BA*count.txt > all.txt; tail -n +2 -q *count.txt >> all.txt



#	That doesn't make any sense, but I assume it is meant to extract a single header line and then append all the data.
#	That's not what happens though as there are multiple *BA*count.txt files.
#
#	Not sure what "all.txt" is to be used for.
#
#	Previously, I've noticed that count_trinuc_muts_v8.pl filters out some lines to the output count didn't match the input count. Perhaps 
#

#	R script is expecting a cosmic_mut_all_sort.txt which seems like this "all.txt"


head -1 $( ls *count.txt | head -1 ) > cosmic_mut_all_sort.txt
tail -n +2 -q *count.txt >> cosmic_mut_all_sort.txt





