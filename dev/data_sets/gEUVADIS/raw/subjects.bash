#!/usr/bin/env bash


while read line 
do
file=${line##*/}
subject=${file%%.*}
echo $subject
done < PRJEB3366_files.txt | sort | uniq > subjects.txt

