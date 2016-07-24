#!/usr/bin/env bash


function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` referencefile samplefilelist"
	echo
	echo "Insertion points or Overlappers?"
	echo "The file content looks like it is expecting insertion points!"
	echo "This makes the example output filename confusing!"
	echo "Should be insertion_points_reference"
	echo
	echo "Expecting file content in the format of ..."
	echo
	echo "..."
	echo "chr8|99063786|F"
	echo "chr9|105365407|F"
	echo "chrX|74554211|R"
	echo "chrY|14564844|R"
	echo "..."
	echo
	echo "With or without the direction is acceptable."
	echo
	echo "Looks like this could also be run on the insertion_points_to_table tmpfile!"
	echo "chr10|102392397|F|POST,1,HG00096"
	echo "chr10|2675705|F|POST,1,HG00096"
	echo "chr10|26894438|F|POST,4,HG00096"
	echo "chr10|41714154|F|POST,9,HG00096"
	echo "chr10|43338170|F|POST,1,HG00096"
	echo "chr10|43338171|F|POST,1,HG00096"
	echo
	echo "Example:"
	echo "  `basename $0` [--print 'reference' or 'sample'] referencefile samplefilelist"
	echo
	echo "find . -maxdepth 1 -type d \( -name HG\* -o -name NG\* \) -execdir sh -c 'echo {}; cd {}; positions_within_10bp_of_reference.sh ../../overlapper_reference.Q20 *Q20*ts | sort | uniq -c > {}.bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.both_ltr.bowtie2.hg19.Q20.overlappers_reference' \;"
	echo
	echo
	echo
	echo "OUTPUTS the samplefilelist lines, NOT the referencefile lines."
	echo "( same as positions_within_10bp.sh )"
	echo
	echo
	exit 1
}
#	-depth will produce errors like the following on ec2. Use -maxdepth instead.
#	find: paths must precede expression: 2
#	Usage: find [-H] [-L] [-P] [-Olevel] [-D help|tree|search|stat|rates|opt|exec] [path...] [expression]

#	Basically, its either 'sample' or its not. 
printwhat='sample'

while [ $# -ne 0 ] ; do
	case $1 in
		-p|--p*)
			shift; printwhat=$1; shift ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done


#	Basically, this is TRUE AND DO ...
#[ $# -ne 2 ] && usage
[ $# -lt 2 ] && usage
if [ ! -f $1 ] ; then 
	echo "$1 is not a file" 
	usage
fi
if [ ! -f $2 ] ; then
	echo "$2 is not a file" 
	usage
fi

reference=$1
shift

while [ $# -ne 0 ] ; do
#	echo $1
	for line in `cat $reference` ; do

		#	CORRECTION .... chrY|4395088|F ... REFERENCE INCLUDES DIRECTION

#		echo $line
		chr=${line%%|*}	#	remove everything after first pipe (including pipe)
		line2=${line#*|}	#	remove everything before first pipe (including pipe)
		pos=${line2%%|*}	#	remove everything after first pipe (including pipe)
#		echo $chr
#		echo $pos

		#	Expecting file content format like so ...
		#	chrY|6616930|

#	print the reference insertion point or the point found?

#	print the POSITION from what.

#	the reference line DOES NOT INCLUDE THE SAMPLE NAME
#	the sample line contains the sample name and count.  NEED TO EXTRACT IT

		awk -F\| -v chr="$chr" -v pos="$pos" -v line="$line" -v printwhat="$printwhat" '
			( ( $1 == chr ) && ( (pos-10) < $2 ) && ( (pos+10) > $2 ) ){
				if( printwhat=="sample" ){
					print $0
				}else{
					split($0,a,",")
					print line","a[2]","a[3]
				}
			}' $1
#				print line
#				print line" - "$0

	done	#	for line in reference
	shift	#	change sample input file
done	#	while more input files
