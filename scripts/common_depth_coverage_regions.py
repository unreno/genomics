#!/usr/bin/env python


import os    
#import os.path
import sys
import pandas
import numpy


#	common_depth_coverage_regions.py {HG,NA}*.NC_001664.4.depth.csv
#	common_depth_coverage_regions.py {HG,NA}*.NC_000898.1.depth.csv


#print( sys.argv[1:] )
#['20180103-awsqueue.sql', 'Makefile', 'Makefile.example', 'NA12878_SRR010942', 'PersonalGenomeProject', 'README.md', 'dev', 'docker', 'geuvadis.txt', 'notebooks', 'notes', 'oneoff', 'scripts', 'test_user_data']

#print( sys.argv[1:][0] )
#20180103-awsqueue.sql


#	~/github/unreno/genomics/dev/data_sets/1000genomes/20181010-unmapped-hhv6/hhv6.py
#	dev/data_sets/CCLS/raw/bam/bam-coverage-depth.py

#	pvalues = pandas.DataFrame(index=trinuc_muts,columns=trinuc_muts)
#d=pandas.DataFrame(columns=['position','depth'])
#d.set_index('position',inplace=True)
#d=pandas.DataFrame(columns=['position','depth'])
#df=pandas.DataFrame(data=None, index=['position'], columns=['depth'], dtype=int)
#df=pandas.DataFrame(data=None, index=['position'], columns=[], dtype=int)

df=pandas.DataFrame()
boo=pandas.DataFrame()
flagged=pandas.DataFrame()
#print( df.head() )
#print( df.dtypes )

for filename in sys.argv[1:]:
	print(filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		print("Reading "+filename)
		sample=filename.split(".")[0]	#	everything before the first "."
		d = pandas.read_csv(filename,
			sep="\t",
			header=None,
			usecols=[1,2],	# usecols=[0,1],
			#names=["position","depth"],
			#dtype={"position": int,"depth": int},
			names=["position",sample],
			dtype={"position": int, sample: int},
			index_col=["position"] )
		#print( d.head() )
		#print( d.dtypes )
		#df = df.merge( d )
		#df = pandas.concat([df, d], axis=1, sort=True )
		df = pandas.concat([df, d], axis=1)
		#df = df.append(d, axis=1)
		#.fillna(0)
		#print( df.head() )
		#print( df.dtypes )
		#d[sample]=d[sample]>100
		#d[sample] = d.apply(lambda row: row[sample] > 100 , axis=1)
		#boo = pandas.concat([boo, d], axis=1)
		#print( boo.head() )
		#print( boo.dtypes )
		#	NOPE d[sample]=( d[sample]>1 ) ? 1 : 0

		#print( "SUM" )
		#print( d.sum() )
		d[sample] = numpy.where(d[sample]>1, 1, 0)
		#d[sample] = numpy.where(d[sample]>5, 1, 0)

		flagged = pandas.concat([flagged, d], axis=1)
		#flagged = flagged.append(d, axis=1)
		print( flagged.head() )
		print( flagged.dtypes )

		#	merge
#subjects = subjects.merge( kg, left_on='Subject', right_on='subject', how='outer')

df.fillna(0, inplace=True)
#print( df.head() )
#print( df.tail() )
#print( df.dtypes )
print( df )
#print( df.mean(axis=1) )

#boo.fillna(False, inplace=True)
#print( boo.head() )
#print( boo.dtypes )
#print( boo.mean(axis=1).tail() )


flagged.fillna(0, inplace=True)
#print( flagged.head() )
#print( flagged.dtypes )
print( flagged.mean(axis=1) )

#	https://stackoverflow.com/questions/4628333/converting-a-list-of-integers-into-range-in-python
#
#	p = []
#	last = -2                                                            
#	start = -1
#
#	for item in list:
#		if item != last+1:                        
#			if start != -1:
#				p.append([start, last])
#			start = item
#		last = item
#
#	p.append([start, last])
#

common=flagged.index[ flagged.mean(axis=1) >= 0.6 ].tolist()
print( common )

if( len(common) > 0 ):
	regions=[]
	first=last=common[0]
	for item in common[1:]:
		if( item != last+1 ):
			regions.append([first,last])
			first=item

		last=item
	regions.append([first,last])
	print(regions)

	#	fill gaps less than 20 base pairs
	filled_regions=[]
	buffered=regions[0]
	for pair in regions[1:]:
		if( pair[0] < buffered[1]+20 ):
			buffered[1] = pair[1]
		else:
			filled_regions.append(buffered)
			buffered=pair
	filled_regions.append(buffered)
	print( filled_regions )
		

else:
	print("No common regions found.")



#	common_depth_coverage_regions.py HG000*.NC_001664.4.depth.csv
#	[[7717, 7728], [7730, 7765], [7871, 7877], [7908, 7921], [158982, 159028], [159039, 159058], [159060, 159066]]
#	[[7717, 7765], [7871, 7877], [7908, 7921], [158982, 159066]]

#	common_depth_coverage_regions.py HG00*.NC_001664.4.depth.csv
#	[[7707, 7971], [158991, 159253]]


#	common_depth_coverage_regions.py HG00*.NC_001664.4.depth.csv
#	[[7803, 7803], [7809, 7825], [7829, 7830], [7844, 7844], [7850, 7873], [7879, 7879], [7881, 7883], [7885, 7885], [7887, 7890], [7894, 7894], [7904, 7904], [7907, 7941], [159038, 159048], [159057, 159067], [159069, 159069], [159211, 159215], [159217, 159217], [159223, 159223]]
#	[[7803, 7941], [159038, 159069], [159211, 159223]]

#	common_depth_coverage_regions.py {HG,NA}*.NC_001664.4.depth.csv




