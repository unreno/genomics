#### Modifying an Instance for Suicidabiliy

For purposes of clustering, starting bulk instances, never manually connecting, having them complete processing and then shut themselves down and go away, the following notes apply.

First off, the instance(s) should be started with the "terminate" behaviour.
Otherwise, they stay on your dashboard. You may actually be able to restart it.


```BASH
aws ec2 run-instances --instance-initiated-shutdown-behavior terminate
```


Also, the instance must allow the scripting of sudo and shutting down without being logged in.

```BASH
sudo shutdown -h now
```

sudo raises this error `sudo: sorry, you must have a tty to run sudo`

Adding -t, -tt, -ttt, -tttt to ssh doesn't change this but can get this instead....
Pseudo-terminal will not be allocated because stdin is not a terminal.

Only ...

`sudo visudo` and comment out the following lines ...
Defaults  requiretty
Defaults !visiblepw

... works.
I don't believe that this is scriptable on instance creation of a standard instance.
You'll need to create yet another AMI from your instance with this change.

http://unix.stackexchange.com/questions/49077


As AWS charges by the hour, use with caution.
If you start 100 instances and they immediately commit suicide,
that just cost you $5, or more depending on your options.


For 1000 genomes processing, I added the following option
when starting the instances.

```BASH
--user-data file://aws_start_1000genomes_processing.sh
```

This loaded a small LOCAL script as data and passed it to the new instance as ROOT.

```BASH
#!/usr/bin/env bash
su -l ec2-user -c 'nohup aws_1000genomes.sh --shutdown &> ~/aws_1000genomes.sh.log &'
```

I changed to the basic user for my script, which on completion called `sudo shutdown -h now`.

This seemed to work most of the time.



