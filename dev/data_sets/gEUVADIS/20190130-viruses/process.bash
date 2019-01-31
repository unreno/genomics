#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



database_file="viral_mapped.sqlite3"

sql="sqlite3 ${database_file}"

if [ ! -f ${database_file} ] ; then

	#${sql} "CREATE TABLE subjects( subject, unmapped, mapped, total ); CREATE UNIQUE INDEX subjects_subject ON subjects (subject);"
	${sql} "CREATE TABLE subjects( subject, total ); CREATE UNIQUE INDEX subjects_subject ON subjects (subject);"

	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )
		virus=${virus/./_}
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}; ALTER TABLE subjects ADD COLUMN ${virus}_total; ALTER TABLE subjects ADD COLUMN nonhg19_${virus}; ALTER TABLE subjects ADD COLUMN nonhg19_${virus}_total;"

		#	${sql} "ALTER TABLE subjects ADD COLUMN ${virus}"
		#	#${sql} "ALTER TABLE subjects ADD COLUMN ${virus}_unmapped"
		#	${sql} "ALTER TABLE subjects ADD COLUMN ${virus}_total"
		#	${sql} "ALTER TABLE subjects ADD COLUMN nonhg19_${virus}"
		#	#${sql} "ALTER TABLE subjects ADD COLUMN nonhg19_${virus}_unmapped"
		#	${sql} "ALTER TABLE subjects ADD COLUMN nonhg19_${virus}_total"
	done

fi


