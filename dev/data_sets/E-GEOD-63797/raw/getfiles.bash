#!/usr/bin/env bash


##	No files
#
#for f in $( awk -F"\t" '{print $(NF-1)}' E-GEOD-63797.sdrf.txt ) ; do
#	l=$( basename $f )
#	echo $f $l
#	if [ -f $l ] && [ ! -w $l ] ; then
#		echo "Write-protected $l already exists. Skipping."
#	else
#		if [ -f $l ] ; then
#			echo "Removing file."
#			rm $l
#		fi
#		echo "Wgetting $l"
#		wget $f
#		chmod a-w $l
#	fi
#done

