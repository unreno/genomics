#!/usr/bin/env bash
#	manually set -x as can't pass through env
set -x

function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` [--shutdown]"
	echo
	echo "--shutdown : sudo shutdown after complete"
	echo
	exit
}

date=`date "+%Y%m%d%H%M%S"`
log_file=$HOME/`basename $0`.$date.`hostname`.$$.out
shutdown_file=$HOME/`basename $0`.shutdown

while [ $# -ne 0 ] ; do
	case $1 in
		-s|--s*)
			shift; touch $shutdown_file;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#       Basically, this is TRUE AND DO ...
[ $# -ne 0 ] && usage


{
	echo "Starting at ..."
	date

	mysql_queue.bash --defaults_file ~/.awsqueue.cnf start

	echo
	echo "Finished at ..."
	date
} 1>>$log_file 2>&1

gzip --best $log_file
aws s3 cp $log_file.gz s3://herv/suicidal_logs/

#	sudo raises this error
#	sudo: sorry, you must have a tty to run sudo
#	adding -t, -tt, -ttt, -tttt to ssh doesn't change this but can get this instead....
#	Pseudo-terminal will not be allocated because stdin is not a terminal.
#	Only ...
# sudo visudo 
#   to comment out the following lines ...
# Defaults    requiretty
# Defaults   !visiblepw
#	works.  Need to create yet another AMI with this change.
#	http://unix.stackexchange.com/questions/49077
#if [ -f $shutdown_file -o $shutdown == 'true' ]; then
if [ -f $shutdown_file ]; then
	sudo shutdown -h now
	#	sudo halt
fi

