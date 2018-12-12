#!/usr/bin/env bash


#for dir in /raid/data/raw/1000genomes/phase3/data/* ; do basename $dir; done > subjects.txt
#for virus in /raid/refs/fasta/virii/*fasta ; do basename $virus .fasta; done > virii_versions.txt
#head -1q /raid/refs/fasta/virii/*fasta | sed 's/^>//' > virii_details.txt

#for virus in /raid/refs/fasta/virii/*fasta ; do
#	versions="${versions} $( basename $virus .fasta)"
#done
#echo $versions


#for subject in /raid/data/raw/1000genomes/phase3/data/* ; do 
#	subjects="${subjects} $( basename $subject )"
#done
subjects=$( cat subjects.txt )

#for virus in /raid/refs/fasta/virii/*fasta ; do
#	version=$( basename $virus .fasta )
#	#echo -n $version
#	echo -n \"$( head -1q /raid/refs/fasta/virii/${version}.fasta | sed 's/^>//' )\"

echo "virus/subject,"$subjects | tr " " ","

#for virus in $( cat virii_details.txt ) ; do
while read virus ; do
	echo -n \"${virus}\"

	version=${virus%% *}
	#echo $version

	for subject in $subjects ; do
		#file="${subject}.${version}.bowtie2.mapped.count.txt"
		file="${subject}.${version}.bowtie2.mapped.ratio_total.txt"
		if [ -f $file ] ; then
			count=$( cat $file | awk '{print $1" * 1000000000"}' | bc )
			count=${count%.*}
		else
			count=""
		fi
		echo -n ,${count}
	done
	echo
done < virii_details.txt
