#!/usr/bin/env bash

for bam in *.recaled.bam ; do
	base=${bam%.recaled.bam}
	echo $bam $base

	f="${base}.unaligned.fasta.gz"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then

		echo "${f} already exists, so skipping."

	else

		echo "Extracting ${f} from ${bam}"
		samtools fasta -N -f 4 --threads 38 ${bam} | gzip --best > ${f} 2> ${f}.STDERR

		chmod a-w ${f}

	fi

done
