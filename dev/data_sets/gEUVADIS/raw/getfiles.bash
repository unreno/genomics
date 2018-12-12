#!/usr/bin/env bash


#for f in $( cat PRJEB3366_files.txt ) ; do
for f in $( sort -t \/ -k 6 PRJEB3366_files.txt ) ; do
	l=$( basename $f )
	echo $f $l
	if [ -f $l ] && [ ! -w $l ] ; then
		echo "Write-protected $l already exists. Skipping."
	else
		if [ -f $l ] ; then
			echo "Removing $l"
			rm $l
		fi
		echo "Wgetting $l"
		wget ftp://$f
		chmod a-w $l
	fi
done

