#!/usr/bin/env bash


java -Djava.library.path=./dynamodb_local_2016-03-01/DynamoDBLocal_lib \
	-jar dynamodb_local_2016-03-01/DynamoDBLocal.jar -sharedDb &

