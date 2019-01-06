#!/usr/bin/env python


#	significant difference between python2.7 and python3.6
#	/ is different. In 2.7 is integer division. In 3.6, it is float.
#	To force the same float behavior, one of the input MUST be a float, so add .0 or call float() on one.


import os    
import sys
import pandas
import numpy

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog='frobble')

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V', '--version', help='show program version', action='store_true')
parser.add_argument('-p', '--percentage', nargs=1, type=int, default=50, help='the percentage to %(prog)s (default: %(default)s)')
parser.add_argument('-d', '--depth', nargs=1, type=int, default=1, help='the depth to %(prog)s (default: %(default)s)')
parser.add_argument('-n', '--name', nargs=1, type=str, default='Reference', help='the name to %(prog)s (default: %(default)s)')
parser.add_argument('-l', '--length', nargs=1, type=int, default=1000000, help='the length to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

# check for --version or -V
if args.version:  
	print("this is myprogram version 0.1")
	quit()



#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?

if isinstance(args.percentage,list):
	percentage=args.percentage[0]
else:
	percentage=args.percentage

print( "Filtering commonality on sample percentage: ", percentage )


if isinstance(args.depth,list):
	depth=args.depth[0]
else:
	depth=args.depth

print( "Filtering commonality on sample depth: ", depth )




if isinstance(args.name,list):
	name=args.name[0]
else:
	name=args.name

print( "Using reference name: ", name )




if isinstance(args.length,list):
	length=args.length[0]
else:
	length=args.length

print( "Using reference length: ", length )









#	common_depth_coverage_regions.py {HG,NA}*.NC_001664.4.depth.csv
#	common_depth_coverage_regions.py {HG,NA}*.NC_000898.1.depth.csv

#print( sys.argv[1:] )
#['20180103-awsqueue.sql', 'Makefile', 'Makefile.example', 'NA12878_SRR010942', 'PersonalGenomeProject', 'README.md', 'dev', 'docker', 'geuvadis.txt', 'notebooks', 'notes', 'oneoff', 'scripts', 'test_user_data']

#print( sys.argv[1:][0] )
#20180103-awsqueue.sql


#	~/github/unreno/genomics/dev/data_sets/1000genomes/20181010-unmapped-hhv6/hhv6.py
#	dev/data_sets/CCLS/raw/bam/bam-coverage-depth.py


data_frames = []
flagged_data_frames = []

#for filename in sys.argv[1:]:
for filename in args.files:  
	print(filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		print("Reading "+filename)
		sample=filename.split(".")[0]	#	everything before the first "."
		d = pandas.read_csv(filename,
			sep="\t",
			header=None,
			usecols=[1,2],	# usecols=[0,1],
			names=["position",sample],
			dtype={"position": int, sample: int},
			index_col=["position"] )

#		if( len(d.index) > 0 ):
		print("Appending")
		data_frames.append(d)
		d[sample] = numpy.where(d[sample]>depth, 1, 0)
		flagged_data_frames.append(d)
#		else:
#			print("Empty. Ignoring.")
	else:
		print(filename + " is empty")

if len(data_frames) > 0:
	df = pandas.concat(data_frames, axis=1)
	flagged = pandas.concat(flagged_data_frames, axis=1)

	data_frames = []
	flagged_data_frames = []

	df.fillna(0, inplace=True)
	#print( df.head() )


#	NOTE     mean will be different if include empty files or don't


	flagged.fillna(0, inplace=True)
#	print( flagged.max(axis=1) )
	#print( flagged.mean(axis=1).head() )

	#print( "Percentage:"+str(percentage)+" - " + str(percentage/100.0))

	#print( "Means: " + str(flagged.mean(axis=1).tolist()))
	print( "Max: " + str(max(flagged.mean(axis=1).tolist())))
	print( "Mean: " + str(numpy.mean(flagged.mean(axis=1).tolist())))

	common=flagged.index[ flagged.mean(axis=1) >= (percentage/100.0) ].tolist()
	print( common )
	#print( len(common) )

	if( len(common) > 0 ):
		regions=[]
		first=last=common[0]
		for item in common[1:]:
			if( item != last+1 ):
				regions.append([first,last])
				first=item

			last=item
		regions.append([first,last])
		print("Common regions: ",regions)


#regions=[[50,100], [7717, 7728], [7730, 7765], [7871, 7877], [7908, 7921], [158982, 159028], [159039, 159058], [159060, 159066]]

		#	Expand and fill gaps 
		expanded_regions=map(lambda x: [x[0]-100,x[1]+100], regions)
#[[-50,200], [7617, 7828], [7630, 7865], [7771, 7977], [7808, 8021], [158882, 159128], [158939, 159158], [158960, 159166]]

#	This can cause a problem
#	 [14242, 14794], [14795, 15392],
# Add 5 to deal with possibility

		filled_regions=[]
		buffered=expanded_regions[0]
		if buffered[0] < 0:
			buffered[0]=0
		for pair in expanded_regions[1:]:
			if( pair[0] < buffered[1]+5 ):
				buffered[1] = pair[1]
			else:
				filled_regions.append(buffered)
				buffered=pair
		filled_regions.append(buffered)
		print("Filled common regions: ", filled_regions )


#		#	fill gaps less than 100 base pairs
#		filled_regions=[]
#		buffered=regions[0]
#		for pair in regions[1:]:
#			if( pair[0] < buffered[1]+100 ):
#				buffered[1] = pair[1]
#			else:
#				filled_regions.append(buffered)
#				buffered=pair
#		filled_regions.append(buffered)
#		print("Filled common regions: ", filled_regions )





		
		#	Need to convert to inverse with reference name
		#	Need reference name and length

		#	[[7683, 8002], [158972, 159290]]
		#		to
		#	7683-8002, 158972-159290
		#		to
		#	AF037218.1:1-7682 AF037218.1:8003-158971 AF037218.1:159291-153080

		start=1
		s=name
		if filled_regions[0][0] == 1:
			s+=":" + str(filled_regions[0][1]+1) + "-"
			i=1
		else:
			s+=":1-"
			i=0
		for region in filled_regions[i:]:
			s+=str(region[0]-1) + " " + name + ":" + str(region[1]+1) + "-"

		s+=str(length)
		print("Samtools uncommon regions: " + s)

	else:
		print("No common regions found.")

else:
	print("No data.")


#	common_depth_coverage_regions.py HG000*.NC_001664.4.depth.csv
#	[[7717, 7728], [7730, 7765], [7871, 7877], [7908, 7921], [158982, 159028], [159039, 159058], [159060, 159066]]
#	[[7717, 7765], [7871, 7877], [7908, 7921], [158982, 159066]]

#	common_depth_coverage_regions.py HG00*.NC_001664.4.depth.csv
#	[[7707, 7971], [158991, 159253]]


#	common_depth_coverage_regions.py HG00*.NC_001664.4.depth.csv
#	[[7803, 7803], [7809, 7825], [7829, 7830], [7844, 7844], [7850, 7873], [7879, 7879], [7881, 7883], [7885, 7885], [7887, 7890], [7894, 7894], [7904, 7904], [7907, 7941], [159038, 159048], [159057, 159067], [159069, 159069], [159211, 159215], [159217, 159217], [159223, 159223]]
#	[[7803, 7941], [159038, 159069], [159211, 159223]]

#	common_depth_coverage_regions.py {HG,NA}*.NC_001664.4.depth.csv
#	[[7695, 7986], [158988, 159276]]
#	[[7695, 7986], [158988, 159276]]



#	common_depth_coverage_regions.py -p 70 {HG,NA}*.NC_001664.4.depth.csv
#	[[7715, 7964], [159008, 159251]]

#	common_depth_coverage_regions.py -p 60 {HG,NA}*.NC_001664.4.depth.csv
#	[[7695, 7986], [158988, 159276]]

#	common_depth_coverage_regions.py -p 50 {HG,NA}*.NC_001664.4.depth.csv
#	[[7683, 8002], [158972, 159290]]

#	20000-120000

