#!/usr/bin/env bash

#mysql --user root --skip-column-names --vertical queue << EOF

#	Vertical creates this asterisk row. Surprisingly removable!
#	*************************** 1. row ***************************

mysql --user root --vertical queue << EOF | tail -n +2
LOCK TABLES queue WRITE;

SELECT id INTO @last FROM queue
WHERE started_at = 0
ORDER BY added_at ASC
LIMIT 1;

UPDATE queue
SET started_at = CURRENT_TIMESTAMP
WHERE id = @last;

SELECT id,command FROM queue
WHERE id = @last;

UNLOCK TABLES;
EOF
