#!/usr/bin/env bash

which -s jq
if [ $? -ne 0 ] ; then
	echo "This script requires jq for parsing output."
	exit
fi


aws rds describe-db-security-groups
aws rds describe-db-instances
aws rds describe-db-subnet-groups
aws ec2 describe-subnets
aws ec2 describe-security-groups
aws ec2 describe-internet-gateways
aws ec2 describe-route-tables
aws ec2 describe-vpcs


echo "Create a VPC, with security group and route table"
vpc=`aws ec2 create-vpc --cidr-block 172.31.0.0/16`

echo $vpc
#	pick it out and remove the double quotes
vpcid=`echo $vpc | jq '.Vpc.VpcId' | tr -d '"'`

echo $vpcid
#	-> VPCID

aws ec2 modify-vpc-attribute --vpc-id $vpcid --enable-dns-support 
aws ec2 modify-vpc-attribute --vpc-id $vpcid --enable-dns-hostnames

echo "Create 2 subnets in the VPC in different AZs"
subnet1=`aws ec2 create-subnet --cidr-block 172.31.0.0/20 --vpc-id $vpcid --availability-zone us-east-1a`
echo $subnet1
subnetid1=`echo $subnet1 | jq '.Subnet.SubnetId' | tr -d '"'`
echo $subnetid1

subnet2=`aws ec2 create-subnet --cidr-block 172.31.16.0/20 --vpc-id $vpcid --availability-zone us-east-1b`
echo $subnet2
subnetid2=`echo $subnet2 | jq '.Subnet.SubnetId' | tr -d '"'`
echo $subnetid2


echo "Create an internet gateway and route to assist in making it reachable locally."
ig=`aws ec2 create-internet-gateway`
echo $ig
igid=`echo $ig | jq '.InternetGateway.InternetGatewayId' | tr -d '"'`
echo $igid

aws ec2 attach-internet-gateway --internet-gateway-id $igid --vpc-id $vpcid


#	RouteTable gets created with the VPC
rt=`aws ec2 describe-route-tables`
echo $rt
rtid=`echo $rt | jq '.RouteTables[] | select(.VpcId == "'${vpcid}'").RouteTableId' | tr -d '"'`
echo $rtid

aws ec2 create-route --route-table-id $rtid --destination-cidr-block 0.0.0.0/0 --gateway-id $igid
#	-> Nothing



#	Default VPC security group needs modified to include
#	SSH / TCP / 22 / Anywhere / 0.0.0.0/0
#	(Apparently ALL / ALL / ALL isn’t good enough)
#
#	A security group is created with the vpc, just need to find it.
#
sg=`aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcid,Name=description,Values=default VPC security group"`
echo $sg
sgid=`echo $sg | jq '.SecurityGroups[].GroupId' | tr -d '"'`
echo $sgid


echo "Explicitly enable ssh access (port 22)"
aws ec2 authorize-security-group-ingress \
	--protocol tcp --port 22 --cidr 0.0.0.0/0 \
	--group-id $sgid

echo "Explicitly enable mysql/mariadb access (port 3306)"
aws ec2 authorize-security-group-ingress \
	--protocol tcp --port 3306 --cidr 0.0.0.0/0 \
	--group-id $sgid

subnetgroupname='dbsubnetgroupname'
subnetgroup=`aws rds create-db-subnet-group --db-subnet-group-name $subnetgroupname --db-subnet-group-description dbsubnetgroupdescription --subnet-ids $subnetid1 $subnetid2`
echo $subnetgroup

#{
#    "DBSubnetGroup": {
#        "Subnets": [
#            {
#                "SubnetStatus": "Active", 
#                "SubnetIdentifier": "subnet-186dee40", 
#                "SubnetAvailabilityZone": {
#                    "Name": "us-east-1b"
#                }
#            }, 
#            {
#                "SubnetStatus": "Active", 
#                "SubnetIdentifier": "subnet-abcea5dd", 
#                "SubnetAvailabilityZone": {
#                    "Name": "us-east-1a"
#                }
#            }
#        ], 
#        "DBSubnetGroupName": "queuedbsubnetgroupname", 
#        "VpcId": "vpc-a6434cc2", 
#        "DBSubnetGroupDescription": "queuedbsubnetgroupdescription", 
#        "SubnetGroupStatus": "Complete"
#    }
#}

echo
echo	"Done"
echo


aws rds describe-db-security-groups
aws rds describe-db-instances
aws rds describe-db-subnet-groups
aws ec2 describe-subnets
aws ec2 describe-security-groups
aws ec2 describe-internet-gateways
aws ec2 describe-route-tables
aws ec2 describe-vpcs

#
#	echo
#	echo	"Cleaning up"
#	echo
#
#
#	aws rds delete-db-subnet-group --db-subnet-group-name $subnetgroupname
#	aws ec2 delete-route --route-table-id $rtid --destination-cidr-block 0.0.0.0/0
#	aws ec2 detach-internet-gateway --internet-gateway-id $igid --vpc-id $vpcid
#	aws ec2 delete-internet-gateway --internet-gateway-id $igid
#	aws ec2 delete-subnet --subnet-id $subnetid2
#	aws ec2 delete-subnet --subnet-id $subnetid1
#	aws ec2 delete-vpc --vpc-id $vpcid
#
#
#
#	echo
#	echo	"Done"
#	echo
#
#
#	aws rds describe-db-security-groups
#	aws rds describe-db-instances
#	aws rds describe-db-subnet-groups
#	aws ec2 describe-subnets
#	aws ec2 describe-security-groups
#	aws ec2 describe-internet-gateways
#	aws ec2 describe-route-tables
#	aws ec2 describe-vpcs
#
#
