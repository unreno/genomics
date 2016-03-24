#!/usr/bin/env bash

#	Output when selecting will be tsv.
#	Making the command last would make it easier to parse if it contained any tabs.

#	Making it text would be better as well.  Commands could be long.

mysql --user root << EOF
DROP DATABASE IF EXISTS queue;
CREATE DATABASE queue;
CONNECT queue;

CREATE TABLE queue (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
	added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	started_at TIMESTAMP,
	completed_at TIMESTAMP,
	command TEXT NOT NULL
);
EOF
