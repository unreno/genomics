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

#/home/jake/.local/lib/python3.5/site-packages/pandas/core/ops.py:1649: FutureWarning: elementwise comparison failed; returning scalar instead, but in the future will perform elementwise comparison

#				mut_row=sample[sample['trinuc'] == mut]
#				rcmut_row=sample[sample['trinuc'] == rcmut]
#				#	I'm guessing that there is a nan in there. converting to str makes warning go away
#				mut_row=sample.loc[sample['trinuc'].astype(str) == mut]
#				rcmut_row=sample.loc[sample['trinuc'].astype(str) == rcmut]
				mut_row=sample[sample['trinuc'].astype(str) == mut]
				rcmut_row=sample[sample['trinuc'].astype(str) == rcmut]


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

total_total = sample['total'].sum()

sample['ratio']=sample['total']/total_total

print( sample )

sample.to_csv(file_name+'.ratios.csv', index=False)


#	https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4758883/
#However, if unrestrained, APOBEC enzymes can also act as potent mutators of chromosomal DNA, where they deaminate cytidines preferentially within the trinucleotide sequences, TCA and TCT (referred to collectively as TCW; the mutated base is underlined) (Refsland and Harris, 2013). Consequently, APOBEC-mutagenized tumors contain an over-abundance of C to T and C to G substitutions within TCW sequences (Roberts et al., 2013, Alexandrov et al., 2013, Burns et al., 2013b). This mutatio

apobec_mutations=[ 'T[C>G]A', 'T[C>T]A', 'T[C>G]T', 'T[C>T]T' ]

apobec = sample.loc[sample['trinuc'].isin(apobec_mutations)]

print(apobec)

print()
print("Total APOBEC-related ratio: "+apobec['ratio'].sum().astype(str))
print()


with open(file_name+'.apobec_ratio.txt', 'w') as writer:
	writer.write( apobec['ratio'].sum().astype(str) )


#sample.plot(x='trinuc', y='total', kind='bar', title=base_name )

#plt.savefig(file_name+'.plot.png')

