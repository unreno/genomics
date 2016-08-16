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


threads=2
index="hg19"
core="bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned"

#	If passed 1 fast[aq], check for chimeric reads.
#	If passed 2 fast[aq], also check for anchors with paired read run.

function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` [--threads 4] [--index hg19]" 
	echo "[--core bowtie2.herv_k113_ltr_ends.__very_sensitive_local.aligned.bowtie2.herv_k113.unaligned]"
	echo
	echo "Defaults:"
	echo "  threads ..... : $threads"
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
		-t|--t*)
			shift; threads=$1; shift ;;
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



#	if no fastq files exist, base becomes "*fastq"
#base=`basename $1`
#base=${base%%_1.*}

base=`basename $PWD`

{
	echo "Starting at ..."
	date

	#indexes=/Volumes/cube/working/indexes
	#	leading with the ": " stops execution
	#	just ${BOWTIE2_INDEXES:"/Volumes/cube/working/indexes"}
	#	would try to execute the result.  I just want the OR/EQUALS feature
	#: ${BOWTIE2_INDEXES:="/Volumes/cube/working/indexes"}
	: ${BOWTIE2_INDEXES:="$HOME/BOWTIE2_INDEXES"}

	#	they MUST be exported, apparently, to be picked up by bowtie2
	export BOWTIE2_INDEXES

	base="$base.$core"

	#	find insertion points
	#	then find those with the signature overlap

	#	 f = ALL/YES
	#	 F = NONE/NOT	(results in double negatives)
	#	 4 = not aligned
	#	 8 = mate not aligned
	#	16 = reverse complement

	echo "Seeking insertion points and overlaps"


	for q in 00 10 20 ; do

		samtools view -q $q -F 20 $base.pre_ltr.bowtie2.$index.bam \
			| awk '{print $3"|"$4+length($10)}' \
			| sort > $base.pre_ltr.bowtie2.$index.Q${q}.insertion_points

		samtools view -q $q -F 20 $base.post_ltr.bowtie2.$index.bam \
			| awk '{print $3"|"$4}' \
			| sort > $base.post_ltr.bowtie2.$index.Q${q}.insertion_points

		positions_within_10bp.bash $base.*.bowtie2.$index.Q${q}.insertion_points \
			| sort | uniq -c > $base.both_ltr.bowtie2.$index.Q${q}.insertion_points.overlappers
	
		samtools view -q $q -F 4 -f 16 $base.pre_ltr.bowtie2.$index.bam \
			| awk '{print $3"|"$4}' \
			| sort > $base.pre_ltr.bowtie2.$index.Q${q}.rc_insertion_points

		samtools view -q $q -F 4 -f 16 $base.post_ltr.bowtie2.$index.bam \
			| awk '{print $3"|"$4+length($10)}' \
			| sort > $base.post_ltr.bowtie2.$index.Q${q}.rc_insertion_points

		positions_within_10bp.bash $base.*.bowtie2.$index.Q${q}.rc_insertion_points \
			| sort | uniq -c > $base.both_ltr.bowtie2.$index.Q${q}.rc_insertion_points.rc_overlappers

	done

	echo
	echo "Finished at ..."
	date

} 1>>$base.`basename $0`.out 2>&1
