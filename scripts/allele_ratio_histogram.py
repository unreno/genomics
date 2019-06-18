#!/usr/bin/env python


import pandas as pd


#	needed when run on a server without $DISPLAY
import matplotlib
matplotlib.use('Agg')


import matplotlib.pyplot as plt
import sys

plt.rcParams["figure.figsize"] = [18.0,8.0]

file_name = sys.argv[1]

file_name_parts=file_name.split('/')

base_name=file_name_parts[len(file_name_parts)-1]

ratios = pd.read_csv(file_name,sep='\t',
	usecols=['REF_RATIO','ALT1_RATIO','ALT2_RATIO','ALT3_RATIO'])

ratios.plot(kind='hist',title=base_name,bins=200,alpha=0.3,logy=True,xlim=(0.0,1.0))

#	Could also stack, then wouldn't need alpha
#ratios.plot(kind='hist',title=base_name,bins=200,stacked=True,logy=True)

plt.savefig(file_name+'.histogram.png')

