#!/usr/bin/env bash

#	find . -type d \( -name HG\* -o -name NA\* \) -depth 1 -execdir sh -c 'echo {}; cd {}; pwd' \;
#
#	Something odd happened when I actually did this.  It crossed some file limit and crashed.  Twice.  Both times it had processed about 1000 samples.  Somehow when the above was run with align_herv_k113_chimerics_to_index (instead of pwd), it kept file handles opened(?) and when it ran out, it crashed.  Need to investigate.  Somehow.  Just tried on my laptop with similar script, without any processing and no problems.  I really don’t understand "limits"


#	Perhaps "lsof" can help?


#    called like ...
#    find . -type d \( -name HG\* -o -name NA\* \) -depth 1 -execdir sh -c 'echo {}; cd {}; /Users/jakewendt/herv/hg38_alignment/test_limits.sh' \;

mkdir testing
cd testing
for i in `seq 1000` ; do
	{
		echo "Starting $i at ..."
		date
		mkdir $i
		cd $i
			echo testing > logfile
			lsof | wc -l | awk '{print "lsof count "$0}'
			lsof > logfile
			echo "Finished $i at ..."
			date
		cd ..
	} 1>>$i.`basename $0`.out 2>&1
done
