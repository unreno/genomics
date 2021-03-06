#!/usr/bin/env bash


set -x


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



suffix=25_49
#cutoff=49	#	not used ( probably meant for the awk script )


f=case_abyss.fa
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	ABYSS -k25 -c0 -e0 case_kmers.fasta -o $f
	chmod a-w $f
fi

f=case_abyss.$suffix.fa
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	awk '!/^>/ { next } { getline seq } length(seq) >= 49 { print $0 "\n" seq }' case_abyss.fa > $f
	chmod a-w $f
fi


f=control_abyss.fa
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	ABYSS -k25 -c0 -e0 control_kmers.fasta -o $f
	chmod a-w $f
fi

f=control_abyss.$suffix.fa
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	awk '!/^>/ { next } { getline seq } length(seq) >= 49 { print $0 "\n" seq }' control_abyss.fa > $f
	chmod a-w $f
fi

