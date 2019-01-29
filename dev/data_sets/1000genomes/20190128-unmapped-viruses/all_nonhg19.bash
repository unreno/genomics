#!/usr/bin/env bash




for virus_fasta in /raid/refs/fasta/virii/*fasta ; do
	virus=$( basename $virus_fasta .fasta )
	#virus=${virus/./_}

	echo "Processing $virus"

	if [ -f /raid/data/working/refs/20190128-hg19/${virus}.nonhg19.txt ] ; then

		region=$( cat /raid/data/working/refs/20190128-hg19/${virus}.nonhg19.txt || true )

		echo "${region}"
		[ -z "${region}" ] && region="${virus}"

		#	samtools depth requires its regions to be individually declared! Why the inconsistancy?!

		#region=$( echo $region | sed 's/ / -r /g' )
		#echo "${region}"
		#echo samtools depth -aa --reference $virus_fasta -r $region ALL.virii.bam
		#samtools depth -aa --reference $virus_fasta -r $region ALL.virii.bam > ALL.${virus}.nonhg19.depth.txt
		#	This seems to only return the last region
	
		\rm ALL.${virus}.nonhg19.depth.txt
		for r in $region ; do
			echo samtools depth -aa --reference $virus_fasta -r $r ALL.virii.bam
			samtools depth -aa --reference $virus_fasta -r $r ALL.virii.bam >> ALL.${virus}.nonhg19.depth.txt
		done

	fi

done
