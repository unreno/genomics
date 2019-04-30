#!/usr/bin/env python

import pandas as pd
import numpy as np
import glob
#import os


pd.set_option('display.max_rows', None)


dfs=[]

for sample_dir in glob.iglob('*.somatic'):
	print( sample_dir )
	sample=sample_dir.split('.')[0]
	print( sample )
	vcfs=[]
	for vcf in glob.iglob( sample_dir+'/*.recaled.*.mpileup.MQ60.call.SNP.DP.annotate.GNOMAD_AF.Bias.AD.0.40/0000.vcf.gz'):
		print( vcf )
		df_vcf = pd.read_csv(vcf, comment='#', header=None, sep='\t',
			names=['CHROM','POS','ID','REF','ALT','QUAL','FILTER',sample +'_INFO','FORMAT',sample],
			index_col=['CHROM','POS'],
			usecols=['CHROM','POS',sample])
		vcfs.append( df_vcf )

	dfs.append( pd.concat( vcfs, sort=True ) )

#merged = pd.concat( dfs, axis=1 )	#, on=['CHROM','POS'] )
merged = pd.concat( dfs, axis=1, join='inner' )	#, on=['CHROM','POS'] )

print( merged.head() )

print( merged.columns )

print( merged )

#	ervcaller_bam['bam_COUNT'] = ervcaller_bam['INFO'].str.split(';',expand=True)[2].str.split('=',expand=True)[1]
#	ervcaller_bam['bam_STATUS'] = ervcaller_bam['INFO'].str.split(';',expand=True)[1].str.split(',',expand=True)[5].astype(int)
#	ervcaller_bam.drop('INFO', inplace=True, axis=column)
#	ervcaller_bam.drop(ervcaller_bam[ervcaller_bam.bam_STATUS < 3].index, inplace=True)
#	print(ervcaller_bam.head())



#		print(filepath)
#		if os.stat(filepath).st_size > 0:
#			sample=filepath.split('.')[0]
#			f = pd.read_csv(filepath, header=None, names=[sample], 
#				delim_whitespace=True,
#				index_col=[1], dtype={'count':int})
#			dfs.append(f.transpose())
#		
#	df = pd.concat(dfs,sort=True)
#	df=df.fillna(0)
#	df.sort_index(inplace=True)
#	
#	
#	print(df)
#	df.to_csv('hg38_no_alts.proper_pairs.counts.csv')
#	
#	df['total']=df.sum(axis = 1, skipna = True) 
#	
#	
