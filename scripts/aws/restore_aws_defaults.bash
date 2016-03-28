#!/usr/bin/env bash


#	This would not be so difficult if I hadn't deleted much of this.
#	The vpc, subnets, groups, gateways, route tables, and security 
#	groups would all exist and this would've been simpler.
#	Live and learn.
#	Perhaps I should destroy everything again,
#	create a script that "restores AWS defaults"
#	and then rewrite this script.


#	This is a bit of a challenge.
#	Everything seems to have a dependence.
#	The db instance needs a ....
#		vpc security group id (why id here)
#		db subnet group name (and why name here)
#		The group needs at least 2 subnets in 2 difference AZs?
#			(can I still access from my local computer?)
#		Each subnet needs to be defined in a sub cidr range of the vpc.
#	
#	I think that I should just create using the GUI
#	and then examine the results.
#
#	And there is an inconsistency in the parameter naming conventions.
#	Sometimes it is "id", other times its "name"
#	Sometimes it is complete like "security-group-name", other times its short like "group-name"
#

#I really need to just start over. I need to understand this new concept of VPCs, subnets, AZs, subnet groups, cidr blocks, security groups, db security groups, ingress, gateways, route tables. Do these cidr blocks need to be in the same range for the ec instance to access the database?



#	aws ec2 create-vpc --cidr-block 172.31.0.0/16
#	-> VPCID

#	aws ec2 create-subnet --cidr-block 172.31.0.0/20 --vpc-id $VPCID
#	-> SUBNETID
#	aws ec2 create-subnet --cidr-block 172.31.16.0/20 --vpc-id $VPCID
#	-> SUBNETID

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

#Explicitly enable ssh
#aws ec2 authorize-security-group-ingress \
#	--protocol tcp --port 22 --cidr 0.0.0.0/0 \
#	--group-id SGID



#
#	The above is what was done to prepare to create EC2 Instances, NOT a database.
#	Some of it needs redone or additionally done for the database.
#



#	aws ec2 describe-vpcs
#	aws ec2 describe-subnets
#	aws ec2 describe-internet-gateways
#	aws ec2 describe-route-tables
#	aws ec2 describe-security-groups --filters "Name=vpc-id,Values=VPCID,Name=description,Values=default VPC security group"  --query 'SecurityGroups[].GroupId'


#	This is beyond ridiculous now ..
#	Create a VPC
#	Create 2 EC2 subnets (can’t overlap, must be 2 diff AZs)
#	aws ec2 create-subnet
#
#	aws ec2 create-vpc --cidr-block 10.0.0.0/16
#	{
#    "Vpc": {
#        "InstanceTenancy": "default", 
#        "State": "pending", 
#        "VpcId": "vpc-a6434cc2", 
#        "CidrBlock": "10.0.0.0/16", 
#        "DhcpOptionsId": "dopt-513bc334"
#    }
#}

VPCID="vpc-a6434cc2"

#	aws ec2 create-subnet --cidr-block 10.0.0.0/20 --vpc-id $VPCID
#	--availability-zone "us-east-1a"
#	need to define az?

#	aws ec2 create-subnet --cidr-block 10.0.0.0/20 --availability-zone us-east-1a --vpc-id $VPCID
#{
#    "Subnet": {
#        "VpcId": "vpc-a6434cc2", 
#        "CidrBlock": "10.0.0.0/20", 
#        "State": "pending", 
#        "AvailabilityZone": "us-east-1a", 
#        "SubnetId": "subnet-abcea5dd", 
#        "AvailableIpAddressCount": 4091
#    }
#}
#	aws ec2 create-subnet --cidr-block 10.0.16.0/20 --availability-zone us-east-1b --vpc-id $VPCID
#{
#    "Subnet": {
#        "VpcId": "vpc-a6434cc2", 
#        "CidrBlock": "10.0.16.0/20", 
#        "State": "pending", 
#        "AvailabilityZone": "us-east-1b", 
#        "SubnetId": "subnet-186dee40", 
#        "AvailableIpAddressCount": 4091
#    }
#}



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

#	Because this isn't my "DEFAULT" vpc, the ip addresses 
#	will not be public unless explicitly specified!
#	Cannot create a publicly accessible DBInstance because customer VPC has no internet gateway attached.

#	aws ec2 create-internet-gateway
#	-> IGID
#	aws ec2 attach-internet-gateway --internet-gateway-id IGID --vpc-id $VPCID
#	-> Nothing



#	aws ec2 describe-route-tables
#	aws ec2 describe-route-tables --query 'RouteTables[].RouteTableId'
#	-> RTID ARRAY

