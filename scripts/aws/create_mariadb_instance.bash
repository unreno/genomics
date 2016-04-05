#!/usr/bin/env bash

function usage(){
	echo
	echo "Start a MariaDB instance on AWS"
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "`basename $0` --password PASSWORD [--username USERNAME]"
	echo
	echo "Defaults:"
	echo
	echo " username .. $username"
	echo " password .. "
	echo
	exit
}

username='MyAWSUser'
password=''

while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		-u*|--u*)
			shift; username=$1; shift ;;
		-p*|--p*)
			shift; password=$1; shift ;;
		-h*|--h*)
			usage ;;
		--)	#	just -- is a common and explicit "stop parsing options" command
			shift; break ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#       Basically, this is TRUE AND DO ...
[ -z $password ] && usage



#	Check if database with this id exists already.
#	Basically
#if [ `aws rds describe-db-instances | jq '.DBInstances | select(.DBInstanceIdentifier == "QueueDbInstanceId") | length'` -gt 0 ] ; then
#	echo -e "You've already got a Queue DB setup. You probably don't want to do this.\n"
#	exit
#fi
#
#	If there aren't any, jq crashes
#	


#	If not found, the following will be printed on the STDERR. I don't need it, so to dev null.
#	A client error (DBInstanceNotFound) occurred when calling the DescribeDBInstances operation: DBInstance QueueDbInstanceId not found.
qdbi=`aws rds describe-db-instances --db-instance-identifier QueueDbInstanceId 1> /dev/null 2>&1`
#	qdbi should be blank, so storing it is unnecessary.
status=$? 	#	0 when it exists, 255 when it doesn't
if [ $status -eq 0 ] ; then
	echo "QueueDbInstanceId already exists. Stopping."
	exit $status
fi

#	Basically, don't overwrite the cnf file if a db exists.

cat <<-EOF > awsqueue.cnf
[mysql]
user=$username
password=$password
database=QueueDbName
port=3306
host=
EOF
chmod 600 awsqueue.cnf

aws rds create-db-instance \
	--publicly-accessible \
	--engine mariadb \
	--allocated-storage 5 \
	--db-instance-class db.t2.micro \
	--db-instance-identifier QueueDbInstanceId \
	--master-username $username \
	--master-user-password $password \
	--db-name QueueDbName \
	--db-subnet-group-name DbSubnetGroupName

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





aws rds describe-db-instances --db-instance-identifier QueueDbInstanceId --query "DBInstances[].Endpoint"







#	If need to delete ...
#	aws rds delete-db-instance --db-instance-identifier queuedbinstanceid --skip-final-snapshot
#	Deleting can take several minutes





#	To simplify usage, ~/.my.cnf could be created to include the database specs.
#	Probably a good idea to "chmod 600 ~/.my.cnf"
#	Then simple call "mysql --defaults-group-suffix=awsqueue"
#[mysqlawsqueue]
#	host
#	port
#	user
#	password
#	database
#
#	This cnf file overwrites settings so last setting sticks.
#	eg
#		database=overwritten_db
#		database=used_db
#

#	Perhaps create an alias if you're really into it
#	alias mysql_awsqueue="mysql --defaults-group-suffix=awsqueue"

#	Or a separate defaults file could be created altogether. --defaults-file=HOST.cnf
#	(I like this option. Its isolated and can be created and destroyed with the database)

#	One could also use the encrypted version created by mysql_config_editor
#	if you are using >5.6, I think. (~/.mylogin.cnf)
#	Don't be fooled though. The file is encrypted, but the source code has the key.
#	I could easily modify and recompile the source and have the password.
#	IT IS NOT SECURE. Only fractionally moreso than ~/.my.cnf


echo "Running the following in a few minutes to get the hostname."

echo 'aws rds describe-db-instances --db-instance-identifier QueueDbInstanceId --query "DBInstances[].Endpoint'

echo "Then add it to the awsqueue.cnf file."

echo "Then connect simply via ..."

echo "mysql --defaults-file=awsqueue.cnf"



