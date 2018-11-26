#!/usr/bin/env bash


#	cat FORWARD.fa | reverse_complement.bash > REVERSE_COMPLEMENT.fa


while read line
do
	if [[ $line =~ '>' ]] ; then
		echo ${line}-RC
	else
		echo $line | tr "[ATGCatgc]" "[TACGtacg]" | rev
	fi
done
