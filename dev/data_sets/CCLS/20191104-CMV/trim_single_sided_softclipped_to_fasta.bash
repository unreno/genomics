#!/usr/bin/env bash


#	Select the soft-clipped regions and print to fastas
#	Expecting only single sided soft clipping ... ##M##S or ##S##M
#	Not ##S##M##S
#	Anything else will require more development


#
#	Find alignments that align past the appropriate end of the ends of the ltr.
#
#    f4 = unmapped
#    F4 = NOT unmapped = mapped
#    F8 = mate NOT unmapped = mate mapped
#
#	Older versions of awk do not directly support "interval expressions",
#		ie ({4}, {4,}, {4,6})
#	Need a newer version or add the --posix option

#	Using -F 4 here again, seems unnecessary.
samtools view -h -F 4 $1 | gawk -v base=$1 '
BEGIN {
	#	input is a sam file so specifying tab may be unnecessary, but clarity is nice.
	FS="\t"
	#pre_out=sprintf("%s.pre.fasta",base)
	#post_out=sprintf("%s.post.fasta",base)
}
#	Simply for progress
( ( !/^@/ ) && ( ( NR % 1000000 ) == 0 ) ){ print "Read "NR" records" }

#	Ex. @SQ	SN:chr1	LN:249250621
#	... ref[chr1] = 249250621
#( /^@SQ/ ){ ref[substr($2,4)] = substr($3,4) }


#	Eventually, the database will contain multiple elements.
#	HERVs, SINEs, LINEs, SVAs, ...
#	Include this in the output read? Separate files?


#	Ensure at least 2-digit soft clip and ensure matches near the beginning of the reference.
#	"near the beginning" means starts at position <= 5
#( ( $6 ~ /^[0-9]{2,}S[0-9IDMX=]*$/ ) ){	#&& ( $4 <= 5 ) ){
( $6 ~ /^[0-9]{2,}S[0-9IDMX=]*$/ ){
	#print "---"
	#print "Pre"		#	38S112M
	#print $6
	#print $10
	split($6,a,"S")
	##	clip=a[1]-$4+1
	#print length(a)
	#print a[1]
	#print a[2]
	print ">"$1"_pre" #>> pre_out
	print substr($10,1,a[1]) #>> pre_out

	next;	#	could match next block too? No. This regex couldnt match both.
}

#	Ensure at least 2-digit soft clip and ensure matches near the end of the reference.
#	"near the end" means starts at position >= 5 more than the reference minus the length of the read
#( ( $6 ~ /^[0-9IDMX=]*[0-9]{2,}S$/ ) ){	#&& ( $4 >= ( ref[$3] - length($10) + 5 ) ) ){
( $6 ~ /^[0-9IDMX=]*[0-9]{2,}S$/ ){
	#print "---"
	#print "Post"		#	46M104S
	#print $6
	#print $10
	split($6,a,"M")
	#	clip=ref[$3]-$4+2
	#print clip
	#print length(a)
	#print "a1",a[1]
	#print "a2",a[2]
	#split(a[1],b,"M")
	#print b[1]
	#print b[2]
	print ">"$1"_post" #>> post_out
	print substr($10,1+a[1]) #>> post_out

	next;
}
{
#	print $6 >> "skipped"
}'
