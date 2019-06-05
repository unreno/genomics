#!/usr/bin/env python

import numpy as np
import pandas as pd

#	needed when run on a server without $DISPLAY
import matplotlib
matplotlib.use('Agg')


import matplotlib.pyplot as plt
import sys

from scipy.optimize import curve_fit
def func(x, a, b, c):
	return a * np.exp(-b * x) + c

plt.rcParams["figure.figsize"] = [18.0,8.0]

file_name = sys.argv[1]

file_name_parts=file_name.split('/')

base_name=file_name_parts[len(file_name_parts)-1]

counts = pd.read_csv(file_name,sep=',',
	index_col='AD',
#	usecols=['AD','tumor','normal'])
	usecols=['AD','tumor','normal','shared'])

#	counts.plot(use_index=True,title=base_name)
#	counts.diff().drop(0.20,axis='index').plot(use_index=True,title=base_name)
#	counts.diff().drop(0.20,axis='index').diff().drop(0.21,axis='index').plot(use_index=True,title=base_name)

counts['diff'] = counts['normal'] + counts['tumor']
counts.drop(['normal','tumor'], axis='columns',inplace=True)
print(counts.head())


counts = counts.diff().drop(0.20,axis='index')
print(counts.head())




plt.scatter(counts.index,counts['shared'], 
	color='blue',
	label='shared')
plt.scatter(counts.index,counts['diff'], 
	color='red',
	label='diff')

popt, pcov = curve_fit(func, counts.index, counts['shared'])
plt.plot(counts.index,func(counts.index, *popt),
	color='green',
	label='shared fit: a=%5.3f, b=%5.3f, c=%5.3f' % tuple(popt))

popt, pcov = curve_fit(func, counts.index, counts['diff'])
plt.plot(counts.index,func(counts.index, *popt), 
	color='orange',
	label='diff fit: a=%5.3f, b=%5.3f, c=%5.3f' % tuple(popt))



#	plt.scatter(counts.index,counts['tumor'], 
#		color='blue',
#		label='tumor')
#	plt.scatter(counts.index,counts['normal'], 
#		color='red',
#		label='normal')
#	
#	
#	popt, pcov = curve_fit(func, counts.index, counts['tumor'])
#	plt.plot(counts.index,func(counts.index, *popt),
#		color='green',
#		label='tumor fit: a=%5.3f, b=%5.3f, c=%5.3f' % tuple(popt))
#	
#	popt, pcov = curve_fit(func, counts.index, counts['normal'])
#	plt.plot(counts.index,func(counts.index, *popt), 
#		color='orange',
#		label='normal fit: a=%5.3f, b=%5.3f, c=%5.3f' % tuple(popt))





plt.legend()
plt.show()

plt.savefig(file_name+'.png')





quit()




for csv in *.somatic/tumor-normal-isec-counts.csv ; do
plot-tumor-normal-isec-counts.py ${csv}
done

ll *somatic/tumor-normal-isec-counts.csv.png

open *somatic/tumor-normal-isec-counts.csv.png



