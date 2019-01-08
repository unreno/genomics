#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



p=2 #	percent threshold use to call common coverage

database_file="viral_mapped_unmapped.2000.${p}.sqlite3"

sql="sqlite3 ${database_file}"

if [ ! -f ${database_file} ] ; then

	${sql} "CREATE TABLE subjects( subject, unmapped, mapped, total ); CREATE UNIQUE INDEX subjects_subject ON subjects (subject);"

	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )
		virus=${virus/./_}
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}"
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}_unmapped"
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}_total"
		${sql} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}"
		${sql} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}_unmapped"
		${sql} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}_total"
	done

fi


for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*unmapped*bam ; do
	echo "------------------------------------------------------------"
	base=$( basename $bam )
	subject=${base%.unmapped.ILLUMINA.bwa*}
	echo $bam
	echo $base
	echo $subject

	echo "Processing $subject"

	f="${subject}/${subject}.unmapped.count.txt"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		echo "Counting reads in $bam.bai"
		#samtools view -c $bam > ${subject}.unmapped.count.txt
		cat $bam.bai | bamReadDepther | grep "^*\|^#" | awk -F"\t" '{s+=$NF}END{print s}' > ${f}
		chmod a-w ${f}
	fi

	f="${subject}/${subject}.mapped.count.txt"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		mapped_bam=${bam/.unmapped/.mapped}
		echo "Counting reads in $mapped_bam.bai"
		#	DIFFERENT THAN UNMAPPED
		cat $mapped_bam.bai | bamReadDepther | grep "^#" | awk -F"\t" '{s+=$2+$3}END{print s}' > ${f}
		chmod a-w ${f}
	fi

	f="${subject}/${subject}.total.count.txt"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		echo "Adding mapped and unmapped read counts."
		echo $( cat ${subject}/${subject}.mapped.count.txt )"+"$( cat ${subject}/${subject}.unmapped.count.txt ) | bc > ${f}
		chmod a-w ${f}
	fi

	if [ -z $( ${sql} "SELECT unmapped FROM subjects WHERE subject = '${subject}'" ) ] ; then
		mapped=$( cat ${subject}/${subject}.mapped.count.txt )
		unmapped=$( cat ${subject}/${subject}.unmapped.count.txt )
		total=$( cat ${subject}/${subject}.total.count.txt )
		command="INSERT INTO subjects( subject, unmapped, mapped, total ) VALUES ( '${subject}', '${unmapped}', '${mapped}', '${total}' );"
		echo "${command}"
		${sql} "${command}"
	fi


	#	blastn only accepts fasta. Bowtie2 can take either. Not sure if bowtie2 uses the quality

	f="${subject}.fasta.gz"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		echo "Extracting fasta reads from $bam"
		samtools fasta -N $bam 2>> ${subject}/${subject}.fasta.log | gzip --best > ${f}
		chmod a-w ${f}
	fi

	f="${subject}/${subject}.virii.bam"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else

		f="${subject}/${subject}.virii.sorted.bam"
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			echo "Aligning ${subject} to all virii."


