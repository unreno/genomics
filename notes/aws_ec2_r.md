#### EC2 and R

Not sure if this will be worthy of noting, but I've been made to understand that installing R isn't always straight forward.
On my Mac it was a simple `sudo port install R` and then wait about an hour.



http://blogs.helsinki.fi/bioinformatics-viikki/documentation/getting-started-with-r-programming/installingrlatest/#macosx

suggests the following for ...

Installing the latest R on CentOS:

Add the latest EPEL repository which you can find from here. Don’t forget to add the 64 bit f you are using a 64 bit OS. I have a CentOS release 5.8, 64 bit (Check the Ubuntu installation section of this document if you don’t know your Linux distribution or whether it is 64 or 32 bit ) and I used the following script to add the proper repository:

$ `sudo rpm -Uvh http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm`

Then install R using this script:

$ `sudo yum install R`


Of course, Amazon Linux isn't CentOS, but that's the plan.

Not sure if its needed, but this is the latest.

`http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/epel/epel-release-latest-7.noarch.rpm`





I've also read that some optional already-included rpms just need to be enabled like so.


```
vim /etc/yum.repos.d/redhat.repo

[rhel-6-server-optional-rpms]
...
enabled = 1
```




Also may need to install additional modules.

`yum list R-\*`







Once R was installed on my local machine, I had to install the 'qqman' package.

```R
R
> install.packages("qqman")
> q()
```

then the command 

`Rscript scripts/aws_plink_plots.r`

