#!/usr/bin/env bash

#	find . -type d \( -name HG\* -o -name NA\* \) -depth 1 -execdir sh -c 'echo {}; cd {}; pwd' \;
#
#	Something odd happened when I actually did this.  It crossed some file limit and crashed.  Twice.  Both times it had processed about 1000 samples.  Somehow when the above was run with align_herv_k113_chimerics_to_index (instead of pwd), it kept file handles opened(?) and when it ran out, it crashed.  Need to investigate.  Somehow.  Just tried on my laptop with similar script, without any processing and no problems.  I really don’t understand "limits"




#    called like ...
#    find . -type d \( -name HG\* -o -name NA\* \) -depth 1 -execdir sh -c 'echo {}; cd {}; /Users/jakewendt/herv/hg38_alignment/test_limits.sh' \;

base=`basename $PWD`

{
    echo "Starting at ..."
    date

    echo "Not really doing anything."
    
#    for i in $(seq 1 20); do echo "blah" > `basename $0`.out.$i; done

#    no problems running this on my mac.
#    Need to try on an ec2 instance and see what happens.

    echo
    echo "Finished at ..."
    date

} 1>>$base.`basename $0`.out 2>&1