#	Hmm. All?

			bowtie2 --all --threads 35 -f --xeq -x virii --very-sensitive -U ${subject}/${subject}.fasta.gz 2>> ${subject}/${subject}.virii.log | samtools view -F 4 -o ${f} -


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

	f="${subject}/${subject}.virii.depth.csv"
	if [ -f ${f} ] && [ ! -w ${f} ]  ; then
		echo "Write-protected ${f} exists. Skipping step."
	else
		echo "Getting depth"
		samtools depth ${subject}/${subject}.virii.bam > ${f}
		chmod a-w ${f}
	fi


	for virus in /raid/refs/fasta/virii/*fasta ; do
		virus=$( basename $virus .fasta )
		v=${virus/./_}

		echo "Processing $subject / $virus"

		f="${subject}/${subject}.${virus}.depth.csv"
		if [ -f ${f} ] && [ ! -w ${f} ]  ; then
			echo "Write-protected ${f} exists. Skipping step."
		else
			echo "Getting depth"


			awk '( $1 == "'${virus}'" )' ${subject}/${subject}.virii.depth.csv > ${f}
#			samtools depth ${subject}.${virus}.bam > ${subject}.${virus}.depth.csv



			chmod a-w ${f}
		fi


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
			command="UPDATE subjects SET ${v} = '${count}' WHERE subject = '${subject}'"
			echo "${command}"
			${sql} "${command}"
		fi





		for g in 2000 ; do

			#		for p in 50 25 5 ; do
			#		for p in 5 ; do
			for p in 2 ; do
	
				if [ -f common_regions/common_regions.${g}.${p}.${virus}.txt ] ; then

					f="${subject}/${subject}.${virus}.bowtie2.mapped_uncommon.${g}.${p}.count.txt"
		
					if [ -f ${f} ] && [ ! -w ${f} ]  ; then
						echo "Write-protected ${f} exists. Skipping step."
					else
						echo "Counting reads bowtie2 aligned uncommon.${g}.${p} to ${virus}"
						#	-F 4 needless here as filtered with this flag above.
			
						#	grep will return error code if no line found so add || true
						region=$( grep Samtools common_regions/common_regions.${g}.${p}.${virus}.txt || true )
		
						echo $region
						region=${region#Samtools uncommon regions: }
						#common_regions.D13784.1.txt:Samtools uncommon regions: D13784.1:1-4163 D13784.1:4208-7649 D13784.1:7691-8000 D13784.1:8053-1000000
			
						echo "${region}"
						[ -z "${region}" ] && region="${virus}"
			
						samtools view -c -F 4 ${subject}/${subject}.virii.bam ${region} > ${f}
			
						chmod a-w ${f}
					fi
		
					if [ -z $( ${sql} "SELECT uncommon_${v} FROM subjects WHERE subject = '${subject}'" ) ] ; then
						count=$( cat ${f} )
						command="UPDATE subjects SET uncommon_${v} = '${count}' WHERE subject = '${subject}'"
						echo "${command}"
						${sql} "${command}"
					fi

				fi

			done

		done

#		if [ -f bowtie2.mapped.ratio_unmapped.txt/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] && [ ! -w bowtie2.mapped.ratio_unmapped.txt/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] ; then
#			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${virus} bowtie2 alignments to total unaligned reads"
#			echo "scale=9; "$(cat bowtie2.mapped.count.txt/${subject}.${virus}.bowtie2.mapped.count.txt)"/"$(cat unmapped.count.txt/${subject}.unmapped.count.txt) | bc > bowtie2.mapped.ratio_unmapped.txt/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
#			chmod a-w bowtie2.mapped.ratio_unmapped.txt/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
#		fi
#
#		if [ -f bowtie2.mapped.ratio_total.txt/${subject}.${virus}.bowtie2.mapped.ratio_total.txt ] && [ ! -w bowtie2.mapped.ratio_total.txt/${subject}.${virus}.bowtie2.mapped.ratio_total.txt ] ; then
#			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.ratio_total.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${virus} bowtie2 alignments to total reads"
#			echo "scale=9; "$(cat bowtie2.mapped.count.txt/${subject}.${virus}.bowtie2.mapped.count.txt)"/"$(cat total.count.txt/${subject}.total.count.txt) | bc > bowtie2.mapped.ratio_total.txt/${subject}.${virus}.bowtie2.mapped.ratio_total.txt
#			chmod a-w bowtie2.mapped.ratio_total.txt/${subject}.${virus}.bowtie2.mapped.ratio_total.txt
#		fi

	done

done


for virus in /raid/refs/fasta/virii/*fasta ; do
	virus=$( basename $virus .fasta )
	virus=${virus/./_}
	command="UPDATE subjects SET ${virus}_unmapped = 1.0 * ${virus} / unmapped;"
	echo "${command}"
	${sql} "${command}"
	command="UPDATE subjects SET ${virus}_total = 1.0 * ${virus} / total;"
	echo "${command}"
	${sql} "${command}"
	command="UPDATE subjects SET uncommon_${virus}_unmapped = 1.0 * uncommon_${virus} / unmapped;"
	echo "${command}"
	${sql} "${command}"
	command="UPDATE subjects SET uncommon_${virus}_total = 1.0 * uncommon_${virus} / total;"
	echo "${command}"
	${sql} "${command}"
done



echo "---"
echo "Done"
