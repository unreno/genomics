#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



database_file="bam_specs.sqlite3"

sql="sqlite3 ${database_file}"

if [ ! -f ${database_file} ] ; then

	${sql} "CREATE TABLE specs( filename, unmapped, mapped, total );"

fi


for f in *.bam ; do
	echo $f

	if [ -z $( ${sql} "SELECT total FROM specs WHERE filename = '${f}'" ) ] ; then
		mapped=$( samtools view --threads 39 -c -F 4 ${f} )
		unmapped=$( samtools view --threads 39 -c -f 4 ${f} )
		total=$( samtools view --threads 39 -c ${f} )
		command="INSERT INTO specs( filename, unmapped, mapped, total ) VALUES ( '${f}', '${unmapped}', '${mapped}', '${total}' );"
		echo "${command}"
		${sql} "${command}"
	fi

done
