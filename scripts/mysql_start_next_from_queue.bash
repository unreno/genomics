#!/usr/bin/env bash

mysql --user root queue << EOF
LOCK TABLES queue WRITE;

SELECT id INTO @last FROM queue
WHERE started_at = 0
ORDER BY added_at ASC
LIMIT 1;

UPDATE queue
SET started_at = CURRENT_TIMESTAMP
WHERE id = @last;

SELECT * FROM queue
WHERE id = @last;

UNLOCK TABLES;
EOF

