#!/usr/bin/env bash

var="LOCK TABLES queue WRITE;"

while [ $# -ne 0 ] ; do
	var="${var}"$'\n'"UPDATE queue SET completed_at = CURRENT_TIMESTAMP WHERE id = '$1';"
	shift
done

var="${var}"$'\n'"UNLOCK TABLES;"

#echo "$var"

echo "$var" | mysql --user root queue
