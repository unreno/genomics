#!/usr/bin/env bash

#	how to create unique, auto-incrementing id
#	how to create a date field that defaults to current time created.
#	Dynamo DB won't do either of those.
#	The given attributes are REQUIRED. Can have any other additional attributes though.

aws dynamodb create-table \
	--table-name Queue \
	--attribute-definitions  \
		AttributeName=command,AttributeType=S \
	--key-schema AttributeName=command,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
	--endpoint-url http://localhost:8000

#
#	From documentation ...
#
#aws dynamodb create-table \
#	--table-name Music \
#	--attribute-definitions  \
#		AttributeName=Artist,AttributeType=S  \
#		AttributeName=SongTitle,AttributeType=S \
#	--key-schema AttributeName=Artist,KeyType=HASH AttributeName=SongTitle,KeyType=RANGE \
#	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
#	--endpoint-url http://localhost:8000
#
