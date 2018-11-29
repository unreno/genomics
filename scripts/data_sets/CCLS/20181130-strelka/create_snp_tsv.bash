#!/usr/bin/env bash


for f in */results/variants/somatic.snvs.vcf.gz ; do
base=${f%/results/*}
echo $f $base
outfile="$base.snp.tsv"
#echo -e "CHROM\tPOS\tREF\tALT\tQUAL\tAN\tDB\tQD\tMQ\tFMT/DP\tFMT/GQ\tFS\tMQRankSum\tReadPosRankSum" > $outfile
#bcftools query -i 'TYPE="snp"' -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%AN\t%DB\t%QD\t%MQ\t[%DP]\t[%GQ]\t%FS\t%MQRankSum\t%ReadPosRankSum\n' $f >> $outfile &
echo -e "CHROM\tPOS\tREF\tALT\tQUAL\tMQ\tFMT/DP\tReadPosRankSum" > $outfile
bcftools query -i 'TYPE="snp"' -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%MQ\t[%DP]\t%ReadPosRankSum\n' $f >> $outfile &
done

