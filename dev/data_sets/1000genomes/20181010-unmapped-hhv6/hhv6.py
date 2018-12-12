#!/usr/bin/env python

import pandas
#import decimal	#	don't think that I use this anymore


subjects=pandas.read_csv('20130606_sample_info - Sample Info.csv',usecols=['Sample','Population','Gender'])

pop = pandas.read_csv('20131219.populations.tsv',sep="\t",usecols=['Population Code','Super Population'])
pop = pop.loc[pop['Population Code'].notnull()]

subjects = subjects.merge(pop,left_on='Population',right_on='Population Code',how="outer")
subjects.drop('Population Code',axis=1,inplace=True)
#del pop

subjects.rename(inplace=True, columns={ 'Sample': 'Subject' })
subjects = subjects[ ['Subject','Gender','Population','Super Population'] ]




#kg = pandas.read_csv("20181010-1000genomes-unmapped-hhv6/report.csv", sep="\t")
kg = pandas.read_csv("1kg-HHV6ab-report.csv", sep="\t")

kg.rename(inplace=True, columns={
	'unmapped':'unmapped DNA',
	'total': 'total DNA',
	'bowtie2 HHVa center': 'bowtie2 HHVa center DNA',
	'bowtie2 HHVa center/unmapped': 'bowtie2 HHVa center/unmapped DNA(xE7)',
	'bowtie2 HHVa center/total': 'bowtie2 HHVa center/total DNA(xE7)',
	'bowtie2 HHVb center': 'bowtie2 HHVb center DNA',
	'bowtie2 HHVb center/unmapped': 'bowtie2 HHVb center/unmapped DNA(xE7)',
	'bowtie2 HHVb center/total': 'bowtie2 HHVb center/total DNA(xE7)',
	'bowtie2 HHVa': 'bowtie2 HHVa DNA',
	'bowtie2 HHVa/unmapped': 'bowtie2 HHVa/unmapped DNA(xE7)',
	'bowtie2 HHVa/total': 'bowtie2 HHVa/total DNA(xE7)',
	'bowtie2 HHVb': 'bowtie2 HHVb DNA',
	'bowtie2 HHVb/unmapped': 'bowtie2 HHVb/unmapped DNA(xE7)',
	'bowtie2 HHVb/total': 'bowtie2 HHVb/total DNA(xE7)',
	'kallisto10 HHVa': 'kallisto10 HHVa DNA',
	'kallisto10 HHVa/total': 'kallisto10 HHVa/total DNA(xE7)',
	'kallisto10 HHVb': 'kallisto10 HHVb DNA',
	'kallisto10 HHVb/total': 'kallisto10 HHVb/total DNA(xE7)' })


subjects = subjects.merge( kg, left_on='Subject', right_on='subject', how='outer')
subjects.drop('subject',inplace=True,axis=1)

geu = pandas.read_csv("gEUVADIS-HHV6ab-report.csv", sep="\t")

geu.rename(inplace=True, columns={
	'total': 'total RNA',
	'bowtie2 HHVa': 'bowtie2 HHVa RNA',
	'bowtie2 HHVa/total': 'bowtie2 HHVa/total RNA(xE7)',
	'bowtie2 HHVb': 'bowtie2 HHVb RNA',
	'bowtie2 HHVb/total': 'bowtie2 HHVb/total RNA(xE7)',
	'kallisto10 HHVa': 'kallisto10 HHVa RNA',
	'kallisto10 HHVa/total': 'kallisto10 HHVa/total RNA(xE7)',
	'kallisto10 HHVb': 'kallisto10 HHVb RNA',
	'kallisto10 HHVb/total': 'kallisto10 HHVb/total RNA(xE7)'})

subjects = subjects.merge( geu, left_on='Subject', right_on='subject', how='outer')
subjects.drop('subject',inplace=True,axis=1)





vcf = pandas.read_csv("1kg-HHV6.snps.csv", sep="\t")
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT ........
vcf.drop(columns=["#CHROM","POS","REF","ALT","QUAL","FILTER","INFO","FORMAT"],inplace=True)
vcf.set_index("ID",inplace=True)
vcf=vcf.transpose()


