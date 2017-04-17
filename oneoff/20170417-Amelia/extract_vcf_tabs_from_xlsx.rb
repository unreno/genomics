#!/usr/bin/env ruby

require 'roo'

basename = 'pnas.1602336113.sd02.xlsx'
spreadsheet = Roo::Spreadsheet.open(basename)

spreadsheet.sheets.each do |sheet_name|

	sheet = spreadsheet.sheet(sheet_name)

	#	Output will be quoted if contains the default quote character (")
	#	To avoid this, set the quote_char to something else. \0 is the NULL character.
	tsv = CSV.open("#{basename}.#{sheet_name}.tsv",'w', { col_sep: "\t", quote_char: "\0" })

	(sheet.first_row..sheet.last_row).each do |r|
		
		tsv.puts sheet.row(r)

	end

	tsv.close

end
