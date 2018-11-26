#!/usr/bin/env python

#		import pandas
#		
#		subjects = pandas.read_csv('subjects.txt',
#			sep="\t",
#			header=None,
#			names=['subject'] ) #, index_col='subject')
#		
#		subjects=subjects.head()
#		
#		print( subjects )
#		
#		virii = pandas.read_csv('virii_details.txt',
#			sep="\t",
#			header=None,
#			names=['name']) #, index_col='name')
#		
#		virii=virii.head()
#		
#		print( virii )
#		
#		virii[['name','description']] = virii["name"].str.split(" ", 1, expand=True)
#		print( virii.head() )
#		
#		#virii = virii.reindex(columns=['name','description'])
#		#print( virii.head() )
#		
#		virii.set_index(['name','description'], inplace=True)
#		print( virii.head() )
#		
#		#virii["asdf"] = 123
#		#print( virii.head() )
#		
#		print "testing loop"
#		
#		for index,row in virii.iterrows():
#		#	print index
#		#	print row
#		#	virii[index]['asdf']=1
#			row['asdf']=1
#		
#		print virii
#		
