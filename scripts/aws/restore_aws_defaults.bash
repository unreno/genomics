#!/usr/bin/env bash


#	aws ec2 create-vpc --cidr-block 172.31.0.0/16
#	-> VPCID

#	aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-support 
#	aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-hostnames



#	aws ec2 create-subnet --cidr-block 172.31.0.0/20 --vpc-id $VPCID --availability-zone us-east-1a
#	-> SUBNETID1
#	aws ec2 create-subnet --cidr-block 172.31.16.0/20 --vpc-id $VPCID --availability-zone us-east-1b
#	-> SUBNETID2



#	aws ec2 create-internet-gateway
#	-> IGID

#	aws ec2 attach-internet-gateway --internet-gateway-id IGID --vpc-id $VPCID
#	-> Nothing



#	aws ec2 describe-route-tables --query 'RouteTables[].RouteTableId'
#	-> RTID

#	aws ec2 create-route --route-table-id RTID --destination-cidr-block 0.0.0.0/0 --gateway-id IGID
#	-> Nothing


#	Default VPC security group needs modified to include
#	SSH / TCP / 22 / Anywhere / 0.0.0.0/0
#	(Apparently ALL / ALL / ALL isn’t good enough)
#
#	Is this security group automatically created with the VPC?
#
#	aws ec2 describe-security-groups --filters "Name=description,Values=default VPC security group" --query 'SecurityGroups[].GroupId'
#	-> SGID ARRAY

#	aws ec2 describe-security-groups --filters "Name=vpc-id,Values=VPCID,Name=description,Values=default VPC security group"  --query 'SecurityGroups[].GroupId'



#Explicitly enable ssh
#aws ec2 authorize-security-group-ingress \
#	--protocol tcp --port 22 --cidr 0.0.0.0/0 \
#	--group-id SGID

#Explicitly enable mysql access (3306)
#aws ec2 authorize-security-group-ingress \
#	--protocol tcp --port 22 --cidr 0.0.0.0/0 \
#	--group-id SGID



#aws rds create-db-subnet-group --db-subnet-group-name queuedbsubnetgroupname --db-subnet-group-description queuedbsubnetgroupdescription --subnet-ids subnet-abcea5dd subnet-186dee40
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

#	aws rds describe-db-subnet-groups

