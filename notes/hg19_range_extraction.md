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
mkdir hg19
awk 'NR > 1 {
	c=( $2 == 23 ) ? "X" : $2;
	s=( $3 <= 500000 ) ? 1 : $3-500000;
	e=$3+500000;
	print "samtools faidx hg19.fa chr"c":"s"-"e " > hg19/chr"c":"s"-"e".fa"
}' ALL_top.snps.final_collapsed_jake.txt    |  sh -x


samtools faidx hg19.fa chr1:54809587-55809587 > hg19/chr1:54809587-55809587.fa
samtools faidx hg19.fa chr1:64188073-65188073 > hg19/chr1:64188073-65188073.fa
...
```




```BASH
cd hg19
ls *fa | awk '{print "bowtie2-build "$0" "substr($0,1,index($0,".")-1)}' | sh -x


bowtie2-build chr1:105542790-106542790.fa chr1:105542790-106542790
bowtie2-build chr1:111305474-112305474.fa chr1:111305474-112305474
...
```


