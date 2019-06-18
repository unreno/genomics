#!/usr/bin/env bash



#	#echo "chr,AD,0000,0001,0002,0003"
#	#echo "chr,AD,tumor,normal,shared,shared"
#	echo "chr,AD,tumor,normal,shared"
#	for chr in $(seq 1 22 ) X ; do
#	for AD in $( seq 0.20 0.01 0.50 ) ; do
#	echo -n ${chr},${AD}
#	for file in 0000 0001 0002 ; do
#	#for file in 0000 0001 0002 0003 ; do
#	#	echo 983899.recaled.${chr}.mpileup.MQ60.call.SNP.DP200.annotate.GNOMAD_AF.Bias.AD.${AD}.${file}.count
#	#	ls -l *.recaled.${chr}.mpileup.MQ60.call.SNP.DP200.annotate.GNOMAD_AF.Bias.AD.${AD}.${file}.count
#		v=$(cat *.recaled.${chr}.mpileup.MQ60.call.SNP.DP200.annotate.GNOMAD_AF.Bias.AD.${AD}.${file}.count)
#		echo -n ,${v}
#	done
#	echo
#	done
#	done

echo "AD,tumor,normal,shared"
for AD in $( seq 0.20 0.01 0.50 ) ; do
echo -n ${AD}
for file in 0000 0001 0002 ; do
	v=$( cat *.recaled.*.mpileup.MQ60.call.SNP.DP200.annotate.GNOMAD_AF.Bias.AD.${AD}.${file}.count | awk '{s+=$1}END{print s}' )
	echo -n ,${v}
done
echo
done

