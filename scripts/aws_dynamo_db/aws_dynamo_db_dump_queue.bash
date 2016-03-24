#!/usr/bin/env bash

aws dynamodb scan --table-name Queue --endpoint-url http://localhost:8000

