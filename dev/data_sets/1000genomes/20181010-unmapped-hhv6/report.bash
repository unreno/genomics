#!/usr/bin/env bash

echo -e "subject\tunmapped\ttotal\t\
bowtie2 HHVa center\t\
bowtie2 HHVa center/unmapped\t\
bowtie2 HHVa center/total\t\
bowtie2 HHVb center\t\
bowtie2 HHVb center/unmapped\t\
bowtie2 HHVb center/total\t\
bowtie2 HHVa\t\
bowtie2 HHVa/unmapped\t\
bowtie2 HHVa/total\t\
bowtie2 HHVb\t\
bowtie2 HHVb/unmapped\t\
bowtie2 HHVb/total\t\
kallisto10 HHVa\t\
kallisto10 HHVa/total\t\
kallisto10 HHVb\t\
kallisto10 HHVb/total"

for f in *.HHV6b.bowtie2.mapped.ratio_total.txt ; do
	subject=${f%.HHV6b.bowtie2.mapped.ratio_total.txt}

	echo -e "${subject}\t$( cat ${subject}.unmapped.count.txt )\t$( cat ${subject}.total.count.txt )\t\
$( cat ${subject}.HHV6a.bowtie2.mapped_center.count.txt )\t\
0$( cat ${subject}.HHV6a.bowtie2.mapped_center.ratio_unmapped.txt )\t\
0$( cat ${subject}.HHV6a.bowtie2.mapped_center.ratio_total.txt )\t\
$( cat ${subject}.HHV6b.bowtie2.mapped_center.count.txt )\t\
0$( cat ${subject}.HHV6b.bowtie2.mapped_center.ratio_unmapped.txt )\t\
0$( cat ${subject}.HHV6b.bowtie2.mapped_center.ratio_total.txt )\t\
$( cat ${subject}.HHV6a.bowtie2.mapped.count.txt )\t\
0$( cat ${subject}.HHV6a.bowtie2.mapped.ratio_unmapped.txt )\t\
0$( cat ${subject}.HHV6a.bowtie2.mapped.ratio_total.txt )\t\
$( cat ${subject}.HHV6b.bowtie2.mapped.count.txt )\t\
0$( cat ${subject}.HHV6b.bowtie2.mapped.ratio_unmapped.txt )\t\
0$( cat ${subject}.HHV6b.bowtie2.mapped.ratio_total.txt )\t\
$( cat ${subject}.HHV6a.kallisto10.count.txt )\t\
$( cat ${subject}.HHV6a.kallisto10.mapped.ratio_total.txt )\t\
$( cat ${subject}.HHV6b.kallisto10.count.txt )\t\
$( cat ${subject}.HHV6b.kallisto10.mapped.ratio_total.txt )"

done

