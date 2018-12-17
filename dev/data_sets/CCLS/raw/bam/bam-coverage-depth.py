#!/usr/bin/env python

import pandas
import matplotlib.pyplot as plt
import glob
import os.path

from matplotlib.backends.backend_pdf import PdfPages
pp = PdfPages('20181217-Bam-coverage-depth.pdf')

filename="/Users/jakewendt/github/jakewendt/notebooks/983899.recaled.bam.depth.txt.gz"

#pickle="/Users/jakewendt/github/jakewendt/notebooks/983899.recaled.bam.depth.txt.gz"
#d = pandas.read_pickle("/Users/jakewendt/github/jakewendt/notebooks/983899.recaled.bam.depth.txt.pkl")

#print(filename)
if os.path.isfile(filename): 
	d = pandas.read_csv(filename,
		sep="\t",
		header=None,
		usecols=[0,1,2],
		names=["chromosome","position","depth"],
		dtype={ "chromosome": str }
		index_col=["chromosome","position"] )

	d.to_pickle("/Users/jakewendt/github/jakewendt/notebooks/983899.recaled.bam.depth.txt.pkl")

	for idx, data in d.groupby(level=0):
		print('---')
		print(idx)
		print(data.head())

		data.fillna(0).reset_index().plot(
			title="Depth chart of chromosome "+idx,
			logy=False,kind='scatter',x='position',y='depth')	#,ylim=[1,2000])

		pp.savefig()

pp.close()



