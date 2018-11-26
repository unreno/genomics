#!/usr/bin/env python3


import numpy
import random

import sys
def printf(format, *args):
    sys.stdout.write(format % args)


#samtools view -H /raid/data/raw/20170804-Adam/sorted_BAM/186069.sorted.bam

lengths = {
	'chr1': 248956422,
	'chr2': 242193529,
	'chr3': 198295559,
	'chr4': 190214555,
	'chr5': 181538259,
	'chr6': 170805979,
	'chr7': 159345973,
	'chr8': 145138636,
	'chr9': 138394717,
	'chr10': 133797422,
	'chr11': 135086622,
	'chr12': 133275309,
	'chr13': 114364328,
	'chr14': 107043718,
	'chr15': 101991189,
	'chr16': 90338345,
	'chr17': 83257441,
	'chr18': 80373285,
	'chr19': 58617616,
	'chr20': 64444167,
	'chr21': 46709983,
	'chr22': 50818468,
	'chrX': 156040895,
	'chrY': 57227415,
	'chrM': 16569
}

#awk -F"\t" '{print $3}' hg38.hervd.20180605.OR.positions.txt | sort | uniq -c | awk '{print "'"'"'"$2"'"'"': " $1}'

counts = {
	'chr1': 1272,
	'chr2': 1150,
	'chr3': 1130,
	'chr4': 1290,
	'chr5': 984,
	'chr6': 1008,
	'chr7': 866,
	'chr8': 838,
	'chr9': 530,
	'chr10': 598,
	'chr11': 790,
	'chr12': 772,
	'chr13': 558,
	'chr14': 514,
	'chr15': 346,
	'chr16': 324,
	'chr17': 296,
	'chr18': 348,
	'chr19': 626,
	'chr20': 188,
	'chr21': 264,
	'chr22': 148,
	'chrX': 1108,
	'chrY': 752
}


#cat hg38.hervd.20180605.class.counts.txt 
#     86 HERV15-int
#   1864 HERV16-int
#    694 HERV17-int
#     44 HERV1_I-int
#     38 HERV1_LTRa
#     14 HERV1_LTRb
#     30 HERV1_LTRc
#     26 HERV1_LTRd
#     52 HERV1_LTRe
#     60 HERV30-int
#    494 HERV35I-int
#    180 HERV3-int
#    306 HERV4_I-int
#    442 HERV9-int
#    342 HERV9NC-int
#    280 HERV9N-int
#    242 HERVE_a-int
#    350 HERVE-int
#     14 HERV-Fc1-int
#     22 HERV-Fc1_LTR1
#      4 HERV-Fc1_LTR2
#      6 HERV-Fc1_LTR3
#      2 HERV-Fc2-int
#      4 HERV-Fc2_LTR
#    118 HERVFH19-int
#    106 HERVFH21-int
#    114 HERVH48-int
#   2674 HERVH-int
#     80 HERVI-int
#    188 HERVIP10B3-int
#    478 HERVIP10FH-int
#    270 HERVIP10F-int
#     60 HERVK11D-int
#    230 HERVK11-int
#     56 HERVK13-int
#     76 HERVK14C-int
#    228 HERVK14-int
#    388 HERVK22-int
#    256 HERVK3-int
#    512 HERVK9-int
#     56 HERVKC4-int
#    258 HERVK-int
#    330 HERVL18-int
#    118 HERVL32-int
#   1016 HERVL40-int
#    106 HERVL66-int
#    260 HERVL74-int
#   2856 HERVL-int
#    144 HERVP71A-int
#    126 HERVS71-int

#	HERVE
#	HERVH
#	HERVK
#	HERVL
#	HERVOther


for chromosome in sorted(counts):
#	print(chromosome);
	for i in range(counts[chromosome]):
		printf("HERV\tFAKE%d\t%s\t%d\n", random.random() * 50, chromosome, random.random() * lengths[chromosome])

#>>> random.random()
#0.6648065202192475
#>>> random.random()
#0.30982477565353106
#>>> random.random()
#0.17048873902395323
#>>> random.random()
#0.4266745235953694

#HERV	BEGIN_ERV_0000785,HERVK9-int	chr1	895510
#HERV	END_ERV_0000785,HERVK9-int	chr1	895548
#HERV	BEGIN_ERV_0001783,HERV16-int	chr1	2009838
#HERV	END_ERV_0001783,HERV16-int	chr1	2010935

