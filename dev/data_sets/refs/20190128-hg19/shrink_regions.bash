#!/usr/bin/env bash


for f in *.nonhg19.txt ; do
	base=$( basename $f .nonhg19.txt )
	echo $f
	cat $f

	region_count=$( cat $f | sed 's/ /\n/g' | wc -l )

	if [ $region_count -gt 1 ] ; then
		echo "Has $region_count regions"

		cat $f | sed -e 's/ /\n/g' -e 's/[:-]/\t/g' | awk -v s=1000 -v region_count=$region_count -F"\t" '
			( NR == 1 ){
				if( $3 > s ){
					print($1":"$2"-"$3-s)
				}
				next
			}
			( NR == region_count ){
				print($1":"$2+s"-"$3)
				next
			}
			{
				if( $3-$2 > 2*s ){
					print($1":"$2+s"-"$3-s)
				}
			}' | tr "\n" " " > ${base}.nonhg19.shrunk1000.txt

#		i=0
#		for r in $( cat $f ); do
#			((i++))
#			echo $r
#			if [ $i -eq 1 ] ; then
#				echo "first region"
#
#				echo $r | sed 's/[:-]/\n/g' )
#
#			elif [ $i -eq $region_count ] ; then
#				echo "last region"
#
#			else
#				echo "mid region"
#
#			fi
#
#		done

	else
		echo "Has only 1 region"
	fi

done
