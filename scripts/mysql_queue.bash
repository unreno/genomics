#!/usr/bin/env bash

if [ $# -eq 0 ]; then
	echo
	echo "maintain FIFO-like mysql database"
	echo
	echo "Usage:"
	echo "`basename $0` push 'COMMAND' -> adds COMMAND to bottom of queue (one at a time)"
	echo "(currently deving pushing multiple properly quoted commands. no promises.)"
	echo "COMMAND must be quoted! Single or double."
	echo "`basename $0` size -> display number of records (aka count or length)"
	echo "`basename $0` list -> display all records"
	echo "`basename $0` start -> initiates a loop popping and running unrun elements in the queue"
	echo
	exit
fi

database_name="queue"
table_name="queue"
logfile="`basename $0`.`date "+%Y%m%d%H%M%S"`.$$.log"
#IFS=''	#	was for possibly preserving indentation in HEREDOCS. Causes problems.

log(){
	echo "$*" >> $logfile
}


#max_retries=5

#peek(){
#	echo "Peeking ... `date`" >> $logfile
##	r=`sqlite3 -cmd '.timeout 5000' -line $database_file_name "select * from queue order by id asc limit 1"`
##	command=`echo "$r" | grep "^\s*command = " | sed 's/^command = //'`
##	echo $command
#}

#
#	Sadly, rapid pop calls can result in the multiple returns of the same record.
#
#pop(){
#	echo "Popping ... `date`" >> $logfile
#	r=`sqlite3 -cmd '.timeout 5000' -line $database_file_name "select * from queue order by id asc limit 1"`
#	id=`echo "$r" | grep " id = " | awk -F= '{print $NF}'`
#	if [ "x$id" != "x"  ] ; then
#		command=`echo "$r" | grep "^\s*command = " | sed 's/^command = //'`
#		echo $command
#		echo $command >> $logfile
#		echo "Deleting ..." >> $logfile
#		sqlite3 -cmd '.timeout 5000' $database_file_name "delete from queue where id = $id"
#		delete_retries=0
#		while [ $delete_retries -lt $max_retries -a \
#			`sqlite3 -cmd '.timeout 5000' $database_file_name "select * from queue where id = $id" | wc -l` -gt 0 ]
#		do
#			echo "Delete failed. Retrying ... $delete_retries" >> $logfile
#			sqlite3 -cmd '.timeout 5000' $database_file_name "delete from queue where id = $id"
#			delete_retries=`expr $delete_retries + 1`
#		done
#	fi
#}

push(){
	#	The $* in a function MUST BE PASSED.  IT IS NOT THE $* from the command line.
	#	Unless, of course, that's what you pass it.
	log "Pushing ... `date`"
	var="LOCK TABLES $table_name WRITE;"
	#	for i in "$@" ; do
	#		var="${var}"$'\n'"INSERT INTO $table_name (command) VALUES ( '$i' );"
	#	done
	#	either way now
	while [ $# -ne 0 ] ; do
		var="${var}"$'\n'"INSERT INTO $table_name (command) VALUES ( '$1' );"
		shift
	done
	var="${var}"$'\n'"UNLOCK TABLES;"
	log "$var"
	echo "$var" | mysql --user root $database_name
	log "Pushed $*"
	echo "Pushed $*"
}

count(){
	log "Counting ... `date`"
	#	The "| tail -n +2" is to remove the ***** row.
	mysql --user root --vertical $database_name <<- EOF | tail -n +2
		SELECT COUNT(*) INTO @all FROM $table_name;
		SELECT COUNT(*) INTO @waiting FROM $table_name WHERE started_at = 0;
		SELECT COUNT(*) INTO @running FROM $table_name WHERE started_at <> 0 AND completed_at = 0;
		SELECT COUNT(*) INTO @complete FROM $table_name WHERE started_at <> 0 AND completed_at <> 0;
		SELECT @all, @waiting, @running, @complete;
	EOF
}

list(){
	log "Listing ... `date`"
	mysql --user root -e "SELECT * FROM $table_name" $database_name
}

start_next(){
	read -d '' var <<- EOF
		LOCK TABLES $table_name WRITE;
		SELECT id INTO @last FROM $table_name
			WHERE started_at = 0
			ORDER BY added_at ASC
			LIMIT 1;
		UPDATE $table_name
			SET started_at = CURRENT_TIMESTAMP,
				processid = $$
			WHERE id = @last;
		SELECT id,command FROM $table_name
			WHERE id = @last;
		UNLOCK TABLES;
	EOF
	#	using echo to "return" a value
	#	DON'T FORGET THE DOUBLE QUOTES!
	#	Without the double quotes, the id and command will be on the 
	#	same line in the variable and then won't work as expected.
	log
	log "$var"
	n=`echo "$var" | mysql --user root --vertical $database_name | tail -n +2`
	echo "$n"
}

start(){
	log "Starting ... `date`"

	#     id: 10
	#command: echo "testing2"

	#$ x='command: echo "testing2"'
	#$ echo $x
	#command: echo "testing2"
	#$ echo ${x:9}		<- After 9 characters
	#echo "testing2"

	#	The text only starts at 10 because that is the length
	#	of "command: ". If the field name changes, so must "10".
	while r=$(start_next) && \
			id=`echo "$r" | grep "^     id: " | cut -c 10-` && \
			command=`echo "$r" | grep "^command: " | cut -c 10-` && \
			[ "x$id" != "x" -a "x$command" != "x" ] ; do
#		echo "$r"
#		id=`echo "$r" | grep "^     id: " | cut -c 10-`
#		id=${id:9}
#		echo "--${id}--"
	
#		command=`echo "$r" | grep "^command: " | cut -c 10-`
#		command=${command:9}
#		echo "--${command}--"
	
		log "Running ... id $id"
		log "Running ... $command"

		#	run the command
		$command
	
		#	mark as complete record with id = $id
		read -d '' var <<- EOF
			LOCK TABLES $table_name WRITE;
			UPDATE $table_name SET completed_at = CURRENT_TIMESTAMP WHERE id = '$id';
			UNLOCK TABLES;
		EOF
		log "$var"
		echo "$var" | mysql --user root $database_name
	done

	echo "Queue appears to be empty now."

}

#mysql --user root << EOF
#DROP DATABASE IF EXISTS $database_name;
#CREATE DATABASE $database_name;
#CONNECT $database_name;
#
#CREATE TABLE $table_name (
#	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
#	added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#	started_at TIMESTAMP,
#	completed_at TIMESTAMP,
#	processid INT,
#	command TEXT NOT NULL
#);
#EOF

case "$1" in
#	peek )
#		shift; peek;;
#	pop )
#		shift; pop;;
	start )
		#	Syntax highlighting suggests that start is a keyword?
		shift; start;;	
	push | queue )
		#	Using $@ and wrapping in double quotes passes quotes correctly!
		shift; push "$@";;	
	size | count | length )
		count;;
	list )
		list;;
esac



#	for i in {1..50}; do echo mysql_queue.bash push \'sleep `date +%N | cut -c 5-6`\'; done | sh

