#!/usr/bin/env python

import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
plt.rcParams["figure.figsize"] = [18.0,9.0]

import matplotlib.backends.backend_pdf
pdf = matplotlib.backends.backend_pdf.PdfPages("plots.pdf")

complements={'A':'T','C':'G','G':'C','T':'A'}
nucleotides=sorted(complements.keys())

for file in '983899.somatic/983899.count_trinuc_muts.counts.txt', '983899.somatic/983899_strelka.count_trinuc_muts.counts.txt':

	tumor=pd.read_csv(file,
		header=None,
		sep='\s+',
		names=['count','trinuc'])
	tumor['rc_trinuc']=''
	tumor['rc_count']=0
	
	for nt1 in nucleotides:	#[0:2]:
		for nt2 in ['C','T']:	#nucleotides:
			for nt3 in nucleotides:
				if( nt2 == nt3 ):
					continue
				for nt4 in nucleotides:
					mut=nt1+'['+nt2+'>'+nt3+']'+nt4
					rcmut=complements[nt4]+'['+complements[nt2]+'>'+complements[nt3]+']'+complements[nt1]
	
					mut_row=tumor[tumor['trinuc'] == mut]
					rcmut_row=tumor[tumor['trinuc'] == rcmut]
	
					mut_row_count=len(mut_row)
					rcmut_row_count=len(rcmut_row)
	
					if rcmut_row_count == 0:
						rcmut_count=0 
					else:
						rcmut_count=rcmut_row.iloc[0]['count']
	
					if mut_row_count == 0:
						mut_count=0 
						tumor=tumor.append({ 'trinuc': mut, 'count': 0,
							'rc_trinuc': rcmut, 'rc_count': rcmut_count }, ignore_index=True)
					else:
						mut_count=mut_row.iloc[0]['count']
						tumor.at[mut_row.index,'rc_trinuc'] = rcmut
						tumor.at[mut_row.index,'rc_count'] = rcmut_count
				
	tumor.drop(tumor[tumor['rc_trinuc']==''].index, inplace=True)
	tumor.sort_values(by=['trinuc'], inplace=True)
	tumor.reset_index(drop=True, inplace=True)
	
	tumor['total']=tumor['count']+tumor['rc_count']
	
	tumor.plot(x='trinuc', y='total', kind='bar',title=file)
	pdf.savefig( )
	plt.close()



pdf.close()


