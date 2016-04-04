#!/usr/bin/env bash

#username='MyAWSUser'

function usage(){
	echo
	echo "Start an EC2 instance on AWS"
	echo
	echo "Usage:"
	echo
#	echo "`basename $0` --password PASSWORD [--username $username]"
	echo "`basename $0`"
	echo
	exit
}

#password=''

while [ $# -ne 0 ] ; do
	case $1 in
#		-u|--u*)
#			shift; username=$1; shift ;;
#		-p|--p*)
#			shift; password=$1; shift ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#       Basically, this is TRUE AND DO ...
#[ -z $password ] && usage
[ $# -ne 0 ] && usage


#	Get a subnet. Which one?



#$ aws ec2 describe-images --image-ids ami-60b6c60a
#{
#    "Images": [
#        {
#            "VirtualizationType": "hvm", 
#            "Name": "amzn-ami-hvm-2015.09.1.x86_64-gp2", 
#            "Hypervisor": "xen", 
#            "ImageOwnerAlias": "amazon", 
#            "SriovNetSupport": "simple", 
#            "ImageId": "ami-60b6c60a", 
#            "State": "available", 
#            "BlockDeviceMappings": [
#                {
#                    "DeviceName": "/dev/xvda", 
#                    "Ebs": {
#                        "DeleteOnTermination": true, 
#                        "SnapshotId": "snap-a17f1036", 
#                        "VolumeSize": 8, 
#                        "VolumeType": "gp2", 
#                        "Encrypted": false
#                    }
#                }
#            ], 
#            "Architecture": "x86_64", 
#            "ImageLocation": "amazon/amzn-ami-hvm-2015.09.1.x86_64-gp2", 
#            "RootDeviceType": "ebs", 
#            "OwnerId": "137112412989", 
#            "RootDeviceName": "/dev/xvda", 
#            "CreationDate": "2015-10-29T18:17:23.000Z", 
#            "Public": true, 
#            "ImageType": "machine", 
#            "Description": "Amazon Linux AMI 2015.09.1 x86_64 HVM GP2"
#        }
#    ]
#}


#$ aws ec2 describe-images --image-ids ami-08111162
#
#{
#    "Images": [
#        {
#            "VirtualizationType": "hvm", 
#            "Name": "amzn-ami-hvm-2016.03.0.x86_64-gp2", 
#            "Hypervisor": "xen", 
#            "ImageOwnerAlias": "amazon", 
#            "SriovNetSupport": "simple", 
#            "ImageId": "ami-08111162", 
#            "State": "available", 
#            "BlockDeviceMappings": [
#                {
#                    "DeviceName": "/dev/xvda", 
#                    "Ebs": {
#                        "DeleteOnTermination": true, 
#                        "SnapshotId": "snap-12c47a84", 
#                        "VolumeSize": 8, 
#                        "VolumeType": "gp2", 
#                        "Encrypted": false
#                    }
#                }
#            ], 
#            "Architecture": "x86_64", 
#            "ImageLocation": "amazon/amzn-ami-hvm-2016.03.0.x86_64-gp2", 
#            "RootDeviceType": "ebs", 
#            "OwnerId": "137112412989", 
#            "RootDeviceName": "/dev/xvda", 
#            "CreationDate": "2016-03-16T23:48:08.000Z", 
#            "Public": true, 
#            "ImageType": "machine", 
#            "Description": "Amazon Linux AMI 2016.03.0 x86_64 HVM GP2"
#        }
#    ]
#}





#aws ec2 run-instances \
#    --image-id ami-60b6c60a \
#    --instance-type t2.micro \
#    --key-name HOMEKEY \
#    --instance-initiated-shutdown-behavior terminate \
#    --associate-public-ip-address \
#    --subnet-id subnet-947a73cd \
#    --iam-instance-profile Name="ec2_processor"
#
##    --block-device-mappings '[{"DeviceName":"/dev/xvda", "Ebs":{"VolumeSize":100,"VolumeType":"gp2"}}]' \
##    --query 'Instances[].InstanceId' \


#aws ec2 describe-instances \
#    --query 'Reservations[0].Instances[0].PublicIpAddress' \
#    --instance-ids INSTANCE_ID



#	ssh -i WORKKEY.pem ec2-user@#.#.#.#





#	rather than [] suffix, use map(select()) so output is an array.

#	images=`aws ec2 describe-images`
#$ echo $images | jq '.Images[] | length'
#66401
#$ echo $images | jq '.Images | map(select( .VirtualizationType == "hvm" )) | length'
#22494
#$ echo $images | jq '.Images | map(select( .VirtualizationType == "hvm" )) | map(select( .RootDeviceType == "ebs" )) | length'
#21705
#$ echo $images | jq '.Images | map(select( .VirtualizationType == "hvm" )) | map(select( .RootDeviceType == "ebs" )) | map(select( .Architecture == "x86_64" )) | length'
#21087
#$ echo $images | jq '.Images | map(select( .VirtualizationType == "hvm" )) | map(select( .RootDeviceType == "ebs" )) | map(select( .Architecture == "x86_64" ))  | map(select( .ImageOwnerAlias == "amazon" )) | length'
#852



