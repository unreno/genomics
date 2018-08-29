#!/usr/bin/env bash

#	Use [client] instead of [mysql] so mysqldump also works.

#cat ~/.localqueue.cnf
#[client]
#user=root
#password=
#[mysql]
#database=queue

#cat ~/.awsqueue.cnf
#[mysql]
#database=QueueDbName
#[client]
#user=*******
#password=*******
#port=3306
#host=******.******.rds.amazonaws.com

function usage(){
	echo
	echo "Maintain FIFO-like mysql/mariadb database"
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` push 'COMMAND' -> adds COMMAND to bottom of queue (one at a time)"
	echo "(currently deving pushing multiple properly quoted commands. no promises.)"
	echo "COMMAND must be quoted! Single or double."
	echo "`basename $0` size -> display number of records (aka count or length)"
	echo "`basename $0` list -> display all records"
	echo "`basename $0` start -> initiates a loop popping and running unrun elements in the queue"
	echo "`basename $0` create -> creates table (does not create database or destroy existing table"
	echo
	echo "Defaults:"
	echo "--defaults_file . $defaults_file"
	echo "--table_name .... $table_name"
	echo
	echo "Example:"
	echo "`basename $0` --defaults_file ~/.awsqueue.cnf push 'sleep 10'"
	echo
	echo "Tips:"
	echo "Create an alias ... (FYI: aliases don't get pulled into scripts!)"
	echo "alias awsq='`basename $0` --defaults_file ~/.awsqueue.cnf'"
	echo "awsq push 'sleep 10'"
	echo "awsq list"
	echo
	exit
}

defaults_file="~/.localqueue.cnf"
table_name="queue"

while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		-d*|--d*)
			shift; defaults_file=$1; shift ;;
		-t*|--t*)
			shift; table_name=$1; shift ;;
		--)	#	just -- is a common and explicit "stop parsing options" option
			shift; break ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

[ $# -eq 0 ] && usage

mysql="mysql --defaults-file=$defaults_file"
hostname=`hostname`

logfile="`basename $0`.`date "+%Y%m%d%H%M%S"`.$$.log"
#IFS=''	#	was for possibly preserving indentation in HEREDOCS. Causes problems.

log(){
#	echo "$*" >> $logfile
	echo "$*"
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


#	This is FAST!
file_push(){
	var="LOCK TABLES $table_name WRITE;"
	while [ $# -ne 0 ] ; do
		echo "Pushing the contents of "$1
#		var="${var}"$'\n'"LOAD DATA INFILE '$1' INTO TABLE $table_name (command);"
		var="${var}"$'\n'"LOAD DATA LOCAL INFILE '$1' INTO TABLE $table_name (command);"
		shift
	done
	var="${var}"$'\n'"UNLOCK TABLES;"
	log "$var"
#	echo "$var" | $mysql
	echo "$var" | $mysql --local-infile
}

#file_push1(){
#	var="LOCK TABLES $table_name WRITE;"
#	while [ $# -ne 0 ] ; do
#		echo "Pushing the contents of "$1
#
#		while read -r line; do
#			echo "$line"
#			var="${var}"$'\n'"INSERT INTO $table_name (command) VALUES ( '$line' ),"
#		done < $1
#
#		shift
#	done
#	var="${var}"$'\n'"UNLOCK TABLES;"
#	log "$var"
#	echo "$var" | $mysql
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
	echo "$var" | $mysql
	log "Pushed $*"
	echo "Pushed $*"
}

count(){
	log "Counting ... `date`"
	#	The "| tail -n +2" is to remove the ***** row.
	$mysql --vertical <<- EOF | tail -n +2
		SELECT COUNT(*) INTO @all FROM $table_name;
		SELECT COUNT(*) INTO @waiting FROM $table_name WHERE started_at = 0;
		SELECT COUNT(*) INTO @running FROM $table_name WHERE started_at <> 0 AND completed_at = 0;
		SELECT COUNT(*) INTO @complete FROM $table_name WHERE started_at <> 0 AND completed_at <> 0;
		SELECT @all, @waiting, @running, @complete;
	EOF
}

list(){
	log "Listing ... `date`"
	$mysql -e "SELECT * FROM $table_name"
}

#	Many items are queued so quickly that they have the same queued_at date.
#	In order to process in the order that they were queued, ORDER BY id ASC
start_next(){
	read -d '' var <<- EOF
		LOCK TABLES $table_name WRITE;
		SELECT id INTO @last FROM $table_name
			WHERE started_at = 0
			ORDER BY id ASC
			LIMIT 1;
		UPDATE $table_name
			SET started_at = CURRENT_TIMESTAMP,
				hostname = '$hostname',
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
	n=`echo "$var" | $mysql --vertical | tail -n +2`
	echo "$n"
}

start(){
	log "Starting ... `date`"

	pid_file=$HOME/`basename $0`.removal_cancel_further_running
	echo $$ > $pid_file

	#     id: 10
	#command: echo "testing2"

	#$ x='command: echo "testing2"'
	#$ echo $x
	#command: echo "testing2"
	#$ echo ${x:9}		<- After 9 characters
	#echo "testing2"

	#	The text only starts at 10 because that is the length
	#	of "command: ". If the field name changes, so must "10".
#	while r=$(start_next) && \
	while [ -f $pid_file ] && \
			r=$(start_next) && \
			id=`echo "$r" | grep "^     id: " | cut -c 10-` && \
			command=`echo "$r" | grep "^command: " | cut -c 10-` && \
			[ -n "$id" -a -n "$command" ] ; do
#	When using -n or -z, be sure to either wrap variable in quotes
#	or use double brackets [[ ]]. See snippet at bottom.
#			[ "x$id" != "x" -a "x$command" != "x" ] ; do
#		echo "$r"
#		id=`echo "$r" | grep "^     id: " | cut -c 10-`
#		id=${id:9}
#		echo "--${id}--"
	
#		command=`echo "$r" | grep "^command: " | cut -c 10-`
#		command=${command:9}
#		echo "--${command}--"
	
		log "Date ...... `date`"
		log "Running ... id $id"
		log "Running ... $command"

		#	run the command
		eval $command

		log "Date ...... `date`"

		#	mark as complete record with id = $id
		read -d '' var <<- EOF
			LOCK TABLES $table_name WRITE;
			UPDATE $table_name SET completed_at = CURRENT_TIMESTAMP WHERE id = '$id';
			UNLOCK TABLES;
		EOF
		log "$var"
		echo "$var" | $mysql
	done

	[ -f $pid_file ] || echo "PID file is gone. Further processing cancelled."
	[ -f $pid_file ] && echo "Queue appears to be empty now." && \rm -f $pid_file

}

create(){
	#DROP DATABASE IF EXISTS $database_name;
	#CREATE DATABASE $database_name;
	#CONNECT $database_name;
	read -d '' var <<- EOF
		CREATE TABLE $table_name (
			id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
			queued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			started_at TIMESTAMP,
			completed_at TIMESTAMP,
			hostname VARCHAR(255),
			processid INT,
			command TEXT NOT NULL
		);
	EOF
	#	using echo to "return" a value
	#	DON'T FORGET THE DOUBLE QUOTES to preserve newlines!
	#	Without the double quotes, the id and command will be on the
	#	same line in the variable and then won't work as expected.
	log
	log "$var"
	n=`echo "$var" | $mysql`
	echo "$n"
}

case "$1" in
#	peek )
#		shift; peek;;
#	pop )
#		shift; pop;;
	start )
		#	Syntax highlighting suggests that start is a keyword?
		start;;
	push | queue )
		#	Using $@ and wrapping in double quotes passes quotes correctly!
		shift; push "$@";;	
	file_push )
		shift; file_push "$@";;
	size | count | length )
		count;;
	list )
		list;;
	create )
		create;;
esac



#	for i in {1..50}; do echo mysql_queue.bash push \'sleep `date +%N | cut -c 5-6`\'; done | sh

exit;

#	DO NOT DO [ -n $x ]! It is always true.

unset x
[ -n $x ] && echo "$x:and" || echo "$x:or"
[[ -n $x ]] && echo "$x:and" || echo "$x:or"
[ -n "$x" ] && echo "$x:and" || echo "$x:or"

x=""
[ -n $x ] && echo "$x:and" || echo "$x:or"
[[ -n $x ]] && echo "$x:and" || echo "$x:or"
[ -n "$x" ] && echo "$x:and" || echo "$x:or"

x="set"
[ -n $x ] && echo "$x:and" || echo "$x:or"
[[ -n $x ]] && echo "$x:and" || echo "$x:or"
[ -n "$x" ] && echo "$x:and" || echo "$x:or"

#	Why all the HEREDOCs? Why not just var="blah blah newline blah blah"? It does work. Clarity I suppose.
