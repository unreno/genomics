#!/usr/bin/env bash

for f in /raid/data/raw/20170804-Adam/VCF/*.output-hc.vcf ; do
b=${f%.output-hc.vcf}
b=${b##*/}
echo $f $b
outfile="$b.indel.tsv"
echo -e "CHROM\tPOS\tREF\tALT\tQUAL\tAN\tDB\tQD\tMQ\tFMT/DP\tFMT/GQ\tFS\tMQRankSum\tReadPosRankSum" > $outfile
bcftools query -i 'TYPE="INDEL"' -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%AN\t%DB\t%QD\t%MQ\t[%DP]\t[%GQ]\t%FS\t%MQRankSum\t%ReadPosRankSum\n' $f >> $outfile &
done