#	aws ec2 create-route --route-table-id RTID --destination-cidr-block 0.0.0.0/0 --gateway-id IGID
#	aws ec2 create-route --route-table-id rtb-96f05df1  --destination-cidr-block 0.0.0.0/0 --gateway-id igw-72890d16
#	{
#	    "Return": true
#	}



#	You cannot perform this operation. The DB instance is publicly accessible, but the host VPC does not support DNS resolution and/or hostnames. (the default vpc would)
#	Do separately
#	aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-support 
#	aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-hostnames

#aws rds create-db-instance \
#	--publicly-accessible
#	--engine mariadb \
#	--allocated-storage 5 \
#	--db-instance-class db.t2.micro \
#	--db-instance-identifier queuedbinstanceid \
#	--master-username myawsuser \
#	--master-user-password myawspassword \
#	--db-name queuedbname \
#	--db-subnet-group-name queuedbsubnetgroupname

#{
#    "DBInstance": {
#        "PubliclyAccessible": true, 
#        "MasterUsername": "myawsuser", 
#        "MonitoringInterval": 0, 
#        "LicenseModel": "general-public-license", 
#        "VpcSecurityGroups": [
#            {
#                "Status": "active", 
#                "VpcSecurityGroupId": "sg-6f7e0717"
#            }
#        ], 
#        "CopyTagsToSnapshot": false, 
#        "OptionGroupMemberships": [
#            {
#                "Status": "in-sync", 
#                "OptionGroupName": "default:mariadb-10-0"
#            }
#        ], 
#        "PendingModifiedValues": {
#            "MasterUserPassword": "****"
#        }, 
#        "Engine": "mariadb", 
#        "MultiAZ": false, 
#        "DBSecurityGroups": [], 
#        "DBParameterGroups": [
#            {
#                "DBParameterGroupName": "default.mariadb10.0", 
#                "ParameterApplyStatus": "in-sync"
#            }
#        ], 
#        "AutoMinorVersionUpgrade": true, 
#        "PreferredBackupWindow": "03:14-03:44", 
#        "DBSubnetGroup": {
#            "Subnets": [
#                {
#                    "SubnetStatus": "Active", 
#                    "SubnetIdentifier": "subnet-186dee40", 
#                    "SubnetAvailabilityZone": {
#                        "Name": "us-east-1b"
#                    }
#                }, 
#                {
#                    "SubnetStatus": "Active", 
#                    "SubnetIdentifier": "subnet-abcea5dd", 
#                    "SubnetAvailabilityZone": {
#                        "Name": "us-east-1a"
#                    }
#                }
#            ], 
#            "DBSubnetGroupName": "queuedbsubnetgroupname", 
#            "VpcId": "vpc-a6434cc2", 
#            "DBSubnetGroupDescription": "queuedbsubnetgroupdescription", 
#            "SubnetGroupStatus": "Complete"
#        }, 
#        "ReadReplicaDBInstanceIdentifiers": [], 
#        "AllocatedStorage": 5, 
#        "BackupRetentionPeriod": 1, 
#        "DBName": "queuedbname", 
#        "PreferredMaintenanceWindow": "fri:06:50-fri:07:20", 
#        "DBInstanceStatus": "creating", 
#        "EngineVersion": "10.0.17", 
#        "StorageType": "standard", 
#        "DbiResourceId": "db-5BZYRDENNAEY66UWAMOECGSOCM", 
#        "CACertificateIdentifier": "rds-ca-2015", 
#        "StorageEncrypted": false, 
#        "DBInstanceClass": "db.t2.micro", 
#        "DbInstancePort": 0, 
#        "DBInstanceIdentifier": "queuedbinstanceid"
#    }
#}

#	WAIT for it to start to get endpoints

#	aws rds describe-db-instances






#aws ec2 describe-security-groups --filters "Name=description,Values=default VPC security group" --query 'SecurityGroups[].GroupId'
#[
#    "sg-6f7e0717", 
#    "sg-9c9413fa"
#]
#aws ec2 authorize-security-group-ingress --protocol tcp --port 3306 --cidr 0.0.0.0/0 --group-id sg-6f7e0717




#	aws rds describe-db-instances --query "DBInstances[].Endpoint"
#[
#    {
#        "Port": 3306, 
#        "Address": "queuedbinstanceid.c8xrmj8azb5r.us-east-1.rds.amazonaws.com"
#    }
#]

#	mysql --user myawsuser --password --port 3306 --host queuedbinstanceid.c8xrmj8azb5r.us-east-1.rds.amazonaws.com
#
#
#				SUCCESS!!!!
#
#












#	If need to delete ...
#	aws rds delete-db-instance --db-instance-identifier queuedbinstanceid --skip-final-snapshot
#	Deleting can take several minutes
