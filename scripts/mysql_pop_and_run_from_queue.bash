#!/usr/bin/env bash

#$ ./mysql_start_next_from_queue.bash 
#     id: 10
#command: echo "testing2"
#
#$ x='command: echo "testing2"'
#$ echo $x
#command: echo "testing2"
#$ echo ${x:9}		<- After 9 characters
#echo "testing2"
#

#while [ r=`./mysql_start_next_from_queue.bash` -a "x$r" != "x" ] ; do
#	I'm not a fan of "while true" loops but I seem to using them a lot lately.
#while true ; do
#	r=`./mysql_start_next_from_queue.bash`

#	Boom!
while r=`mysql_start_next_from_queue.bash` && [ -n "$r" ] ; do
#	if [ "x$r" != "x" ] ; then	#	r is not blank
	
		id=`echo "$r" | grep "^     id: "`
		id=${id:9}
		echo "--${id}--"
	
		command=`echo "$r" | grep "^command: "`
		command=${command:9}
		echo "--${command}--"
	
		#	run the command
		$command
	
		#	mark as complete record with id = $id

		mysql_mark_complete_from_queue.bash $id
	
#	else	
#		echo "Queue appears to be empty."
#		break	#	from the while true loop
#	fi
done

echo "Queue appears to be empty now."

