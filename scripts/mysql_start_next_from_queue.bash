#!/usr/bin/env bash

mysql --user root << EOF
CONNECT queue;

LOCK TABLES queue WRITE;
SELECT * FROM queue;
SELECT SLEEP(10);
UNLOCK TABLES;
EOF

