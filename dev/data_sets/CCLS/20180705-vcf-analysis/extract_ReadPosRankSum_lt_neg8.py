#!/usr/bin/env python3

#import numpy
import pandas

import sys

#file = "186069.snp.tsv"
file=sys.argv[1:][0]

sample=file.split(".")[0] # everything before the first "."

#df = pandas.read_csv(file, delimiter="\t", dtype={ 'CHROM': str, 'QD': float }, na_values = ".")

df = pandas.read_csv(file, delimiter="\t", dtype={ 'CHROM': str }, na_values = ".")

df = df[pandas.isna(df['DB'])]

df = df[ df['ReadPosRankSum'] <  -8.0 ]

df.to_csv( sample + ".ReadPosRankSum_lt_neg8.tsv",columns=["CHROM","POS","REF","ALT"],index=False,sep="\t")

