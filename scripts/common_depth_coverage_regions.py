#!/usr/bin/env python


import os    
#import os.path
import sys
import pandas


#	common_depth_coverage_regions.py {HG,NA}*.NC_001664.4.depth.csv
#	common_depth_coverage_regions.py {HG,NA}*.NC_000898.1.depth.csv




#print( sys.argv[1:] )
#['20180103-awsqueue.sql', 'Makefile', 'Makefile.example', 'NA12878_SRR010942', 'PersonalGenomeProject', 'README.md', 'dev', 'docker', 'geuvadis.txt', 'notebooks', 'notes', 'oneoff', 'scripts', 'test_user_data']

#print( sys.argv[1:][0] )
#20180103-awsqueue.sql



#	~/github/unreno/genomics/dev/data_sets/1000genomes/20181010-unmapped-hhv6/hhv6.py
#	dev/data_sets/CCLS/raw/bam/bam-coverage-depth.py


for filename in sys.argv[1:]:
	print(filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		print("Reading "+filename)
		d = pandas.read_csv(filename,
			sep="\t",
			header=None,
			usecols=[0,1],
			names=["position","depth"],
			index_col=["position"] )



