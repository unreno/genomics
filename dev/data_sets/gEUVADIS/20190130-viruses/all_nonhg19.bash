#!/usr/bin/env bash




for virus_fasta in /raid/refs/fasta/virii/*fasta ; do
	virus=$( basename $virus_fasta .fasta )
	#virus=${virus/./_}

	echo "Processing $virus"

	region_file="/raid/data/working/refs/20190128-hg19/${virus}.nonhg19.shrunk1000.txt"
	#region_file="/raid/data/working/refs/20190128-hg19/${virus}.nonhg19.shrunk2000.txt"

	if [ -f ${region_file} ] ; then

		region=$( cat ${region_file} || true )

		echo "${region}"
		[ -z "${region}" ] && region="${virus}"

		#	samtools depth requires its regions to be individually declared! Why the inconsistancy?!

		#region=$( echo $region | sed 's/ / -r /g' )
		#echo "${region}"
		#echo samtools depth -aa --reference $virus_fasta -r $region ALL.virii.bam
		#samtools depth -aa --reference $virus_fasta -r $region ALL.virii.bam > ALL.${virus}.nonhg19.depth.txt
		#	This seems to only return the last region
	
		\rm -f ALL.${virus}.nonhg19.depth.txt
		for r in $region ; do
			echo samtools depth -d 0 -aa --reference $virus_fasta -r $r ALL.virii.bam
			samtools depth -d 0 -aa --reference $virus_fasta -r $r ALL.virii.bam >> ALL.${virus}.nonhg19.depth.txt
		done

	fi

done
