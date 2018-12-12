#!/usr/bin/env python3

import numpy
import pandas
from scipy import stats

import sys
#print(sys.argv[1:])

#file = "186069.snps.filtered.count.with_nearests_OR.txt"
file=sys.argv[1:][0]
#print(file)

sample=file.split(".")[0]	#	everything before the first "."

log=open(file+'.log', 'w+')

df = pandas.read_csv(file, delimiter="\t")

#df = df[df['#chr'] != "chrM"]

trinuc_muts = numpy.sort(df['trinuc_mut'].unique())


#for herv in ["HERVE","HERVH","HERVK","HERVL","HERVOther"]:
for herv in ["HERVE","HERVH","HERVK","HERVL","HERVOther","HERVAny"]:
#for herv in ["HERV"]:
#	print( herv )
	log.write(herv)

	pvalues = pandas.DataFrame(index=trinuc_muts,columns=trinuc_muts)

	muts = {}
	for mut in trinuc_muts:
		mut_d = df[df['trinuc_mut'] == mut]['nearest ' + herv + ' dist']
		muts[mut] = mut_d[~numpy.isnan(mut_d)]	#	can't have any NaN's
#		print( muts[mut] )


#quit()

	for mut1 in trinuc_muts:
		log.write('\n' + mut1)
		for mut2 in trinuc_muts:
			log.write(' - ' + mut2)
			t, p = stats.ttest_ind( muts[mut1], muts[mut2] )
			pvalues[mut1][mut2] = round(p,3)
 
	
	pvalues.to_csv( sample + "." + herv + ".trinuc_mutation_comparison_pvalues.and_any.csv" )

# pvalues[COLUMN][ROW] - seems backwards, nevertheless

log.close()

