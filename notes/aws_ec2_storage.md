
From https://forums.aws.amazon.com/thread.jspa?threadID=155938

---

EBS is now default storage for any instances but I am confused regarding default size depends on any instances.

Let's say I want t2.medium, it just shows "EBS" and no size details as well as larger instances with SSD for example, it shows "1 X 4 SSD" for m3.medium but what does it mean and what is the size of it?

Can you please explain about this?

Thank you
Ray

---

Edited by: rayroh on Jul 7, 2014 2:45 PM
Permlink	Replies: 1 | Pages: 1 - Last Post: Jul 7, 2014 8:34 PM by: saids@AWS
Replies
Re: What is the size of storage for each instances?
Posted by:   saids@AWS
Posted on: Jul 7, 2014 8:34 PM
in response to: rayroh in response to: rayroh
 	Click to reply to this thread	Reply
Hello Ray,

Instance types that are not EBS only, support local instance storage as well as EBS. This means in step 4. Add Storage, you have the option to add the X number of local instance store SSD as secondary volumes. With EBS only instance types however, you can only add EBS as secondary volumes. As you may already know instance store (ephemeral) storage do not retain data if instance is stopped. These volumes can be used as cache or temporary. They are local to the instance and are faster.
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Storage.html
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html


---

Jake's addition...

The "1 x 4 SSD" and the like should really read, "EBS + optional 1 x 4 SSD"
For our current usage, the storage on all the instances are the same.



