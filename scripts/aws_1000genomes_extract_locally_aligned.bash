#!/usr/bin/env bash

script_name=$(basename $0)
reference=SVAs_and_HERVs_KWHE
#size=100
threads=4
do_aws_stuff=true

function usage(){
	echo
	echo "REQUIRES jq be installed for parsing some output."
	echo
	echo "Usage: (for 1000 genomes data on S3)"
	echo
#	echo "$script_name [--reference BOWTIE2_INDEX] [--size GB_EBS_DISK_TO_USE] SUBJECT_NAME SAMPLE_NAME"
	echo "$script_name [--reference BOWTIE2_INDEX] SAMPLE_NAME RUN_ID"
	echo
	echo "Default:"
	echo "  reference .... ${reference}"
#	echo "  size ......... ${size}"
#	echo "  subject ...... ${subject}"
	echo
	echo "$script_name --reference SVAs_and_HERVs NA18566 ERR000069"
	echo
	exit 1
}


while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		-r*|--r*)
			shift; reference=$1; shift ;;
#		-s*|--s*)
#			shift; size=$1; shift ;;
		-t*|--t*)
			shift; threads=$1; shift ;;
#		-po*|--po*)
#			shift; population=$1; shift ;;
#		-ph*|--ph*)
#			shift; pheno_name=$1; shift ;;
		--skip_aws_stuff)
			shift; do_aws_stuff=false ;;
		--)	#	just -- is a common and explicit "stop parsing options" option
			shift; break ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

