#!/usr/bin/env bash


echo "About to wait"

state="in-use"
echo "Waiting for wait.txt to contain 'available'"
until [ "$state" == "available" ] ; do
	before=$state
	[ -e wait.txt ] && state=$(cat wait.txt)
	if [ "$state" != "$before" ] ; then
		echo "$state"
	fi
	#	could add a sleep in here to stop any excessive reading
done

echo "Done"
