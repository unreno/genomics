#!/usr/bin/env bash

echo -e "subject\tsample\ttotal\t\
bowtie2 HHVa\t\
bowtie2 HHVa/total\t\
bowtie2 HHVb\t\
bowtie2 HHVb/total\t\
kallisto10 HHVa\t\
kallisto10 HHVa/total\t\
kallisto10 HHVb\t\
kallisto10 HHVb/total"

#kallisto40 HHVa\t\
#kallisto40 HHVb"

for f in *.HHV6b.bowtie2.mapped.ratio_total.txt ; do
	sample=${f%.HHV6b.bowtie2.mapped.ratio_total.txt}
	subject=${sample%%.*}

	echo -e "${subject}\t${sample}\t$( cat ${sample}.total.count.txt )\t\
$( cat ${sample}.HHV6a.bowtie2.mapped.count.txt )\t\
0$( cat ${sample}.HHV6a.bowtie2.mapped.ratio_total.txt )\t\
$( cat ${sample}.HHV6b.bowtie2.mapped.count.txt )\t\
0$( cat ${sample}.HHV6b.bowtie2.mapped.ratio_total.txt )\t\
$( cat ${sample}.HHV6a.kallisto10.count.txt )\t\
$( cat ${sample}.HHV6a.kallisto10.mapped.ratio_total.txt )\t\
$( cat ${sample}.HHV6b.kallisto10.count.txt )\t\
$( cat ${sample}.HHV6b.kallisto10.mapped.ratio_total.txt )"

#$( cat ${sample}.HHV6a.kallisto40.count.txt )\t\
#$( cat ${sample}.HHV6b.kallisto40.count.txt )"
	
done