subjects = subjects.merge( vcf, left_on='Subject', right_index=True, how='outer')



#pandas.set_option('display.max_columns', None)

#	As I have been unable to control the actual exponent, 
subjects['bowtie2 HHVa/unmapped DNA(xE7)'] = subjects['bowtie2 HHVa/unmapped DNA(xE7)'] * 1E7
subjects['bowtie2 HHVb/unmapped DNA(xE7)'] = subjects['bowtie2 HHVb/unmapped DNA(xE7)'] * 1E7
subjects['bowtie2 HHVa/total DNA(xE7)'] =    subjects['bowtie2 HHVa/total DNA(xE7)'] * 1E7
subjects['bowtie2 HHVa/total RNA(xE7)'] =    subjects['bowtie2 HHVa/total RNA(xE7)'] * 1E7
subjects['bowtie2 HHVb/total DNA(xE7)'] =    subjects['bowtie2 HHVb/total DNA(xE7)'] * 1E7
subjects['bowtie2 HHVb/total RNA(xE7)'] =    subjects['bowtie2 HHVb/total RNA(xE7)'] * 1E7

subjects['bowtie2 HHVa center/unmapped DNA(xE7)'] = subjects['bowtie2 HHVa center/unmapped DNA(xE7)'] * 1E7
subjects['bowtie2 HHVb center/unmapped DNA(xE7)'] = subjects['bowtie2 HHVb center/unmapped DNA(xE7)'] * 1E7
subjects['bowtie2 HHVa center/total DNA(xE7)'] =    subjects['bowtie2 HHVa center/total DNA(xE7)'] * 1E7
subjects['bowtie2 HHVb center/total DNA(xE7)'] =    subjects['bowtie2 HHVb center/total DNA(xE7)'] * 1E7

subjects['kallisto10 HHVa/total DNA(xE7)'] = subjects['kallisto10 HHVa/total DNA(xE7)'] * 1E7
subjects['kallisto10 HHVb/total DNA(xE7)'] = subjects['kallisto10 HHVb/total DNA(xE7)'] * 1E7
subjects['kallisto10 HHVa/total RNA(xE7)'] = subjects['kallisto10 HHVa/total RNA(xE7)'] * 1E7
subjects['kallisto10 HHVb/total RNA(xE7)'] = subjects['kallisto10 HHVb/total RNA(xE7)'] * 1E7

subjects = subjects[ ['Subject','Gender','Population','Super Population',
	'rs4774', 'rs3087456',
	'unmapped DNA', 'total DNA', 'sample', 'total RNA', 

	'bowtie2 HHVa center/unmapped DNA(xE7)', 
	'bowtie2 HHVa center/total DNA(xE7)',
	'bowtie2 HHVa center DNA',
	'bowtie2 HHVa DNA', 'kallisto10 HHVa DNA', #	'kallisto40 HHVa DNA', 

	'bowtie2 HHVb center/unmapped DNA(xE7)', 
	'bowtie2 HHVb center/total DNA(xE7)',
	'bowtie2 HHVb center DNA',
	'bowtie2 HHVb DNA', 'kallisto10 HHVb DNA', #	'kallisto40 HHVb DNA',

	'bowtie2 HHVa/unmapped DNA(xE7)', 
	'bowtie2 HHVa/total DNA(xE7)', 'kallisto10 HHVa/total DNA(xE7)', 
	'bowtie2 HHVa/total RNA(xE7)', 'kallisto10 HHVa/total RNA(xE7)', 

	'bowtie2 HHVb/unmapped DNA(xE7)', 
	'bowtie2 HHVb/total DNA(xE7)', 'kallisto10 HHVb/total DNA(xE7)', 
	'bowtie2 HHVb/total RNA(xE7)', 'kallisto10 HHVb/total RNA(xE7)', 

	'bowtie2 HHVa RNA', 'kallisto10 HHVa RNA', #	'kallisto40 HHVa RNA', 

	'bowtie2 HHVb RNA', 'kallisto10 HHVb RNA' #	'kallisto40 HHVb RNA'
] ]


