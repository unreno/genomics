#!/usr/bin/env bash


#for f in $( find /francislab/data1/ -type l ) ; do
while read f ; do
	link=$( readlink -m "$f" )
	#if [[ ${link} == "/home/gwendt/github/ucsffrancislab/genomics"* ]] ; then
	if [[ ${link} == "/c4/home/gwendt/github/unreno/unreno"* ]] ; then
		link=${link/\/c4\/home\/gwendt\/github\/unreno\/unreno/\/c4\/home\/gwendt\/github\/unreno}
		echo chmod +w $( dirname "${f}" )
		echo rm -f "${f}"
		echo ln -s "${link}" "${f}"
	fi
	if [[ ${link} == "/home/jake/.github/unreno/genomics"* ]] ; then
		#echo $f
		#echo $link
		#link=${link/\/home\/jake\/.github\/unreno\/genomics\/scripts/\/home\/gwendt\/github\/unreno\/unreno\/genomics\/dev}
		link=${link/\/home\/jake\/.github\/unreno\/genomics\/scripts/\/home\/gwendt\/github\/unreno\/genomics\/dev}
		link=${link/\/home\/jake\/.github/\/home\/gwendt\/github}
		echo chmod +w $( dirname "${f}" )
		echo rm -f "${f}"
		echo ln -s "/c4${link}" "${f}"
	fi
#done
#done < <( find /francislab/data1/refs/ -type l )
#done < <( find /francislab/data1/ -type l )
done < <( find -L /francislab/data1/working/ -type l )
#done < <( find -L /francislab/data1/working/CCLS/ -type l )
#done < <( find -L /francislab/data1/working/1000genomes/ -type l )
#done < <( find -L /francislab/data1/working/CCLS_983899/ -type l )

#	using the while loop seems to work better than the for loop
#	I think that the for loop won't execute the first iteration until the find command completes.


#	Find dead links with ...
#		find . -xtype l
#			OR
#		find -L . -type l

