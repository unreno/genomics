#!/usr/bin/env ruby

require 'roo'

basename = 'pnas.1602336113.sd02.xlsx'
spreadsheet = Roo::Spreadsheet.open(basename)

all_column_names=[]
positions={}

spreadsheet.sheets.each do |sheet_name|
	next if sheet_name == 'HGDP'

	sheet = spreadsheet.sheet(sheet_name)

	these_column_names = sheet.row(11)

	all_column_names += these_column_names
	all_column_names.uniq!

#puts all_column_names.inspect

#	["#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", "NA18486", "NA18488", "NA18489", "NA18499", "NA18501", "NA18502", "NA18505", "NA18507", "NA18508", "NA18510", "NA18511", "NA18516", "NA18517", "NA18519", "NA18520", "NA18522", "NA18523", "NA18856", "NA18858", "NA18861", "NA18864", "NA18865", "NA18868", "NA18871", "NA18873", "NA18874", "NA18876", "NA18877", "NA18878", "NA18879", "NA18881", "NA18907", "NA18908", "NA18909", "NA18910", "NA18915", "NA18916", "NA18917", "NA18923", "NA18924", "NA18933", "NA18934", "NA19092", "NA19093", "NA19095", "NA19096", "NA19098", "NA19099", "NA19102", "NA19107", "NA19108", "NA19113", "NA19114", "NA19117", "NA19118", "NA19119", "NA19121", "NA19129", "NA19130", "NA19131", "NA19137", "NA19138", "NA19141", "NA19143", "NA19144", "NA19146", "NA19147", "NA19149", "NA19152", "NA19153", "NA19159", "NA19160", "NA19171", "NA19172", "NA19175", "NA19184", "NA19185", "NA19190", "NA19197", "NA19198", "NA19200", "NA19201", "NA19204", "NA19206", "NA19207", "NA19209", "NA19210", "NA19214", "NA19222", "NA19223", "NA19225", "NA19235", "NA19238", "NA19239", "NA19240", "NA19256", "NA19257"]


	((sheet.first_row+11)..sheet.last_row).each do |row_number|
		
		sheet.row(row_number).each_with_index do |column,index|

#			puts index		#	column number
#			puts these_column_names[index]	#	subject id
#			puts row_number
#			puts column		#	value
#			puts "-----"

			#	create a hash for each row or "position" (if first file)
			positions[row_number] ||= {}
			#	set the values for these subjects
			positions[row_number][these_column_names[index]] = column

		end

	end

end



#	Output will be quoted if contains the default quote character (")
#	To avoid this, set the quote_char to something else. \0 is the NULL character.
tsv = CSV.open("#{basename}.merged.tsv",'w', { col_sep: "\t", quote_char: "\0" })

sheet = spreadsheet.sheet('1KGP_YRI')

#	print out the header from one of the input vcf files
(1..10).each {|i| tsv.puts [ sheet.row(i)[0] ] }

tsv.puts all_column_names

#	loop over every position
positions.each_pair do |row_number,value|
	#	print the position values for all of the subjects
	tsv.puts all_column_names.collect{|c|value[c]}
end

tsv.close

