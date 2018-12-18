#!/usr/bin/env python

#	
import matplotlib
# Force matplotlib to not use any Xwindows backend.
#	to avoid error ...
#	_tkinter.TclError: no display name and no $DISPLAY environment variable
matplotlib.use('Agg')

import pandas
import matplotlib.pyplot as plt
plt.rcParams['scatter.marker'] = '.'
plt.rcParams['scatter.markersize'] = 1


import glob
import os.path

from matplotlib.backends.backend_pdf import PdfPages
pp = PdfPages('bam-coverage-depth.pdf')

#filename="/raid/data/raw/CCLS/bam/983899.recaled.bam.depth.txt.gz"

#pickle_filename="/raid/data/raw/CCLS/bam/983899.recaled.bam.depth.txt.gz"
#d = pandas.read_pickle(pickle_filename)


#print(filename)
#if os.path.isfile(filename): 
#	print("Reading "+filename)
#	d = pandas.read_csv(filename,
#		sep="\t",
#		header=None,
#		usecols=[1,2],
#		names=["position","depth"],
#		index_col=["position"] )
#
##		usecols=[0,1,2],
##		names=["chromosome","position","depth"],
##		dtype={ "chromosome": str },
##		index_col=["chromosome","position"] )
#
##		dtype={ "chromosome": str },
##	
##OverflowError: value too large to convert to int
##	explicitly setting position and depth to uint64 to try to loat. No such thing as uint64 or int64
##
##	Split depth file into chromosome specific with just position and depth
##
##	zcat /raid/data/raw/CCLS/bam/983899.recaled.bam.depth.txt.gz | awk -F"\t" '{ print $2"\t"$3 >> FILENAME.$1.txt }'
##	FILENAME is - when reading from STDIN
##	zcat 983899.recaled.bam.depth.txt.gz | awk -F"\t" '{ print $2"\t"$3 >> "983899.recaled.bam.depth."$1".txt" }' &
#
#
#
##	print("Writing "+pickle_filename)
##	d.to_pickle(pickle_filename)
#
#	print("Plotting")
#	for idx, data in d.groupby(level=0):
#		print('---')
#		print(idx)
#		print(data.head())
#
#		data.fillna(0).reset_index().plot(
#			title="Depth chart of chromosome "+idx,
#			logy=False,kind='scatter',x='position',y='depth')	#,ylim=[1,2000])
#
#		pp.savefig()


chromosomes="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT".split()

#chromosomes="Y MT".split()

for chromosome in chromosomes:
	filename="/raid/data/raw/CCLS/bam/983899.recaled.bam.depth."+chromosome+".txt.gz"
	#print(filename)
	#for filename in glob.iglob("/raid/data/raw/CCLS/bam/983899.recaled.bam.depth.*.txt.gz"):
	print(filename)

	if os.path.isfile(filename): 
		print("Reading "+filename)
		d = pandas.read_csv(filename,
			sep="\t",
			header=None,
			usecols=[0,1],
			names=["position","depth"],
			index_col=["position"] )

#/home/jake/.local/lib/python2.7/site-packages/numpy/lib/arraysetops.py:522: FutureWarning: elementwise comparison failed; returning scalar instead, but in the future will perform elementwise comparison
#  mask |= (ar1 == a)

		print("Plotting")

		d.fillna(0).reset_index().plot(
			title="Depth chart of chromosome "+chromosome,
			logy=False,kind='scatter',x='position',y='depth')	#,ylim=[1,2000])

			#marker='.', #markersize=1,

		pp.savefig()

pp.close()



