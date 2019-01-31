#!/usr/bin/env bash


for s in 1000 2000 ; do

	for f in *.nonhg19.txt ; do
		base=$( basename $f .nonhg19.txt )
		echo $f
		cat $f
	
		region_count=$( cat $f | sed 's/ /\n/g' | wc -l )
	
		if [ $region_count -gt 1 ] ; then
			echo "Has $region_count regions"
	
			cat $f | sed -e 's/ /\n/g' -e 's/[:-]/\t/g' | awk -v s=${s} -v region_count=$region_count -F"\t" '
				( NR == 1 ){
					if( $3 > s ){
						print($1":"$2"-"$3-s)
					}
					next
				}
				( NR == region_count ){
					if( $3-$2 > s ){
						print($1":"$2+s"-"$3)
					}
					next
				}
				{
					if( $3-$2 > 2*s ){
						print($1":"$2+s"-"$3-s)
					}
				}' | paste -s -d ' ' > ${base}.nonhg19.shrunk${s}.txt
#				}' | tr "\n" " " > ${base}.nonhg19.shrunk${s}.txt
	
		else
			echo "Has only 1 region"
			cp $f ${base}.nonhg19.shrunk${s}.txt
		fi
	
	done

done
