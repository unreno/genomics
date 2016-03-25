#!/usr/bin/env bash

#	read -d '' var1 << EOF
#	Without double quotes around EOF, text will be subject to parameter expansion.
#	read -d '' var1 << "EOF"
#	With double quotes around EOF, text will NOT be subject to parameter expansion.

#read -d '' var << EOF
#LOCK TABLES queue WRITE;
#EOF

var="LOCK TABLES queue WRITE;"

while [ $# -ne 0 ] ; do
	var="${var}"$'\n'"INSERT INTO queue (command) VALUES ( '$1' );"
	shift
done

var="${var}"$'\n'"UNLOCK TABLES;"

echo "$var"

echo "$var" | mysql --user root queue

