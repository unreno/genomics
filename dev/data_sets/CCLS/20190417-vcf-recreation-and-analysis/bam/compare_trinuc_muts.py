#!/usr/bin/env python

import glob
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
plt.rcParams["figure.figsize"] = [18.0,9.0]

import matplotlib.backends.backend_pdf
pdf = matplotlib.backends.backend_pdf.PdfPages("plots.pdf")

complements={'A':'T','C':'G','G':'C','T':'A'}
nucleotides=sorted(complements.keys())

for filepath in sorted(glob.glob('*.somatic/*.0.??.count_trinuc_muts.counts.txt')):
	print(filepath)
	filename=filepath.split('/')[1]
	print(filename)


	sample=pd.read_csv(filepath,
		header=None,
		sep='\s+',
		names=['count','trinuc'])
	sample['rc_trinuc']=''
	sample['rc_count']=0
	
	for nt1 in nucleotides:	#[0:2]:
		for nt2 in ['C','T']:	#nucleotides:
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
	sample.sort_values(by=['trinuc'], inplace=True)
	sample.reset_index(drop=True, inplace=True)
	
	sample['total']=sample['count']+sample['rc_count']
	
	sample.plot(x='trinuc', y='total', kind='bar',title=filename)
	pdf.savefig( )
	plt.close()



pdf.close()


