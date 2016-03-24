#!/usr/bin/env bash

#	as this table is currently defined,
#	a "put-item" with the same command (ie. run this script multiple times)
#	will only yield one actual item.
#	The additional puts are effectively updates.
#	"command" is defined as the key much like a hash in ruby or perl.
#	"update-item" seems to do exactly the same thing.
#	If the record doesn't exist, it creates it. If it does, it updates it.


aws dynamodb put-item \
    --table-name Queue \
    --item '{ "command": {"S": "Destroy all humans"}, "Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"} }'  \
    --return-consumed-capacity TOTAL \
		--endpoint-url http://localhost:8000

