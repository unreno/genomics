#!/usr/bin/env bash





set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail

set -x



#!!!
# PLEASE MAKE CHANGES ON 
#	run.config	
# SO THAT ALL PARAMETERS ARE SET PROPERLY
#
# Please change RNA_BOWTIE_INDEX in run.config file so that it points the right folder
#
#RNA_BOWTIE_INDEX=$QuickMIRSeq/database/human/db_stranded_0
#
# !!!

#!!!
#
# Please make sure bowtie and cutadapt excutables are avaliables !!!
#
# Please make sure these two Perl modules Config::Simple and Parallel::ForkManager installed
#
# Please install R packages: reshape2, ggplot2, latticeExtra and scales
#
#!!!!

#!!!
# please point it to your QuickMIRSeq install directory
#export QuickMIRSeq=/hpc/grid/shared/ngsapp/QuickMIRSeq
export QuickMIRSeq=/home/jake/.local/QuickMIRSeq
export PATH=$QuickMIRSeq:$PATH
#
#!!!


#
#if you are working in LSF cluster, you can submit your job as below.
#otherwise, just run "perl  $QuickMIRSeq/QuickMIRSeq.pl  allIDs.txt run.config"
#
#bsub -app large -n 13 -o QuickMIRSeq.log -e QuickMIRSeq.err "perl  $QuickMIRSeq/QuickMIRSeq.pl  allIDs.txt run.config"


echo "Running QuickMIRSeq.pl"
perl  $QuickMIRSeq/QuickMIRSeq.pl  allIDs.txt run.config
#perl  $QuickMIRSeq/QuickMIRSeq.pl  headIDs.txt run.config
echo "QuickMIRSeq.pl Finished"



echo "Starting QuickMIRSeq-report.sh"
#run summarization after step #1 is done (PLEASE WAIT).
cd output
$QuickMIRSeq/QuickMIRSeq-report.sh
cd ..
echo "QuickMIRSeq-report.sh Finished"


# packaging (optional): if you want to share your results, you can package all needed files as below
# please run this "tar" command in the PARENT folder of your OUTPUT folder. 
# Replace "demo.tgz" AND "output" with appropriate names.
# The "output" folder name is specified in the run.config file when you run QuickMIRSeq.pl script.
#
tar -zcvf demo.tgz --exclude='unmapped.csv' --exclude='mapped.csv' --exclude='trimmed' --exclude='bowtie_temp' --exclude='alignment' output/*

#NOTE: you can deploy demo.tgz anywhere. After unpacking, you just need a web browser to open index.html


