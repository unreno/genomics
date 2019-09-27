#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



for fastq in /raid/data/raw/E-GEOD-66186/fastq/*.fastq ; do
	base=$( basename $fastq .fastq )

	echo $base

	#for ref in viral.masked hairpin ; do
	for ref in hairpin ; do
	
		f=${base}.${ref}.loc.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			#bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -1 ${r1} -2 ${r2} \
			bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -U ${fastq} \
				--score-min G,1,7 \
				--no-unal 2> ${f}.bowtie2.err \
				| samtools view -o ${f} - #> ${f}.samtools.log 2> ${f}.samtools.err
			chmod a-w $f
		fi

	done

	for ref in mature ; do

		#	G,20,8 = 20 + 8 * ln(x) where x is ~150 ~> 60
		#	G,1,8 = 1 + 8 * ln(x) where x is ~150  ~> 40
		#	G,1,6 = 1 + 6 * ln(x) where x is ~150  ~> 30
	
		f=${base}.${ref}.loc.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			#bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -1 ${r1} -2 ${r2} \
			bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -U ${fastq} \
				--score-min G,1,6 \
				--no-unal 2> ${f}.bowtie2.err \
				| samtools view -o ${f} - #> ${f}.samtools.log 2> ${f}.samtools.err
			chmod a-w $f
		fi

	done

	#for ref in viral.masked hairpin mature ; do
	for ref in hairpin mature ; do

#		f=${base}.${ref}.e2e.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#			#bowtie2 --xeq --threads 40 --very-sensitive -x ${ref} -1 ${r1} -2 ${r2} \
#			bowtie2 --xeq --threads 40 --very-sensitive -x ${ref} -U ${fastq} \
#				--no-unal 2> ${f}.bowtie2.err \
#				| samtools view -o ${f} - #> ${f}.samtools.log 2> ${f}.samtools.err
#			chmod a-w $f
#		fi

		f=${base}.${ref}.loc.bam.counts
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			#samtools view -f  64 -F 4 ${base}.${ref}.loc.bam | awk '{print $1"/1",$3}' >  ${f}.tmp
			#samtools view -f 128 -F 4 ${base}.${ref}.loc.bam | awk '{print $1"/2",$3}' >> ${f}.tmp
			#sort ${f}.tmp | uniq | awk '{print $2}' | sort | uniq -c > ${f}

			#	first awk/sort/uniq is to ensure that a read doesn't get counted for aligning
			#	to the same ref multiple times (really only needed for blast output)
			#samtools view -F 4 ${base}.${ref}.loc.bam | awk '{print $1,$3}' | sort | uniq | awk '{print $2}' | sort | uniq -c > ${f}

			echo "ref ${base}" > ${f}
			samtools view -F 4 ${base}.${ref}.loc.bam | awk '{print $3}' | sort | uniq -c | awk '{print $2,$1}' >> ${f}
			#c=$( grep -c "^>" ${base}.fa )

			c=$( grep -c "^@${base}" ${fastq} )

			echo "total_reads ${c}" >> ${f}
			a=$( samtools view -c -F 4 ${base}.${ref}.loc.bam )
			echo "unaligned $[${c}-${a}]" >> ${f}
			chmod a-w $f
		fi

	done

#		f=${base}.fa
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#			#cat $r1 $r2 | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' -e 's/ (.)/\/\1 /'  -e 's/ .*$//' > ${f}
#			cat $fastq | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' > ${f}
#			chmod a-w $f
#		fi
#	
#		f=${base}.pieces
#		if [ -d $f ] ; then	#	&& [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#			mkdir $f
#			split -d --suffix-length=6 --additional-suffix=.fa --lines=100 ${base}.fa ${f}/
#			#chmod a-w $f
#		fi
#	
#		#	mature hg38 nt
#		for ref in viral.masked hairpin mature ; do
#	
#			# @M04104:246:000000000-D6RBR:1:1101:13542:1883 2:N:0:CTGAAGCT+GTACTGAC
#	
#	#		f=${base}.${ref}.blastn.tsv.gz
#	#		if [ -f $f ] && [ ! -w $f ] ; then
#	#			echo "Write-protected $f exists. Skipping."
#	#		else
#	#			echo "Creating $f"
#	#			zcat $r1 $r2 | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' -e 's/ (.)/\/\1 /'  -e 's/ .*$//' | blastn -num_threads 40 -outfmt 6 -db ${ref} | gzip --best > ${f}
#	#			chmod a-w $f
#	#		fi
#	
#	
#			f=${base}.${ref}.blastn.tsv.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				echo "Creating $f"
#				ls ${base}.pieces/*fa | parallel --no-notice --joblog ${base}.${ref}.parallel.blastn.log -j40 blastn -query {} -outfmt 6 -db ${ref} -out {}.${ref}.blastn.out 2\> {}.${ref}.blastn.err
#				cat ${base}.pieces/*fa.${ref}.blastn.out | gzip --best > ${f}
#				chmod a-w $f
#			fi
#	
#			f=${base}.${ref}.blastn.tsv.gz.counts
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				echo "Creating $f"
#				zcat ${base}.${ref}.blastn.tsv.gz | awk '{print $1,$2}' | sort | uniq | awk '{print $2}' | sort | uniq -c > ${f}
#				chmod a-w $f
#			fi
#	
#		done

done 


#for ref in viral.masked hairpin mature ; do
#	echo "Summarizing ${ref}"
#
#	f=summary.${ref}.blastn.tsv.gz.counts
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Creating $f"
#		awk '{print $2}' *.${ref}.blastn.tsv.gz.counts | sort | uniq -c | sort -r -n > ${f}
#		chmod a-w $f
#	fi
#
#	f=summary.${ref}.loc.bam.counts
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Creating $f"
#		awk '{print $2}' *.${ref}.loc.bam.counts | sort | uniq -c | sort -r -n > ${f}
#		chmod a-w $f
#	fi
#
#done



