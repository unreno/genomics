#!/usr/bin/env bash

function usage(){
	echo
	echo "Start an EC2 instance on AWS"
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` [--image-id AMI] [--instance-type AMITYPE] [--key KEY_WITH_PATH] [--user-data USERDATAFILE] [--volume-size INTEGER] [--NOT-DRY-RUN]"
	echo
	echo "--NOT-DRY-RUN is a boolean flag to ACTUALLY start instance (without, does not)"
	echo
	echo "Image IDs are region specific."
	echo "They must exist in the region specified in the user's ~/.aws/config"
	echo
	echo "Defaults:"
	echo
	echo " image_id ....... $image_id"
	echo " instance_type .. $instance_type"
	echo " key ............ $key (the key and file base name NEED to be the same)"
	echo " volume-size .... Default Image Volume Size"
	echo
	echo "Key Pairs can easily be create like ..."
	echo "aws ec2 create-key-pair --key-name KEYNAME --query 'KeyMaterial' --output text > ~/.aws/KEYNAME.pem"
	echo "Key Pairs are also region specific."
	echo
	echo "        vCPU   ECU  Memory(GiB) Linux/UNIX Usage"
	echo "General Purpose - Current Generation (US West 2 - 20160705)"
	echo "t2.nano   1  Variable  0.5  \$0.0065 per Hour"
	echo "t2.micro  1  Variable  1    \$0.013 per Hour (Free Tier)"
	echo "t2.small  1  Variable  2    \$0.026 per Hour"
	echo "t2.medium 2  Variable  4    \$0.052 per Hour"
	echo "t2.large  2  Variable  8    \$0.104 per Hour"
	echo
	echo "Example:"
	echo
	echo "`basename $0` --key ~/.aws/JakeHumanHome.pem --user-data aws_start_suicidal_queue.user_data"
	echo
	exit
}

# initial image id "ami-f303fb93"
#	image_id="ami-869552e6"	#	Base HERV 3
#image_id="ami-bbd918db"	#	Base HERV 4
#image_id="ami-3cbe7e5c"	#	Base HERV 5
image_id="ami-10c40470"	#	Base HERV 6
instance_type="t2.micro"
#instance_type="t2.medium"
key="~/.aws/KEYNAME.pem"
volume_size=10
dry_run="--dry-run"
#	--user-data file://aws_start_1000genomes_processing.sh
user_data=""
block=""	#	for the volume size

while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		--NOT-DRY-RUN)
			dry_run=""; shift ;;
		-in*|--in*)
			shift; instance_type=$1; shift ;;
		-im*|--im*)
			shift; image_id=$1; shift ;;
		-k*|--k*)
			shift; key=$1; shift ;;
		-u*|--u*)
			shift; user_data="--user-data file://$1"; shift ;;
		-v*|--v*)
			shift; block="--block-device-mappings DeviceName=/dev/xvda,Ebs={VolumeSize=${1},VolumeType=gp2}"; shift ;;
#          VirtualName=string,DeviceName=string,Ebs={SnapshotId=string,VolumeSize=integer,DeleteOnTermination=boolean,VolumeType=string,Iops=integer,Encrypted=boolean},NoDevice=string ...
		-h*|--h*)
			usage ;;
		--)	#	just -- is a common and explicit "stop parsing options" option
			shift; break ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break ;;
	esac
done

#       Basically, this is TRUE AND DO ...
[ $# -ne 0 ] && usage


key_name=${key%.*} # drop the shortest suffix match to ".*" (the .pem extension)
key_name=${key_name##*/}	#	drop the longest prefix match to "*/" (the path)



#	Get a subnet. Which one?
#	Subnet can only have X number of ip addresses. (X is over 4000, fyi)

#	select by vpcid. Which vpcid?
#	sort by AvailableIpAddressCount?

#	This should return that with the MOST available.
subnets=`aws ec2 describe-subnets`
echo $subnets
#aws ec2 describe-subnets
#{
#    "Subnets": [
#        {
#            "VpcId": "vpc-0f333c6b", 
#            "CidrBlock": "172.31.0.0/20", 
#            "MapPublicIpOnLaunch": false, 
#            "DefaultForAz": false, 
#            "State": "available", 
#            "AvailabilityZone": "us-east-1a", 
#            "SubnetId": "subnet-356f0543", 
#            "AvailableIpAddressCount": 4091
#        }, 
#        {
#            "VpcId": "vpc-0f333c6b", 
#            "CidrBlock": "172.31.16.0/20", 
#            "MapPublicIpOnLaunch": false, 
#            "DefaultForAz": false, 
#            "State": "available", 
#            "AvailabilityZone": "us-east-1b", 
#            "SubnetId": "subnet-0bca4853", 
#            "AvailableIpAddressCount": 4091
#        }
#    ]
#}


subnet_id=`echo $subnets | jq '.Subnets | sort_by(.AvailableIpAddressCount) | reverse[0].SubnetId' | tr -d '"'`
echo $subnet_id



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

#	20160405 - Newest version of above
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


vpcid=`aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" | jq '.Vpcs[].VpcId' | tr -d '"'`

echo "VPC ID: ${vpcid}"

sg=`aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcid,Name=description,Values=default VPC security group"`
sgid=`echo $sg | jq '.SecurityGroups[].GroupId' | tr -d '"'`
echo "Security Group Id: ${sgid}"

echo "Checking for existing ssh access"
ssh_access=`aws ec2 describe-security-groups --group-id ${sgid} --filters Name=group-name,Values=default Name=ip-permission.protocol,Values=tcp Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='0.0.0.0/0' --query 'SecurityGroups[*].{Name:GroupName}'`
if [ "$ssh_access" == "[]" ]; then
	echo "Explicitly enable ssh access (port 22)"
	aws ec2 authorize-security-group-ingress \
		--protocol tcp --port 22 --cidr 0.0.0.0/0 \
		--group-id $sgid
else
	echo "SSH Access already exists. Skipping."
fi

command="aws ec2 run-instances $dry_run $block
	--count 1
	--image-id $image_id
	--instance-type $instance_type
	--key-name ${key_name}
	--subnet-id $subnet_id
	--associate-public-ip-address
	--instance-initiated-shutdown-behavior terminate
	--iam-instance-profile Name='ec2_processor' ${user_data}"

#	--user-data file://aws_start_1000genomes_processing.sh
# --block-device-mappings '[{"DeviceName":"/dev/xvda", "Ebs":{"VolumeSize":100,"VolumeType":"gp2"}}]'
#	--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":'${volume_size}',"VolumeType":"gp2"}}]'
# --query 'Instances[].InstanceId'

#	'ec2_processor' was "ec2_processor". Double quotes versus single quotes matter???? Nope.

#	Double quotes preserve newlines (if they weren't escaped)
echo "$command"
instance=`$command`
echo "$instance"

instance_id=`echo "$instance" | jq '.Instances[].InstanceId' | tr -d '"'`
echo $instance_id




#$ aws ec2 describe-instances
#{
#    "Reservations": []
#}


command="aws ec2 describe-instances
	--query 'Reservations[0].Instances[0].PublicIpAddress'
	--instance-ids $instance_id"
echo
echo $command
echo
echo "ssh -i ${key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@#.#.#.#"
echo




#	Seems that it may be next to impossible to select the latest
#	Amazon Linux AMI programmatically

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


#	Rather than jq, can also use python to pick from json
#		line=`echo $message | python -c \
#			'import sys, json; print json.load(sys.stdin)["Messages"][0]["Body"]'`
#		echo $line
#
#		handle=`echo $message | python -c \
#			'import sys, json; print json.load(sys.stdin)["Messages"][0]["ReceiptHandle"]'`
#		echo $handle
