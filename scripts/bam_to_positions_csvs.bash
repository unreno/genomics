#!/usr/bin/env bash


while [ $# -ne 0 ] ; do
	case $1 in
		-p|--p*)
			paired=true; shift ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#       Basically, this is TRUE AND DO ...
#[ $# -gt 0 ] && usage


while [ $# -ne 0 ] ; do

	base=${1%.*}

	echo $1 $base
	echo "CSV columns ... ReadName, Chromosome, Position, AlignmentScore"

	#	if paired, only use READ1 ( 64 )
	if [ -z "${paired}" ] ; then
		echo "Getting all positions"
		read1=""
	else
		echo "Getting only READ1 positions"
		read1="-f 64"
	fi
	mapped="-F 4"
	forward="-F 16"
	reverse="-f 16"

echo "samtools view ${mapped} ${forward} ${read1} $1"

samtools view ${mapped} ${forward} ${read1} $1 | awk '
BEGIN{ FS=OFS="\t" }
{
	for(i=12;i<=NF;i++)
		if($i ~ /^AS:/)
			split($i,a,":")
	print $1,$3,$4,a[3]
}' > ${base}.forward.positions.csv

echo "samtools view ${mapped} ${reverse} ${read1} $1"

samtools view ${mapped} ${reverse} ${read1} $1 | awk '
BEGIN{ FS=OFS="\t" }
{
	for(i=12;i<=NF;i++)
		if($i ~ /^AS:/)
			split($i,a,":")
	print $1,$3,$4+length($10),a[3]
}' > ${base}.reverse.positions.csv


	shift
done
