#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



database_file="unmapped_viral_mapped.sqlite3"

sql="sqlite3 ${database_file}"

if [ ! -f ${database_file} ] ; then

	${sql} "CREATE TABLE subjects( subject, unmapped, mapped, total ); CREATE UNIQUE INDEX subjects_subject ON subjects (subject);"

	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )
		virus=${virus/./_}
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}"
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}_unmapped"
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}_total"
		${sql} "ALTER TABLE subjects ADD COLUMN nonhg19_${virus}"
		${sql} "ALTER TABLE subjects ADD COLUMN nonhg19_${virus}_unmapped"
		${sql} "ALTER TABLE subjects ADD COLUMN nonhg19_${virus}_total"
	done

fi


previous="/raid/data/working/1000genomes/20181214-unmapped-virii"

for fastagz in ${previous}/*.fasta.gz ; do
	echo "------------------------------------------------------------"
	base=$( basename $fastagz .fasta.gz )
	subject=${base}
	echo $fastagz
	echo $base
	echo $subject

	echo "Processing $subject"

	if [ -z $( ${sql} "SELECT unmapped FROM subjects WHERE subject = '${subject}'" ) ] ; then
		mapped=$( cat ${previous}/${subject}/${subject}.mapped.count.txt )
		unmapped=$( cat ${previous}/${subject}/${subject}.unmapped.count.txt )
		total=$( cat ${previous}/${subject}/${subject}.total.count.txt )
		command="INSERT INTO subjects( subject, unmapped, mapped, total ) VALUES ( '${subject}', '${unmapped}', '${mapped}', '${total}' );"
		echo "${command}"
		${sql} "${command}"
	fi

	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )
		v=${virus/./_}

		echo "Processing $subject / $virus"

		if [ -z $( ${sql} "SELECT ${v} FROM subjects WHERE subject = '${subject}'" ) ] ; then
			count=$( cat ${previous}/${subject}/${subject}.${virus}.bowtie2.mapped.count.txt )
			command="UPDATE subjects SET ${v} = '${count}' WHERE subject = '${subject}'"
			echo "${command}"
			${sql} "${command}"
			command="UPDATE subjects SET ${v}_unmapped = 1.0 * ${v} / unmapped WHERE subject = '${subject}'"
			echo "${command}"
			${sql} "${command}"
			command="UPDATE subjects SET ${v}_total = 1.0 * ${v} / total WHERE subject = '${subject}'"
			echo "${command}"
			${sql} "${command}"
		fi

		region_file="/raid/data/working/refs/20190128-hg19/${virus}.nonhg19.shrunk1000.txt"

		if [ -f ${region_file} ] ; then

			f="${subject}.${virus}.bowtie2.mapped_nonhg19.count.txt"

			if [ -f ${f} ] && [ ! -w ${f} ]  ; then
				echo "Write-protected ${f} exists. Skipping step."
			else
				echo "Counting reads bowtie2 aligned non-hg19 to ${virus}"
				#	-F 4 needless here as filtered with this flag above.
	
				#	grep will return error code if no line found so add || true
				region=$( cat ${region_file} || true )

				echo "${region}"
				[ -z "${region}" ] && region="${virus}"
	
				samtools view -c -F 4 ${previous}/${subject}/${subject}.virii.bam ${region} > ${f}
	
				chmod a-w ${f}
			fi

			if [ -z $( ${sql} "SELECT nonhg19_${v} FROM subjects WHERE subject = '${subject}'" ) ] ; then
				count=$( cat ${f} )
				command="UPDATE subjects SET nonhg19_${v} = '${count}' WHERE subject = '${subject}'"
				echo "${command}"
				${sql} "${command}"
				command="UPDATE subjects SET nonhg19_${v}_unmapped = 1.0 * nonhg19_${v} / unmapped WHERE subject = '${subject}'"
				echo "${command}"
				${sql} "${command}"
				command="UPDATE subjects SET nonhg19_${v}_total = 1.0 * nonhg19_${v} / total WHERE subject = '${subject}'"
				echo "${command}"
				${sql} "${command}"
			fi

		fi

	done

done



#for virus in /raid/refs/fasta/virii/*fasta ; do
#	virus=$( basename $virus .fasta )
#	virus=${virus/./_}
#	command="UPDATE subjects SET ${virus}_unmapped = 1.0 * ${virus} / unmapped;"
#	echo "${command}"
#	${sql} "${command}"
#	command="UPDATE subjects SET ${virus}_total = 1.0 * ${virus} / total;"
#	echo "${command}"
#	${sql} "${command}"
#	command="UPDATE subjects SET nonhg19_${virus}_unmapped = 1.0 * nonhg19_${virus} / unmapped;"
#	echo "${command}"
#	${sql} "${command}"
#	command="UPDATE subjects SET nonhg19_${virus}_total = 1.0 * nonhg19_${virus} / total;"
#	echo "${command}"
#	${sql} "${command}"
#done


