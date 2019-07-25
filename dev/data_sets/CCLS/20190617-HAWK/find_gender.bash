#!/usr/bin/env bash


for bam in /raid/data/raw/CCLS/bam/*.recaled.bam ; do
	base=$( basename ${bam} .recaled.bam )
	echo ${base}
	#for q in 40 60 ; do
	q=60
		for chr in X Y ; do
			echo ${chr}

			f=${base}.${chr}.${q}.count.txt	
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				echo "Creating $f"
				samtools view -c -f 2 -q ${q} -@ 39 ${bam} ${chr} > ${f}
				chmod a-w $f
			fi

		done

		f=${base}.XY.${q}.ratio.txt
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			X=$( cat ${base}.X.${q}.count.txt )
			Y=$( cat ${base}.Y.${q}.count.txt )
			echo "${X} / ${Y}" | bc -l > ${f}
			chmod a-w $f
		fi

		f=${base}.YX.${q}.ratio.txt
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			X=$( cat ${base}.X.${q}.count.txt )
			Y=$( cat ${base}.Y.${q}.count.txt )
			echo "${Y} / ${X}" | bc -l > ${f}
			chmod a-w $f
		fi

	#done
done


