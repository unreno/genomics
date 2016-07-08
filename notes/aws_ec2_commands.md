#### EC2 Commands


Start 10 new instances ...

`./scripts/aws/create_ec2_instance.bash --key ~/.aws/JakeHuman.pem --instance-type c4.large --user-data scripts/aws_start_suicidal_queue.user_data --volume 30 --count 10`

Check the queue times ...

`awsdb -e 'select hostname, avg(timediff(completed_at,started_at)) as time, count(1) as count from queue group by hostname order by time;'`


Why does that last one have such a high average time? What's its ip-address, given all I have is its hostname, ip-172-31-7-82, which is based on its private ip address?

`aws ec2 describe-instances --filters "Name=private-ip-address,Values=172.31.7.82" --query 'Reservations[0].Instances[].PublicIpAddress'`


