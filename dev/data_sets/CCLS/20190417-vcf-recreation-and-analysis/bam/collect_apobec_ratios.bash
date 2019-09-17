#!/usr/bin/env bash



#99776.recaled.mpileup.MQ60.call.SNP.DP20-200.gnomad.gAF0-0.01.Bias.AF0.30-0.50.count_trinuc_muts.counts.txt.apobec_ratio.txt

#desired_order=[ '186069', '341203', '439338', '506458', '530196', '634370', '120207', '122997', '201771', '209605', '266836', '268325', '321666', '36077', '492023', '495910', '607654', '63185', '673944', '73753', '780690', '811386', '813891', '853767', '868614', '871719', '900420', '919207', '972727', '983899', '99776', '833536', '866648', 'GM_268325', 'GM_439338', 'GM_63185', 'GM_634370', 'GM_983899' ]

echo "sample,0-0.0001;0.10-0.40,0-0.0001;0.20-0.40,0-0.001;0.10-0.40,0-0.001;0.20-0.40"

maxAF=0.40

for sample in 186069 341203 439338 506458 530196 634370 120207 122997 201771 209605 266836 268325 321666 36077 492023 495910 607654 63185 673944 73753 780690 811386 813891 853767 868614 871719 900420 919207 972727 983899 99776 833536 866648 GM_268325 GM_439338 GM_63185 GM_634370 GM_983899 ; do
echo -n $sample

base_sample=${sample/GM_/}
#echo "sample,0-0.0001;0.10-0.40,0-0.0001;0.20-0.40,0-0.001;0.10-0.40,0-0.001;0.20-0.40"

for gAF in 0.0001 0.001 ; do
for minAF in 0.10 0.20 ; do

ratio=$( cat ${base_sample}.somatic/${sample}.recaled.mpileup.MQ60.call.SNP.DP20-200.gnomad.gAF0-${gAF}.Bias.AF${minAF}-${maxAF}.count_trinuc_muts.counts.txt.apobec_ratio.txt )
echo -n ,${ratio}

done
done
echo 
done