### FASTA Range Extraction with samtools

#### ALL_top.snps.final_collapsed_jake.txt

```
FILE	CHR	BP	SNP	P	A1	OR
chr2_219213441_R_PRE	1	55309587	rs113968664	1.13E-10	A	3.678
chr7_32793958_F_PRE	1	64688073	rs10489899	1.65E-08	A	4.05
...
```


One of these positions is less that 500000, so need to check and select from 1 as needed.
A range that starts with a negative number gets you nothing.

Not sure what happens if they are too close to the other end. We shall see.
It simply takes as much as exists, so yay. No special handling needed.
However, samtools does mark the read with the requested range, not the actual range.


```BASH
mkdir hg19_select
awk 'NR > 1 {
	c=( $2 == 23 ) ? "X" : $2;
	s=( $3 <= 500000 ) ? 1 : $3-500000;
	e=$3+500000;
	print "samtools faidx hg19.fa chr"c":"s"-"e " > hg19_select/chr"c":"s"-"e".fa"
}' ALL_top.snps.final_collapsed_jake.txt    |  sh -x


samtools faidx hg19.fa chr1:54809587-55809587 > hg19_select/chr1:54809587-55809587.fa
samtools faidx hg19.fa chr1:64188073-65188073 > hg19_select/chr1:64188073-65188073.fa
...
```




```BASH
cd hg19_select
ls *fa | awk '{print "bowtie2-build "$0" "substr($0,1,index($0,".")-1)}' | sh -x


bowtie2-build chr1:105542790-106542790.fa chr1:105542790-106542790
bowtie2-build chr1:111305474-112305474.fa chr1:111305474-112305474
...
```

```BASH
chmod -w *
cd ..
tar cvf - hg19_select | gzip --best > hg19_select.tar.gz
aws s3 cp hg19_select.tar.gz s3://herv/indexes/
```







#### Attaching overlappers to ALL_top.snps.final_collapsed_jake.txt


`NR` is the record number over all.

`FNR` is the record number of the current file.

so ...

`NR==FNR` essentially means the FIRST file.

`NR!=FNR` essentially means the NOT the FIRST file.

This ALL.txt file ended had trailing \r.


```BASH
gawk '
NR==FNR {
	s=$0
	gsub("\r","",s)
	gsub("\t",",",s)
	l[$2][$3]=s
}
NR!=FNR && FNR==1{
	print l["CHR"]["BP"]",absolute_position,"$0
}
NR!=FNR && FNR>1{
	FS=","
	split($1,p,"|")	#	chrX:93085499-94085499|110644|F
	sub("chr","",p[1])
	split(p[1],r,":")	#	X:93085499-94085499
	chr=(r[1]=="X")?"23":r[1]
	split(r[2],t,"-")
	print l[chr][t[2]-500000]","t[2]-500000+p[2]-1","$0
}' ALL_top.snps.final_collapsed_jake.txt overlappers.Q20.csv
```




