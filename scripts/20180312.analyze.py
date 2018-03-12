#!/usr/bin/env python


import pandas
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('pair_base_name', nargs=1)
results = parser.parse_args()

#	Make it nice and wide.
plt.rcParams["figure.figsize"] = [16.0,4.0]

#	Normally 20, gives a warning that more than 20 plots have been created and not closed.
#	Upped to 30 as plotting one for each chromosome.
plt.rcParams["figure.max_open_warning"] = 30


pair_base_name = results.pair_base_name[0]


for o in 'c','m':
	for t in 'CT','GA':
		tumor = pandas.read_csv(  pair_base_name + '-01A.' + o + '.' + t + '.txt',
			delimiter="\t", header=None, names=['chr','position'])
		normal = pandas.read_csv( pair_base_name + '-10A.' + o + '.' + t + '.txt',
			delimiter="\t", header=None, names=['chr','position'])
		
		chromosomes=set(list(tumor['chr']) + list(normal['chr']))
		
		pp = PdfPages(pair_base_name + '.' + o + '.' + t + '.pdf')
		
		for c in sorted(chromosomes):
			total_length=len(tumor.loc[tumor['chr']==c]['position'])+len(normal.loc[normal['chr']==c]['position'])
			if( total_length > 50 ):
				tumor_array=np.array(tumor.loc[tumor['chr']==c]['position'])
				normal_array=np.array(normal.loc[normal['chr']==c]['position'])
				max=np.array(tumor_array.max(), normal_array.max()).max()
				tumor_hist, tumor_bin_edges = np.histogram(tumor_array, bins=100, range=(0,max))
				normal_hist, normal_bin_edges = np.histogram(normal_array, bins=100, range=(0,max))
				hist = tumor_hist - normal_hist
				width = 0.7 * (tumor_bin_edges[1] - tumor_bin_edges[0])
				center = (tumor_bin_edges[:-1] + tumor_bin_edges[1:]) / 2
				fig = plt.figure()	#	FIRST. Basically sets up a background plot
				plt.title(c)
				plt.bar(center, tumor_hist, align='center', width=width, color='#FFAAAA')
				plt.bar(center, -normal_hist, align='center', width=width, color='#AAAAFF')
				plt.bar(center, hist, align='center', width=width*0.5, color='black')
				pp.savefig( fig )
				plt.close()
		
		pp.close()

