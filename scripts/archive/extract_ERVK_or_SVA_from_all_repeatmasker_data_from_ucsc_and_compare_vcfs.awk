#
#
#
#	To preserve "NR==FNR" feature and avoid gunzipping everything ...
#
#		awk -f extract_ERVK_or_SVA_from_all_repeatmasker_data_from_ucsc_and_compare_vcfs.awk <(zcat all_repeatmasker_data_from_ucsc.txt) <(zcat original_vcfs/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr10.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr11.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr12.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr13.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr14.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr15.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr16.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr17.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr18.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr19.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr20.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr21.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr3.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr4.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr5.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr6.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr7.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr8.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chr9.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.chrY.phase3_integrated_v1b.20130502.genotypes.vcf.gz) <(zcat original_vcfs/ALL.wgs.integrated_sv_map_v2.20130502.svs.genotypes.vcf.gz)
#

BEGIN{
	OFS="\t"
	print "CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tEND\tLENGTH\tbin\tswScore\tmilliDiv\tmilliDel\tmilliIns\tgenoName\tgenoStart\tgenoEnd\tgenoLeft\tstrand\trepName\trepClass\trepFamily\trepStart\trepEnd\trepLeft\tid"
}
#
#	The repeat masker file ...
#	
#	$13 (repFamily) == ERVK
#			OR
#	$11 (repName) == SVA_A | SVA_B | SVA_C | SVA_D | SVA_E | SVA_F
#	
#	bin	swScore	milliDiv	milliDel	milliIns	genoName	genoStart	genoEnd	genoLeft	strand	repName	repClass	repFamily	repStart	repEnd	repLeft	id
#
( NR == FNR ) && ( ( $13 == "ERVK" ) || ( $11 ~ /^SVA_/ ) ){
#	genoName=$6	#	this will include "chr"
#	genoStart=$7
#	genoEnd=$8
	starts[$6][length(starts[$6])+1] = $7
	ends[$6][length(ends[$6])+1] = $8
	lines[$6][length(lines[$6])+1] = $0
}
#
#	The vcf files ...
#
#	1) the SVTYPE=DEL
#	2) deletion end position - start position > 100
#	3) matches a row in the extracted RMD file
#        -by chromosome number
#                AND
#         where deletion start is within 50bp upstream or downstream of the HERV or SVA start
#                                OR
#         where deletion end is within 50bp upstream or downstream of the HERV or SVA end
#
#	CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT .....
#
#	X	61438	BI_GS_DEL1_B1_P2898_3	A	<CN0>	100	PASS	AC=672;AF=0.134185;AN=5008;CIEND=0,1;CIPOS=0,1;END=61910;NS=2504;DP=18325;AMR_AF=0.0389;AFR_AF=0.171;EUR_AF=0.0378;SAS_AF=0.2076;EAS_AF=0.1766;SVTYPE=DEL;CS=DEL_union;MC=UW_VH_1291;VT=SV	G
( NR != FNR ) && ( /SVTYPE=DEL/ ){
	#	chromosome number = $1
	#	start position = $2
	#	end position = ;END=????;
#	print $8
	split($8,pairs,";")
	for( pair in pairs ){
		if( pairs[pair] ~ /^END=/ ){
			split(pairs[pair],keyvalue,"=")
			sp=$2
			ep=keyvalue[2]
			if( ( ep - sp ) > 100 ) {
				for( i in starts["chr"$1] ) {
					#	i is just an index (same as ends)
					s=starts["chr"$1][i]
					e=ends["chr"$1][i]
					if( ( ( s-50 < sp ) && ( s+50 > sp ) ) || ( ( e-50 < ep ) && ( e+50 > ep ) ) ){
						print $1,$2,$3,$4,$5,$6,$7,$8,ep,(ep-sp),lines["chr"$1][i]
#						print
#						print $1
#						print sp	#	$2
#						print ep	#	keyvalue[2]
#						print s,e
#						break	#	out of starts/ends loop	#	actually, could match multiple???
					}
				}
			}
			#	no need to check for another "END="
			break	#	out of pairs loop
		}
	}
}
