#### EC2 User-Data

If using the `--user-data file://my_local_script` option with the `aws ec2 run-instances` command 
on an Amazon Linux, there are a few quirks.

The contents of this file will be executed as root, not as the default ec2-user and in the / dir.

I created test.data and add the option `--user-data file://test.data`

```BASH
#!/usr/bin/env bash
touch "FROMUSERDATA"
echo "FROMUSERDATA" > FROMUSERDATA.log
env > FROMUSERDATA.env
```

After it became available, I logged in as ec2-user.


```
ec2-user@ip-172-31-29-235 ~]$ ll /FROM*
-rw-r--r--  1 root     0 Jul  7 23:46 FROMUSERDATA
-rw-r--r--  1 root   226 Jul  7 23:46 FROMUSERDATA.env
-rw-r--r--  1 root    13 Jul  7 23:46 FROMUSERDATA.log
```

```
[ec2-user@ip-172-31-29-235 ~]$ cat /FROMUSERDATA.env 
TERM=linux
PATH=/sbin:/usr/sbin:/bin:/usr/bin
RUNLEVEL=3
runlevel=3
PWD=/
LANGSH_SOURCED=1
LANG=en_US.UTF-8
PREVLEVEL=N
previous=N
CONSOLETYPE=serial
SHLVL=4
UPSTART_INSTANCE=
UPSTART_EVENTS=runlevel
UPSTART_JOB=rc
_=/bin/env
```


As I found this not to be to my liking, my user data files are now like.

```BASH
#!/usr/bin/env bash
su -l ec2-user -c 'nohup REMOTE_COMMAND &'
```