#	when a column contains numbers and blanks,
#	apparently the blanks are converted to NA and the data type is float
#	I just want integers, which apparently, cannot be blank or NA

#merged[['kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA',
#	'kallisto40 HHVa DNA', 'kallisto40 HHVb DNA', 'kallisto40 HHVa RNA', 'kallisto40 HHVb RNA'
#]] = merged[['kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA',
#	'kallisto40 HHVa DNA', 'kallisto40 HHVb DNA', 'kallisto40 HHVa RNA', 'kallisto40 HHVb RNA'
#]].fillna(0.0).astype(int)

#subjects[['unmapped DNA','total DNA','total RNA','bowtie2 HHVa DNA','bowtie2 HHVa RNA','bowtie2 HHVb DNA','bowtie2 HHVb RNA','kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA' ]] = subjects[['unmapped DNA','total DNA','total RNA','bowtie2 HHVa DNA','bowtie2 HHVa RNA','bowtie2 HHVb DNA','bowtie2 HHVb RNA','kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA' ]].fillna(0.0).astype(int)
#subjects[['total DNA','total RNA','bowtie2 HHVa DNA','bowtie2 HHVa RNA','bowtie2 HHVb DNA','bowtie2 HHVb RNA','kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA' ]] = subjects[['total DNA','total RNA','bowtie2 HHVa DNA','bowtie2 HHVa RNA','bowtie2 HHVb DNA','bowtie2 HHVb RNA','kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA' ]].fillna(0.0).astype(int)
#subjects[['bowtie2 HHVa DNA','bowtie2 HHVa RNA','bowtie2 HHVb DNA','bowtie2 HHVb RNA','kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA' ]] = subjects[['bowtie2 HHVa DNA','bowtie2 HHVa RNA','bowtie2 HHVb DNA','bowtie2 HHVb RNA','kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA' ]].fillna(0.0).astype(int)


#subjects['unmapped DNA'] = subjects['unmapped DNA'].round(0)


#subjects.to_csv(formatters={'unmapped DNA':'${:,.0f}'.format})


dp0 = lambda col: "{:.0f}".format(col)
dp2 = lambda col: "{:.2f}".format(col)

#	Tried doing this in one block
#		subjects[['unmapped DNA', 'total DNA', 'total RNA']].apply(dp0)
#	TypeError: ('unsupported format string passed to Series.__format__', 'occurred at index unmapped DNA')


for column in ['unmapped DNA', 'total DNA', 'total RNA', 
		'bowtie2 HHVa DNA', 'bowtie2 HHVa RNA', 'bowtie2 HHVb DNA', 'bowtie2 HHVb RNA', 
		'bowtie2 HHVa center DNA', 'bowtie2 HHVb center DNA',
		'kallisto10 HHVa DNA', 'kallisto10 HHVb DNA', 'kallisto10 HHVa RNA', 'kallisto10 HHVb RNA' ]:
	subjects[column] = subjects[column].apply(dp0)

for column in [ 
		'bowtie2 HHVa center/unmapped DNA(xE7)', 'bowtie2 HHVa center/total DNA(xE7)',
		'bowtie2 HHVb center/unmapped DNA(xE7)', 'bowtie2 HHVb center/total DNA(xE7)',
		'bowtie2 HHVa/unmapped DNA(xE7)', 
		'bowtie2 HHVa/total DNA(xE7)', 'kallisto10 HHVa/total DNA(xE7)', 
		'bowtie2 HHVa/total RNA(xE7)', 'kallisto10 HHVa/total RNA(xE7)', 
		'bowtie2 HHVb/unmapped DNA(xE7)', 
		'bowtie2 HHVb/total DNA(xE7)', 'kallisto10 HHVb/total DNA(xE7)', 
		'bowtie2 HHVb/total RNA(xE7)', 'kallisto10 HHVb/total RNA(xE7)' ]:
	subjects[column] = subjects[column].apply(dp2)

subjects.replace(to_replace='nan', value='', inplace=True)


subjects.sort_values(by=['Subject','sample'],inplace=True)

#subjects.to_csv('hhv6.csv', float_format='%.2f', index=False)
subjects.to_csv('hhv6.csv', index=False)

