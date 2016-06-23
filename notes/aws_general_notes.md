

3 IAM users have been created.


I have create 2 Access Keys and a SSH Key for myself.


SSH Keys can be created via

```BASH
aws ec2 create-key-pair \
	--key-name KEYNAME --query 'KeyMaterial' \
	--output text > ~/.aws/KEYNAME.pem
chmod 400 ~/.aws/KEYNAME.pem
```


Several IAM User Groups have been created giving differing access and permissions.



1 Role has been created, which is used primarily to control the EC2 instances access.


I have 


