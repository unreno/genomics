#	if R2 and seq name is same as buffered, print both
#	MUST use gawk for the bitwise command "and"

function reverse(s){
	x=""
	for(i=length(s);i!=0;i--)
		x=x substr(s,i,1);
	return x;
}

function reverse_complement(s){
	x=""
	for(i=length(s);i!=0;i--)
		x=x comp[substr(s,i,1)];
	return x;
}

function print_to_fastq( name, flags, sequence, quality ){
	lane=(and(flags,64))?"1":"2";
	filename=base"."lane".fastq"

	sequence=(and(flags,16))?reverse_complement(sequence):sequence;
	quality=(and(flags,16))?reverse(quality):quality;

	print "@"name"/"lane >> filename
	print sequence >> filename
	print "+" >> filename
	print quality >> filename
}

#	Check flags for lanes
#	Check flags for REVERSE mappeing


BEGIN {
	comp["A"]="T";
	comp["T"]="A";
	comp["C"]="G";
	comp["G"]="C";
	comp["N"]="N";

	if( !base ){
		print "Requires gawk and "
		print "please call with '-v base=YOUR_BASE'"
		print "samtools view FLAGS SAM_FILE | gawk -v base=YOUR_BASE -f "
		exit
	}
	#	buffered name, flags, sequence and quality
	b1=b2=b10=b11=""
}
{
	if( toupper($10) !~ /^[ATCGN]+$/ ){
		lane=(and($2,64))?"1":"2";
		print $1"/"lane >> base".unknown_bases.txt"
		print $10 >> base".unknown_bases.txt"
	}

	#	ONLY PRINT PAIRED READS WITH SEQUENTIAL READ NAMES
	if ( $1 == b1 ){
		if ( length(b10) != length($10) ){
			print $1 " " length(b10) " " length($10) >> base".diff_length_reads"
		}
		if ( length(b11) != length($11) ){
			print $1 " " length(b11) " " length($11) >> base".diff_length_quality"
		}
		if ( length($10) != length($11) ){
			print $1 " " length($10) " " length($11) >> base".diff_length_read_and_quality"
		}
		print_to_fastq(b1,b2,toupper(b10),b11)
		print_to_fastq($1,$2,toupper($10),$11)
		b1=b2=b10=b11=""
	} else {

		#	Doesn't match buffered read?
		if( b1 != "" )
			print b1 > base".missing_mates.txt"

		#	buffer this one
		b1=$1
		b2=$2
		b10=$10
		b11=$11
	}
}
