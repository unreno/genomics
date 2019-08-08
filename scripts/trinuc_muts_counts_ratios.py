#!/usr/bin/env python

import sys
import pandas as pd

#	needed when run on a server without $DISPLAY
#import matplotlib
#matplotlib.use('Agg')

#import matplotlib.pyplot as plt
#plt.rcParams["figure.figsize"] = [18.0,9.0]

complements={'A':'T','C':'G','G':'C','T':'A'}
nucleotides=sorted(complements.keys())


file_name = sys.argv[1]

print(file_name)

file_name_parts=file_name.split('/')

base_name=file_name_parts[len(file_name_parts)-1]

print(base_name)


sample=pd.read_csv(file_name,
	header=None,
	sep='\s+',
	names=['count','trinuc'])
sample['rc_trinuc']=''
sample['rc_count']=0



for nt1 in nucleotides:
	for nt2 in ['C','T']:
		for nt3 in nucleotides:
			if( nt2 == nt3 ):
				continue
			for nt4 in nucleotides:
				mut=nt1+'['+nt2+'>'+nt3+']'+nt4
				rcmut=complements[nt4]+'['+complements[nt2]+'>'+complements[nt3]+']'+complements[nt1]

				mut_row=sample[sample['trinuc'] == mut]
				rcmut_row=sample[sample['trinuc'] == rcmut]

				mut_row_count=len(mut_row)
				rcmut_row_count=len(rcmut_row)

				if rcmut_row_count == 0:
					rcmut_count=0 
				else:
					rcmut_count=rcmut_row.iloc[0]['count']

				if mut_row_count == 0:
					mut_count=0 
					sample=sample.append({ 'trinuc': mut, 'count': 0,
						'rc_trinuc': rcmut, 'rc_count': rcmut_count }, ignore_index=True)
				else:
					mut_count=mut_row.iloc[0]['count']
					sample.at[mut_row.index,'rc_trinuc'] = rcmut
					sample.at[mut_row.index,'rc_count'] = rcmut_count
			
sample.drop(sample[sample['rc_trinuc']==''].index, inplace=True)
sample['nt1'] = sample['trinuc'].str[0]
sample['nt2'] = sample['trinuc'].str[2]
sample['nt3'] = sample['trinuc'].str[4]
sample['nt4'] = sample['trinuc'].str[6]

sample.sort_values(by=['nt2','nt3','nt1','nt4'], inplace=True)

sample.reset_index(drop=True, inplace=True)

sample['total']=sample['count']+sample['rc_count']

total_total = sample.total.sum()

print(sample)


#sample.plot(x='trinuc', y='total', kind='bar', title=base_name )

#plt.savefig(file_name+'.plot.png')

