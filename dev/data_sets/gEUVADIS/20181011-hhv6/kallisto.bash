#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

#	set -o pipefail


#for c in NA*HHV6b.kallisto10.count.txt ; do
for c in HG003*HHV6b.kallisto10.count.txt ; do

	basename=${c%.HHV6b.kallisto10.count.txt}	#	just 1 %, not 2
	echo $basename

	for hhv in HHV6a HHV6b ; do

		echo "Processing ${hhv}"

		if [ -f ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt ] && [ ! -w ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt ] ; then
			echo "Write-protected ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt exists. Skipping step."
		else
			echo "Calculating ratio ${hhv} kallisto10 alignments to total reads"
			echo "scale=9; "$(cat ${basename}.${hhv}.kallisto10.count.txt)"/"$(cat ${basename}.total.count.txt) | bc > ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt
			chmod a-w ${basename}.${hhv}.kallisto10.mapped.ratio_total.txt
		fi

	done

done

