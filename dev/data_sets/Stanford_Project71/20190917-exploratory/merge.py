#!/usr/bin/env python

import pandas as pd
import numpy as np
import glob
import os


dfs=[]

for filepath in sorted(glob.iglob('*.mature.loc.bam.counts')):
	print(filepath)
	if os.stat(filepath).st_size > 0:
		sample=filepath.split('.')[0]
		f = pd.read_csv(filepath,
			delim_whitespace=True,
			index_col=[0])
		dfs.append(f)

mature = pd.concat(dfs,sort=True,axis='columns')
mature = mature.fillna(0)
mature.sort_index(inplace=True)

mature = mature.astype(int)
mature.set_index( mature.index.astype(str).str.lower(), inplace=True )

print(mature)

mature.to_csv('mature.loc.bam.counts.csv')

#	mature.drop('total_reads',inplace=True)
#	#mature.set_index('mature-' + mature.index.astype(str), inplace=True )
#	mature.set_index( mature.index.astype(str) + '-mature', inplace=True )



dfs=[]

for filepath in sorted(glob.iglob('*.hairpin.loc.bam.counts')):
	print(filepath)
	if os.stat(filepath).st_size > 0:
		sample=filepath.split('.')[0]
		f = pd.read_csv(filepath,
			delim_whitespace=True,
			index_col=[0])
		dfs.append(f)

hairpin = pd.concat(dfs,sort=True,axis='columns')
hairpin = hairpin.fillna(0)
hairpin.sort_index(inplace=True)

hairpin = hairpin.astype(int)
hairpin.set_index( hairpin.index.astype(str).str.lower(), inplace=True )

print(hairpin)

hairpin.to_csv('hairpin.loc.bam.counts.csv')

#	hairpin.drop('total_reads',inplace=True)
#	#hairpin.set_index('hairpin-' + hairpin.index.astype(str), inplace=True )
#	hairpin.set_index( hairpin.index.astype(str) + '-hairpin', inplace=True )





#	
#	mirna = pd.concat([mature,hairpin],sort=True,axis='rows')
#	mirna = mirna.fillna(0)
#	mirna.sort_index(inplace=True)
#	
#	mirna = mirna.astype(int)
#	print(mirna)
#	
#	mirna.to_csv('mirna.loc.bam.counts.csv')
#	

dfs=[]

for filepath in sorted(glob.iglob('*.mirna.loc.bam.counts')):
	print(filepath)
	if os.stat(filepath).st_size > 0:
		sample=filepath.split('.')[0]
		f = pd.read_csv(filepath,
			delim_whitespace=True,
			index_col=[0])
		dfs.append(f)

mirna = pd.concat(dfs,sort=True,axis='columns')
mirna = mirna.fillna(0)
mirna.sort_index(inplace=True)

mirna = mirna.astype(int)
mirna.set_index( mirna.index.astype(str).str.lower(), inplace=True )

print(mirna)

mirna.to_csv('mirna.loc.bam.counts.csv')

