#### plinking on AWS EC2

Some stats from running `aws_plink_wrapper.bash` on several different instance types in July 2016.


type      | cost        | sets | time   | cost / set
--------- | ----------- | ---- | ------ | ------------
t2.micro  | $0.013 / hr |   6  | 23 hrs | $ 0.05 / set
t2.medium | $0.052 / hr |  21  | 23 hrs | $ 0.057 / set
c4.large  | $0.105 / hr |  53  | 23 hrs | $ 0.0455 / set
t2.large  | $0.104 / hr |  33  | 23 hrs | $ 0.0725 / set
m3.medium | $0.067 / hr |  6   |  7 hrs | $ 0.0782 / set
m3.xlarge | $0.266 / hr |  17  |  7 hrs | $ 0.109 / set
m3.large  | $0.133 / hr |  15  |  7 hrs | $ 0.062 / set

Cancelled t2.micro (too slow) and m3.xlarge (too expensive)

type      | cost        | sets | time   | cost / set
--------- | ----------- | ---- | ------ | ------------
t2.medium | $0.052 / hr |  37  | 40 hrs | $ 0.056 / set
c4.large  | $0.105 / hr |  78  | 40 hrs | $ 0.0538 / set
t2.large  | $0.104 / hr |  54  | 40 hrs | $ 0.077 / set
m3.medium | $0.067 / hr |  22  | 24 hrs | $ 0.069 / set
m3.large  | $0.133 / hr |  47  | 24 hrs | $ 0.068 / set


`awsdb -e "select hostname, avg(timediff(completed_at, started_at)) as time, count(1) as count from queue where completed_at IS NOT NULL group by hostname"`

+------------------+------------+-------+
| hostname         | time       | count |
+------------------+------------+-------+
| NULL             |     0.0000 |  6643 |
| ip-172-31-13-55  | 38296.5000 |     6 |
| ip-172-31-20-126 |  9665.0278 |    37 |
| ip-172-31-21-149 |  3006.5065 |    78 |
| ip-172-31-3-160  |  4387.6981 |    54 |
| ip-172-31-33-109 | 10230.2381 |    22 |
| ip-172-31-6-13   |  2385.7222 |    18 |
| ip-172-31-8-34   |  3028.4130 |    47 |
+------------------+------------+-------+

