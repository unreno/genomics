#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


sqlite3 viral_mapped_unmapped.sqlite3 "CREATE TABLE subjects( subject, unmapped, mapped, total );
CREATE UNIQUE INDEX subjects_subject ON subjects (subject);"

for virus in /raid/refs/fasta/virii/*fasta ; do
	virus=$( basename $virus .fasta )
	sqlite3 viral_mapped_unmapped.sqlite3 "ALTER TABLE subjects ADD COLUMN \"${virus}\""
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

	unmapped=$( cat ${subject}.unmapped.count.txt )
	mapped=$( cat ${subject}.mapped.count.txt )
	total=$( cat ${subject}.total.count.txt )

	command="INSERT INTO subjects( subject, unmapped, mapped, total ) VALUES ( '${subject}', '${unmapped}', '${mapped}', '${total}' );"
	echo "${command}"
	sqlite3 viral_mapped_unmapped.sqlite3 "${command}"

	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )

		echo "Processing $subject / $virus"

		virus_mapped_count=$( cat ${subject}.${virus}.bowtie2.mapped.count.txt )

		command="UPDATE subjects SET '${virus}' = ${virus_mapped_count} WHERE subject = \"${subject}\""
		echo "${command}"
		sqlite3 viral_mapped_unmapped.sqlite3 "${command}"

	done

done

echo "---"
echo "Done"
