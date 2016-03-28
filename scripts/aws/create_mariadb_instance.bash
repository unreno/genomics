#!/usr/bin/env bash


#	aws rds describe-db-subnet-groups

#	May have to ...

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
