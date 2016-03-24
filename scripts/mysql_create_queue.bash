#!/usr/bin/env bash

mysql --user root << EOF
DROP DATABASE IF EXISTS queue;
CREATE DATABASE queue;
CONNECT queue;

CREATE TABLE queue (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
	command VARCHAR(255) NOT NULL,
	added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	started_at TIMESTAMP,
	completed_at TIMESTAMP
);
EOF

