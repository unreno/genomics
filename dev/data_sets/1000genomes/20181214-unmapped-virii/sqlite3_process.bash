#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail

p=5 #	percent threshold use to call common coverage

database_file="viral_mapped_unmapped.${p}.sqlite3"

sqlite3 ${database_file} "CREATE TABLE subjects( subject, unmapped, mapped, total );
CREATE UNIQUE INDEX subjects_subject ON subjects (subject);"

for virus in /raid/refs/fasta/virii/*fasta ; do
	virus=$( basename $virus .fasta )
	virus=${virus/./_}
	#echo $virus
	sqlite3 ${database_file} "ALTER TABLE subjects ADD COLUMN ${virus}"
	sqlite3 ${database_file} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}"
	sqlite3 ${database_file} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}_unmapped"
	sqlite3 ${database_file} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}_total"
done

#for bam in $( find /raid/data/raw/1000genomes/phase3/data/ -name *unmapped*bam ) ; do
for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*unmapped*bam ; do
	echo "------------------------------------------------------------"
	base=$( basename $bam )
	subject=${base%.unmapped.ILLUMINA.bwa*}
	echo $bam
	echo $base
	echo $subject

	echo "Processing $subject"

	unmapped=$( cat unmapped.count.txt/${subject}.unmapped.count.txt )
	mapped=$( cat mapped.count.txt/${subject}.mapped.count.txt )
	total=$( cat total.count.txt/${subject}.total.count.txt )

	command="INSERT INTO subjects( subject, unmapped, mapped, total ) VALUES ( '${subject}', '${unmapped}', '${mapped}', '${total}' );"
	echo "${command}"
	sqlite3 ${database_file} "${command}"

	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )
		v=${virus/./_}

		echo "Processing $subject / $virus"

		virus_mapped_count=$( cat bowtie2.mapped.count.txt/${subject}.${virus}.bowtie2.mapped.count.txt )

		#command="UPDATE subjects SET '${virus}' = ${virus_mapped_count} WHERE subject = \"${subject}\""
		command="UPDATE subjects SET ${v} = \"${virus_mapped_count}\" WHERE subject = \"${subject}\""
		echo "${command}"
		sqlite3 ${database_file} "${command}"

		virus_mapped_uncommon_count=$( cat bowtie2.mapped_uncommon.1000.${p}.count.txt/${subject}.${virus}.bowtie2.mapped_uncommon.${p}.count.txt )

		#command="UPDATE subjects SET 'Uncommon ${virus}' = ${virus_mapped_uncommon_count} WHERE subject = \"${subject}\""
		command="UPDATE subjects SET uncommon_${v} = \"${virus_mapped_uncommon_count}\" WHERE subject = \"${subject}\""
		echo "${command}"
		sqlite3 ${database_file} "${command}"

	done

done

for virus in /raid/refs/fasta/virii/*fasta ; do
	virus=$( basename $virus .fasta )
	virus=${virus/./_}
	command="UPDATE subjects SET uncommon_${virus}_unmapped = 1.0 * uncommon_${virus} / unmapped;"
	echo "${command}"
	sqlite3 ${database_file} "${command}"
	command="UPDATE subjects SET uncommon_${virus}_total = 1.0 * uncommon_${virus} / total;"
	echo "${command}"
	sqlite3 ${database_file} "${command}"
done


echo "---"
echo "Done"
