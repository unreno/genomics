### Creating an EBS Volume on the fly

Using EBS volume on the fly (can I do this on my local machine or just EC2 instance? just instance)


It's a little outdated, however still good in principle

* Create volume
* Attach volume
* Make filesystem
* Mount
* Use
* Unmount
* Detach volume
* Delete volume



#### Original Source

From https://edoceo.com/blog/2009/02/amazon-ebs-how-to-grow-storage

##### Amazon EBS – How to Grow the Storage | Edoceo's Blog
###### Amazon EBS – How to Grow the Storage

Amazon Web Services, Engineering, linux
Seen loads of good posts about EBS describing how to use them to provide cross instance persistent storage. Really it’s awesome. All the EC2 images store to their own EBS and if the EC2 crashes a new one can be resumed with minimal downtime. Amazon has nice pictures about this use case.

Quite simple to increase the size of an EBS volume, just: create, attach, mount, write, umount, snapshot, create, attach, check, resize, check, mount, delete. We’re going to walk through the process using Amazon EC2 command line tools.

Create the initial volume and attach to an EC2 instance.

```BASH
$ ec2-create-volume --size 1 --availability-zone us-east-1a
$ ec2-attach-volume vol-3b0eea52 -i i-7b648e12 -d /dev/sdx1
```

The device name can be anything you want, we’ve used /dev/sdx, /dev/sdVolume, /dev/sdebs1. There doesn’t appear to be any restrictions on this file name or location. We currently use the convention of /dev/ebs#

In the EC2 image make a file system on this volume then mount and populate.

```BASH
# mke2fs -j -L'EBS_Test' /dev/sdx1
# mount /dev/sdx1 /mnt/ebs1
# for f in /etc /opt /var/www; do rdiff-backup $f /mnt/ebs1/$f; done
```

###### Actually Resizing

Super easy, minimal downtime. Here’s the precautious way to do it. Unmount the EBS, create snapshot of EBS. Create new Volume with Snapshot at new size, resizefs, mount.

```BASH
# (ec2-host) umount /dev/sdx1
$ ec2-create-snapshot vol-3b0eea52
$ ec3-describe-snapshots
$ ec2-create-volume  --availability-zone us-east-1a --size 2 --snapshot snap-b954bbd0
$ ec2-describe-volumes
$ ec2-attach-volume vol-360eea5f -i i-7b648e12 -d /dev/sdx2
# (ec2-host) e2fsck -f /dev/sdx2
# (ec2-host) resize2fs -p /dev/sdx2
# (ec2-host) e2fsck -f /dev/sdx2
# (ec2-host) tune2fs -l /dev/sdx2
# (ec2-host) mount /dev/sdx2 /mnt/ebs2
```

Once you’re sure the EBS has re-mounted and is clean with all your data you can then go back and delete the original volume.

```BASH
$ ec2-describe-volumes
$ ec2-detach-volume vol-3b0eea52
$ ec2-delete-volume vol-3b0eea52
```

###### Summary

Create the volume has you see fit with a reasonable size. Fill with data then when space runs out plan on some short down time. Then snapshot, re-create, resize and re-mount. Adjustments need to be made for different file system types.

