#!/usr/bin/env bash
#	manually set -x as can't pass through env

set -x

#	Can't pass options when using env
#
#	with the -x the commands are sent to STDERR before execution
#
#	bowtie output goes to stderr for some reason
#	probably because the SAM file usually goes to stdout
#	so, wrap everything in curly braces and direct both
#	to files.
#
#	Explicit redirection within the block will override this
#


#	This really needs to be run in the data directory.
#
#	Eventually, may want to pass number of cpus or threads so
#	execs can use the same number.


index="hg19"
#core="bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned"
core="bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned"

#	If passed 1 fast[aq], check for chimeric reads.
#	If passed 2 fast[aq], also check for anchors with paired read run.

function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` [--index hg19]" 
	echo "[--core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned]"
	echo
	echo "Defaults:"
	echo "  index   ..... : $index"
	echo "  core    ..... : $core"
	echo
	echo "Expecting pre and post ltr fasta files in PWD"
	echo
	echo "core is what is between \$PWD. and .pre_ltr.fasta"
	echo
	echo "Note: all files will be based on the working directory's name"
	echo
	exit
}


while [ $# -ne 0 ] ; do
	case $1 in
		-i|--i*)
			shift; index=$1; shift ;;
		-c|--c*)
			shift; core=$1; shift ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#       Basically, this is TRUE AND DO ...
[ $# -gt 0 ] && usage


base=`basename $PWD`
subject=$base

{
	echo "Starting at ..."
	date

#	base="$base.bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned"
	base="$base.$core"

#	base="$base.bowtie2.herv_k113_ltr_ends.__very_sensitive_local"
#	base="$base.aligned"

#	samtools_extract_and_clip_chimeric_reads.sh $base.bam
	#	-> pre_ltr.fasta
	#	-> post_ltr.fasta

	#	find insertion points
	#	then find those with the signature overlap

	#	 f = ALL/YES
	#	 F = NONE/NOT	(results in double negatives)
	#	 4 = not aligned
	#	 8 = mate not aligned
	#	16 = reverse complement

	echo "Seeking insertion points and overlaps"

	for q in 00 ; do
#	for q in 00 10 20 ; do

		#	splitting on : takes into consideration of the chromosome
		#	is actually a sub range. 
		#	Surprisingly p[2], which could be 160772870-161772870 takes
		#	the first numeric portion when adding which is what I want.
		#	I expected to have to parse that too, but yay!
		#	Seems to work regardless.

#	Should add this to extract_insertion_points_and_overlappers.sh


#	OOPS. Ranges and positions start at 1 so adding one to the other
#		will offset the output position by 1.

#	In order to work with and without a range, will need to check.
#	Can't just subtract 1, which would work in this case.
#	That would offset positions in the future by -1.

#	offset=(p[2])?p[2]-1:0;
#	| awk '{split($3,p,":");o=(p[2])?p[2]-1:0;print p[1]":"o+$4+length($10)}'


#	chrX:154433612-155433612:809997
#	chrX:154433612-155433612:721705
#	chrX:154433612-155433612:614371
#	chrX:154433612-155433612:592614
#	chrX:154433612-155433612:263014 ( 154696626 ) 
#	chrX:154433612-155433612:378858	( 154812470 )

#	chrX:155243608
#	chrX:155155316
#	chrX:155047982
#	chrX:155026225
#	chrX:154696625
#	chrX:154812469

#	[[ ${ext} == insertion_points ]] && direction='F' || direction='R'
#	[[ ${filename} =~ pre_ltr ]] && pre_or_post='PRE' || pre_or_post='POST'


		samtools view -q $q -F 20 $base.pre_ltr.bowtie2.$index.bam \
			| awk -v s=$subject -v d=F -v p=PRE '{print s","$3"_"$4+length($10)"_"d"_"p","$5","$3","$4+length($10)","d","p}' \
			| sort > $base.pre_ltr.bowtie2.$index.Q${q}.insertion_points_with_quality

		samtools view -q $q -F 20 $base.post_ltr.bowtie2.$index.bam \
			| awk -v s=$subject -v d=F -v p=POST '{print s","$3"_"$4"_"d"_"p","$5","$3","$4","d","p}' \
			| sort > $base.post_ltr.bowtie2.$index.Q${q}.insertion_points_with_quality

		samtools view -q $q -F 4 -f 16 $base.pre_ltr.bowtie2.$index.bam \
			| awk -v s=$subject -v d=R -v p=PRE '{print s","$3"_"$4"_"d"_"p","$5","$3","$4","d","p}' \
			| sort > $base.pre_ltr.bowtie2.$index.Q${q}.rc_insertion_points_with_quality

		samtools view -q $q -F 4 -f 16 $base.post_ltr.bowtie2.$index.bam \
			| awk -v s=$subject -v d=R -v p=POST '{print s","$3"_"$4+length($10)"_"d"_"p","$5","$3","$4+length($10)","d","p}' \
			| sort > $base.post_ltr.bowtie2.$index.Q${q}.rc_insertion_points_with_quality

	done

	echo
	echo "Finished at ..."
	date

} 1>>$base.`basename $0`.out 2>&1
