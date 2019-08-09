#!/usr/bin/env python

import sys 
import pandas as pd

file_name = sys.argv[1]

print(file_name)

file_name_parts=file_name.split('/')

base_name=file_name_parts[len(file_name_parts)-1]

print(base_name)


df=pd.read_csv(file_name,index_col='sample')


desired_order=[ '186069', '341203', '439338', '506458', '530196', '634370', '120207', '122997', '201771', '209605', '266836', '268325', '321666', '36077', '492023', '495910', '607654', '63185', '673944', '73753', '780690', '811386', '813891', '853767', '868614', '871719', '900420', '919207', '972727', '983899', '99776', '833536', '866648', 'GM_268325', 'GM_439338', 'GM_63185', 'GM_634370', 'GM_983899' ]

df=df.reindex(desired_order)

#print(df)


df.to_csv( file_name+".ordered.csv")

