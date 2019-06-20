#!/usr/bin/env python

import numpy as np
import pandas as pd

hkles=['HERV_K113','SVA_A','SVA_B','SVA_C','SVA_D','SVA_E','SVA_F']
statuses=['paired','unpaired']

groups = {
	'insertion_points': 'insertion_points_table.hg38.chr6.Q20.sorted',
	'overlappers': 'overlappers_table.hg38.chr6.Q20'
}


for key in groups.keys():
	dfs=[]
	grouped_dfs=[]
	for status in statuses:
		for hkle in hkles:
			df = pd.read_csv('20190424-HKLE-chimera-'+hkle+'-hg38.chr6/working_dir/'+status+'_'+groups[key]+'.csv')
	
			df['hkle'] = hkle
			df['status'] = status
	
			df.rename(index=str, columns={'position': 'original_position'},inplace=True)

			print(df.head())

			print(df['original_position'])

			if( len(df.index) > 0 ):
	
				df['position']  = df['original_position'].str.split('|',expand=True)[1].astype(int)
				df['direction'] = df['original_position'].str.split('|',expand=True)[2]	#	F, R, FR, RF
				#df['relation']  = df['original_position'].str.split('|',expand=True)[3]	#	pre or post
	
				dfs.append(df)
	
				print("Raw shape")
				print(df.shape)

				grouped_df = df.groupby( [pd.cut(df['position'], np.arange(0, 180000000+1, 10000)),'hkle','status','direction'] ).sum()
				grouped_df = grouped_df[grouped_df['position'] >= 0]
				grouped_df.drop('position',axis='columns',inplace=True)

				print(grouped_df.head())
				grouped_dfs.append(grouped_df)
				print("Grouped shape")
				print(grouped_df.shape)

	
	all=pd.concat(dfs,sort=True)
	all.drop('original_position',axis='columns',inplace=True)
	
	all.fillna(0,inplace=True)
	for col in all:
		#if( str(col) not in ['position','hkle','status','direction','relation'] ):
		if( str(col) not in ['position','hkle','status','direction'] ):
			all[col] = all[col].astype(int)
	
	#all.set_index(['position','hkle','status','direction','relation'],inplace=True)
	#all.sort_values(by=['position','hkle','status','direction','relation'],inplace=True)
	all.set_index(['position','hkle','status','direction'],inplace=True)
	all.sort_values(by=['position','hkle','status','direction'],inplace=True)
	
	print(all.shape)
	print(all.head(50))
	
	all.to_csv('hkle_'+key+'.csv')


	all=pd.concat(grouped_dfs,sort=True)
#	all.drop('original_position',axis='columns',inplace=True)
	
	all.fillna(0,inplace=True)
	for col in all:
		if( str(col) not in ['position','hkle','status','direction'] ):
			all[col] = all[col].astype(int)
	
#	all.set_index(['position','hkle','status','direction'],inplace=True)
	all.sort_values(by=['position','hkle','status','direction'],inplace=True)
	
	print(all.shape)
	print(all.head(50))
	
	all.to_csv('hkle_'+key+'_grouped.csv')


