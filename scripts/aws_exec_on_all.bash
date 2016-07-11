#!/usr/bin/env bash

function usage(){
	echo
	echo "Usage:"
	echo
	echo "`basename $0` [--instance-type AWS INSTANCE TYPE] <remote command>"
	echo
	echo "Example:"
	echo "  `basename $0` 'ls *pid'"
	echo "	`basename $0` 'ps -fU ec2-user'"
	echo
	exit 1
}

instance_type=""

while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		-i*|--i*)
			shift; instance_type="Name=instance-type,Values=$1 "; shift ;;
		--)	#	just -- is a common and explicit "stop parsing options" option
			shift; break ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break;;
	esac
done

#	Basically, this is TRUE AND DO ...
[ $# -eq 0 ] && usage
#[ $# -ne 1 ] && usage

remote_command=$@

#	Don't think needed. What happens in scripts, stays in scripts!
initial_IFS=$IFS
#echo "x${IFS}x"
#	Don't get it. When print it, it "looks" like its newline already.
#	Nevertheless ...
IFS=$'\n'
#	From "man bash" ... <space><tab><newline>, the default,

i=0
cmd="aws ec2 describe-instances --filters 'Name=instance-state-name,Values=running' ${instance_type} --query 'Reservations[].Instances[].[PublicIpAddress,KeyName]' --output text"
echo $cmd
echo 
for ip_and_keyname in $(eval $cmd) ; do

	let i++
#	echo $i
#	echo "${ip_and_keyname}"
	ip=${ip_and_keyname%%	*}
#	echo "${ip}"
	key=${ip_and_keyname##*	}
#	echo "${key}"

	local_command="ssh -q -n -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${HOME}/.aws/${key}.pem -l ec2-user ${ip} ${remote_command}"

	echo "${local_command}"

	#	NEEDS default IFS and NO backticks!
	IFS=$initial_IFS
	${local_command}
	IFS=$'\n'

	echo "---"
done

#	Don't think needed. What happens in scripts, stays in scripts!
#	Nevertheless ...
IFS=$initial_IFS