[ $# -ne 2 ] && usage

sample_name=$1
run_id=$2


WORK=$HOME/work
TMP=$WORK/tmp

#	Try to add some uniqueness to log file name
date=`date "+%Y%m%d%H%M%S"`
#log=$HOME/$script_name.$date.`hostname`.$1.$2.$$.log
log=$WORK/$script_name.$sample_name.$run_id.$date.log

S3=s3://herv/1000genomes/${reference}


/bin/rm -rf $WORK

mkdir -p $WORK
mkdir -p $TMP
cd $WORK

#set -v
set -x

#	Begin logging
{
	echo "Starting ..."
	date



	if [ $do_aws_stuff == 'true' ] ; then

		#	Check the sizes of the input files and compute needed EBS workspace.

		#	There aren't any intermediate files. All computation is in memory.
		#	Output to main drive so this EBS disk just needs to be large enough to hold these 2 files.
		#	No computation aside from addition is needed.

		#	aws s3 ls s3://1000genomes/phase3/data/NA21130/sequence_read/ERR250999_2.filt.fastq.gz | awk '{print $3}'
		#3237919545

		s1=$(aws s3 ls s3://1000genomes/phase3/data/${sample_name}/sequence_read/${run_id}_1.filt.fastq.gz | awk '{print $3}')
		s2=$(aws s3 ls s3://1000genomes/phase3/data/${sample_name}/sequence_read/${run_id}_2.filt.fastq.gz | awk '{print $3}')

		echo $s1, $s2

		#echo $[$[622797752+622797753]/1000000]
		#1245

		ebs_size=$[$[$[$s1+$s2]/1000000000]+2]
		echo $ebs_size

		#	The will take some testing to determine exact usage

		#	The size of the volume, in GiBs.


		az=$( curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ )

		#curl http://169.254.169.254/latest/dynamic/instance-identity/document
		#{
		#  "devpayProductCodes" : null,
		#  "privateIp" : "172.31.11.163",
		#  "availabilityZone" : "us-west-2c",
		#  "version" : "2010-08-31",
		#  "instanceId" : "i-0905ad558e681257c",
		#  "billingProducts" : null,
		#  "instanceType" : "t2.micro",
		#  "pendingTime" : "2017-10-25T19:56:48Z",
		#  "accountId" : "372018666448",
		#  "architecture" : "x86_64",
		#  "kernelId" : null,
		#  "ramdiskId" : null,
		#  "imageId" : "ami-665f9006",
		#  "region" : "us-west-2"
		#}
		region=$( curl http://169.254.169.254/latest/dynamic/instance-identity/document | jq '.region' | tr -d '"' )


		#WHY are region AND availability zone needed? If az is given, region can only be 1 thing!

		command="aws ec2 create-volume --region ${region} --availability-zone ${az} --volume-type gp2 --size ${ebs_size}"
		echo $command
		response=$( $command )
		echo "$response"
		volume_id=$( echo "$response" | jq '.VolumeId' | tr -d '"' )
		$echo $volume_id
		#	vol-1234567890abcdef0


		aws ec2 describe-volumes --region ${region} --volume-id $volume_id


		instance_id=$( curl http://169.254.169.254/latest/meta-data/instance-id )

		#	device names ... /dev/sd[f-p]

		state="creating"
		echo "Waiting for state to become 'available'"
		until [ "$state" == "available" ] ; do
			state=$( aws ec2 describe-volumes --region ${region} --volume-id ${volume_id} | jq '.Volumes[0].State' | tr -d '"' )
		done


		command="aws ec2 attach-volume --region ${region} --device xvdf --instance-id ${instance_id} --volume-id ${volume_id}"
		echo $command
		response=$( $command )
		echo "$response"

		state="attaching"
		echo "Waiting for state to become 'in-use'"
		until [ "$state" == "in-use" ] ; do
			state=$( aws ec2 describe-volumes --region ${region} --volume-id ${volume_id} | jq '.Volumes[0].State' | tr -d '"' )
		done




		#	as it is possible that some mount points may linger, check ?
		#	[ -e /dev/xvdf ] ....



		sudo file -s /dev/xvdf
		#	-> data
		#	(/dev/sdf would be a link so not helpful)


		#	Need to create file system on volume
		sudo mkfs -t ext4 /dev/xvdf


		sudo file -s /dev/xvdf
		#	-> /dev/xvdf: Linux rev 1.0 ext4 filesystem data, UUID=0366fdd8-7691-4b3f-be37-2b03a33586a9 (extents) (large files) (huge files)


		sudo mount /dev/xvdf $TMP


		df -h $TMP
		#	Filesystem      Size  Used Avail Use% Mounted on
		#	/dev/xvdf       976M  1.3M  908M   1% /home/ec2-user/ebsdrive

		#	Note the loss of 1%


		#	Owned by root so only writable by root unless ...
		sudo chmod 777 $TMP

	fi

	aws s3 cp s3://1000genomes/phase3/data/${sample_name}/sequence_read/${run_id}_1.filt.fastq.gz  $TMP
	aws s3 cp s3://1000genomes/phase3/data/${sample_name}/sequence_read/${run_id}_2.filt.fastq.gz  $TMP


	: ${BOWTIE2_INDEXES:="$HOME/BOWTIE2_INDEXES"}
	#       they MUST be exported, apparently, to be picked up by bowtie2
	export BOWTIE2_INDEXES

	sr1=${sample_name}.${run_id}_1.${reference}.fasta.gz
	sr2=${sample_name}.${run_id}_2.${reference}.fasta.gz
	bowtie2 --very-sensitive-local --threads $threads -x $reference \
		-q -1 $TMP/${run_id}_1.filt.fastq.gz -2 $TMP/${run_id}_2.filt.fastq.gz \
		| gawk -F"\t" '
#			BEGIN { OFS="\t" }
			( /^@/ ){ print; next; }
			( !and($2,4) || !and($2,8) ){
#	Add aligned reference to read name? Or not?
#				$1=$1 "_" $3
				print }
		' \
		| samtools fasta -c 9 -1 $sr1 -2 $sr2 -
#		| samtools fasta -c 9 -1 ${sample_name}.${run_id}_1.${reference}.fasta.gz -2 ${sample_name}.${run_id}_2.${reference}.fasta.gz -
#		| samtools fastq -c 9 -1 ${sample_name}.${run_id}_1.${reference}.fastq.gz -2 ${sample_name}.${run_id}_2.${reference}.fastq.gz -

#			FASTQ or FASTA?
#
#

	#	 -s file True if file exists and has a size greater than zero.
	[ -s $sr1 ] && aws s3 cp $sr1 ${S3}/
	[ -s $sr2 ] && aws s3 cp $sr2 ${S3}/

	if [ $do_aws_stuff == 'true' ] ; then

		#	Apparently MUST be unmounted before will detach
		sudo umount /dev/xvdf

	
		command="aws ec2 detach-volume --region ${region} --volume-id ${volume_id}"
		echo $command
		response=$( $command )
		echo $response

		state="in-use"
		echo "Waiting for state to become 'available'"
		until [ "$state" == "available" ] ; do
			state=$( aws ec2 describe-volumes --region ${region} --volume-id ${volume_id} | jq '.Volumes[0].State' | tr -d '"' )
		done


	#{
	#    "Volumes": [
	#        {
	#            "AvailabilityZone": "us-west-2c",
	#            "Attachments": [
	#                {
	#                    "AttachTime": "2017-10-25T19:56:49.000Z",
	#                    "InstanceId": "i-0905ad558e681257c",
	#                    "VolumeId": "vol-00aa03a7f36fd9e9c",
	#                    "State": "attached",
	#                    "DeleteOnTermination": true,
	#                    "Device": "/dev/xvda"
	#                }
	#            ],
	#            "Encrypted": false,
	#            "VolumeType": "gp2",
	#            "VolumeId": "vol-00aa03a7f36fd9e9c",
	#            "State": "in-use", 													<---- will be "available" when detached
	#            "Iops": 100,
	#            "SnapshotId": "snap-23f09873",
	#            "CreateTime": "2017-10-25T19:56:49.426Z",
	#            "Size": 8
	#        }
	#    ]
	#}


		command="aws ec2 delete-volume --region ${region} --volume-id ${volume_id}"
		echo $command
		response=$( $command )
		echo $response

	fi

	echo "Ending ..."
	date

} > ${log} 2>&1

#	Must stop logging at some point so can upload file.

aws s3 cp ${log} ${S3}/

#rm ${log}

cd ~




exit

#	FASTQ_FILE	MD5	RUN_ID	STUDY_ID	STUDY_NAME
#	CENTER_NAME	SUBMISSION_ID	SUBMISSION_DATE	SAMPLE_ID	SAMPLE_NAME
#	POPULATION	EXPERIMENT_ID	INSTRUMENT_PLATFORM	INSTRUMENT_MODEL	LIBRARY_NAME
#	RUN_NAME	RUN_BLOCK_NAME	INSERT_SIZE	LIBRARY_LAYOUT	PAIRED_FASTQ
#	WITHDRAWN	WITHDRAWN_DATE	COMMENT	READ_COUNT	BASE_COUNT	ANALYSIS_GROUP

#	data/HG03679/sequence_read/SRR824936_1.filt.fastq.gz


#	awk -F"\t" '{print $13}' ~/s3/1000genomes/sequence.index | sort | uniq -c
#	$13
#  10103 ABI_SOLID	( has sequences like T13032221311013301003131010001102030 )
# 174185 ILLUMINA
#      1 INSTRUMENT_PLATFORM
#   3432 LS454

tail -n +2 ~/s3/1000genomes/sequence.index | awk -F"\t" '( $20 ~ /2.filt.fastq.gz$/ && $26 != "exome" && $13 == "ILLUMINA" ){ print $10, $3, $25 }' | sort -n -k3 -r | awk '{print "aws_1000genomes_extract_locally_aligned.bash",$1,$2 }'

#	-> 37065


