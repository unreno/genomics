#!/usr/bin/env python

import os    
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


data_frames = []
flagged_data_frames = []

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
		data_frames.append(d)

		d[sample] = numpy.where(d[sample]>1, 1, 0)
		flagged_data_frames.append(d)

df = pandas.concat(data_frames, axis=1)
flagged = pandas.concat(flagged_data_frames, axis=1)

data_frames = []
flagged_data_frames = []


df.fillna(0, inplace=True)
print( df )

flagged.fillna(0, inplace=True)
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
#	[[7695, 7986], [158988, 159276]]
#	[[7695, 7986], [158988, 159276]]



