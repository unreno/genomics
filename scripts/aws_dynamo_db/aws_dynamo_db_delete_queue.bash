#!/usr/bin/env bash

aws dynamodb delete-table --table-name Queue --endpoint-url http://localhost:8000
