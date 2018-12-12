#!/usr/bin/env bash


for f in $( cat files ) ; do
echo $f
wget ftp://$f
done