for subject in $( cat /raid/data/raw/gEUVADIS/subjects.txt ) ; do
	echo "------------------------------------------------------------"
	echo $subject

	echo "Processing $subject"

	mkdir -p $subject

	f="${subject}/${subject}.total.count.txt"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		echo "Counting all lines in lane 1 fastq files and dividing by 2."
		ls -l /raid/data/raw/gEUVADIS/${subject}*_1.fastq.gz
		#echo $( cat ${subject}/${subject}.mapped.count.txt )"+"$( cat ${subject}/${subject}.unmapped.count.txt ) | bc > ${f}
		echo $( zcat /raid/data/raw/gEUVADIS/${subject}*_1.fastq.gz | wc -l )"/2" | bc > ${f}
		#zcat /raid/data/raw/gEUVADIS/${subject}*_1.fastq.gz | wc -l > ${f}
		chmod a-w ${f}
	fi

	if [ -z $( ${sql} "SELECT total FROM subjects WHERE subject = '${subject}'" ) ] ; then
		#mapped=$( cat ${subject}/${subject}.mapped.count.txt )
		#unmapped=$( cat ${subject}/${subject}.unmapped.count.txt )
		total=$( cat ${subject}/${subject}.total.count.txt )
		#command="INSERT INTO subjects( subject, unmapped, mapped, total ) VALUES ( '${subject}', '${unmapped}', '${mapped}', '${total}' );"
		command="INSERT INTO subjects( subject, total ) VALUES ( '${subject}', '${total}' );"
		echo "${command}"
		${sql} "${command}"
	fi


	f="${subject}/${subject}.virii.bam"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		f="${subject}/${subject}.virii.unsorted.bam"
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			echo "Aligning ${subject} to all virii."
			bowtie2 --no-unal --all --threads 35 -q -x virii --very-sensitive \
				-U $( ls /raid/data/raw/gEUVADIS/${subject}*.fastq.gz | paste -sd ',' ) \
				2>> ${subject}/${subject}.virii.log | samtools view -F 4 -o ${f} -
			#chmod a-w ${subject}.virii.unsorted.bam
		fi

		echo "Sorting"
		samtools sort -o ${subject}/${subject}.virii.bam ${f}
		chmod a-w ${subject}/${subject}.virii.bam

		\rm ${f}
	fi 

	f="${subject}/${subject}.virii.bam.bai"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		echo "Indexing"
		samtools index ${subject}/${subject}.virii.bam
		chmod a-w ${f}
	fi

	#	f="${subject}/${subject}.virii.depth.csv"
	#	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
	#		echo "Write-protected ${f} exists. Skipping step."
	#	else
	#		echo "Getting depth"
	#		samtools depth -d 0 ${subject}/${subject}.virii.bam > ${f}
	#		chmod a-w ${f}
	#	fi

	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )
		v=${virus/./_}

		echo "Processing $subject / $virus"

		#	f="${subject}/${subject}.${virus}.depth.csv"
		#	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		#		echo "Write-protected ${f} exists. Skipping step."
		#	else
		#		echo "Getting depth"
		#		awk '( $1 == "'${virus}'" )' ${subject}/${subject}.virii.depth.csv > ${f}
		#		chmod a-w ${f}
		#	fi

		f="${subject}/${subject}.${virus}.bowtie2.mapped.count.txt"
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned to ${virus}"
			#	-F 4 needless here as filtered with this flag above.
			samtools view -c -F 4 ${subject}/${subject}.virii.bam ${virus} > ${f}
			chmod a-w ${f}
		fi

		if [ -z $( ${sql} "SELECT ${v} FROM subjects WHERE subject = '${subject}'" ) ] ; then
			count=$( cat ${subject}/${subject}.${virus}.bowtie2.mapped.count.txt )

			command="UPDATE subjects SET ${v} = '${count}', ${v}_total = 1.0 * ${v} / total WHERE subject = '${subject}'"
			echo "${command}"
			${sql} "${command}"


			#	command="UPDATE subjects SET ${v} = '${count}' WHERE subject = '${subject}'"
			#	echo "${command}"
			#	${sql} "${command}"
			#	#command="UPDATE subjects SET ${v}_unmapped = 1.0 * ${v} / unmapped WHERE subject = '${subject}'"
			#	#echo "${command}"
			#	#${sql} "${command}"
			#	command="UPDATE subjects SET ${v}_total = 1.0 * ${v} / total WHERE subject = '${subject}'"
			#	echo "${command}"
			#	${sql} "${command}"
		fi

		region_file="/raid/data/working/refs/20190128-hg19/${virus}.nonhg19.shrunk1000.txt"
		#region_file="/raid/data/working/refs/20190128-hg19/${virus}.nonhg19.shrunk2000.txt"

		if [ -f ${region_file} ] ; then

			f="${subject}/${subject}.${virus}.bowtie2.mapped_nonhg19.count.txt"

			if [ -f ${f} ] && [ ! -w ${f} ]  ; then
				echo "Write-protected ${f} exists. Skipping step."
			else
				echo "Counting reads bowtie2 aligned non-hg19 to ${virus}"
				#	-F 4 needless here as filtered with this flag above.
	
				#	grep will return error code if no line found so add || true
				region=$( cat ${region_file} || true )

				echo "${region}"
				[ -z "${region}" ] && region="${virus}"
	
				samtools view -c -F 4 ${subject}/${subject}.virii.bam ${region} > ${f}
	
				chmod a-w ${f}
			fi

			if [ -z $( ${sql} "SELECT nonhg19_${v} FROM subjects WHERE subject = '${subject}'" ) ] ; then
				count=$( cat ${f} )

				command="UPDATE subjects SET nonhg19_${v} = '${count}', nonhg19_${v}_total = 1.0 * nonhg19_${v} / total WHERE subject = '${subject}'"
				echo "${command}"
				${sql} "${command}"


				#	command="UPDATE subjects SET nonhg19_${v} = '${count}' WHERE subject = '${subject}'"
				#	echo "${command}"
				#	${sql} "${command}"
				#	#command="UPDATE subjects SET nonhg19_${v}_unmapped = 1.0 * nonhg19_${v} / unmapped WHERE subject = '${subject}'"
				#	#echo "${command}"
				#	#${sql} "${command}"
				#	command="UPDATE subjects SET nonhg19_${v}_total = 1.0 * nonhg19_${v} / total WHERE subject = '${subject}'"
				#	echo "${command}"
				#	${sql} "${command}"
			fi

		fi

	done

done

