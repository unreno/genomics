#!/usr/bin/env Rscript

require(deconstructSigs)
require(ggplot2)
require(reshape)
require(stringr)
require(plyr)
require(gridExtra)
require(pryr)  # for object_size, mem_used
require(gdata) # for humanReadable


require(BSgenome.Hsapiens.UCSC.hg38)
hg38 <- BSgenome.Hsapiens.UCSC.hg38

pdf("mutations.pdf")

#	cosmic_mut isn't used anywhere other than here?
#	cosmic_mut = read.table("cosmic/cosmic_mut.txt",header = F, sep="\t",col.names = c("chr","pos","ref","alt","sample"))
#	head(cosmic_mut)

#	cosmic_mut_sort is never actually used anywhere but here?
#	cosmic_mut_sort <- with(cosmic_mut, cosmic_mut[order(cosmic_mut[,"sample"]),])
#	head(cosmic_mut_sort)
#	rownames(cosmic_mut_sort) <- NULL
#	head(cosmic_mut_sort)
#	cosmic_mut_sort$sample <- as.factor(cosmic_mut_sort$sample)
#	head(cosmic_mut_sort)

Sys.time()
message("Reading mut_all_sort.txt. This will take about 10 minutes")

#	the count muts script puts a # in front of the columns line
#	and R skips all comment lines.
mut_all_sort <- read.table(file = "mut_all_sort.txt",
		header = F, sep = "\t", stringsAsFactors = T)
head(mut_all_sort)
Sys.time()
print(humanReadable(mem_used()))
print("object_size(mut_all_sort)")
print(object_size(mut_all_sort))
message("ls()")
ls()


# take a random sample of size 50 from a dataset mydata 
# sample without replacement
#mysample <- mydata[sample(1:nrow(mydata), 50, replace=FALSE),]
#mut_all_sort <- mut_all_sort[sample(1:nrow(mut_all_sort),10000000),]




colnames(mut_all_sort) <- c("chr", "pos", "5_tetnuc", "3_tetnuc", "trinuc", "mut", "trinuc_mut",
		"strand", "context", "C_count", "TC_count", "TCA_count", "TCT_count",
		"YTCA_count", "RTCA_count", "sample")
head(mut_all_sort)

#deconstructSigs_input <- mut_all_sort[,c(1:2,6,16)]
#deconstructSigs_input <- mut_all_sort[,match(c("chr","pos","mut","sample"),colnames(mut_all_sort))]
#deconstructSigs_input <- mut_all_sort[,match(c("chr","pos","mut","sample"),colnames(mut_all_sort))]
#deconstructSigs_input <- mut_all_sort[,match(c("chr","pos","mut","sample"),colnames(mut_all_sort))]
deconstructSigs_input <- subset(mut_all_sort, select = c("chr", "pos", "mut", "sample"))
head(deconstructSigs_input)

deconstructSigs_input$ref <- substr(deconstructSigs_input$mut, 1, 1)
head(deconstructSigs_input)

deconstructSigs_input$alt <- substr(deconstructSigs_input$mut, 3, 3)
head(deconstructSigs_input)

deconstructSigs_input <- subset(deconstructSigs_input, select = c("chr", "pos", "ref", "alt", "sample"))
head(deconstructSigs_input)





deconstructSigs_input$sample <- as.character(deconstructSigs_input$sample)
head(deconstructSigs_input)

#	sample needs to be text when passed to mut.to.sigs.input or ...
#
#	Error in `[<-`(`*tmp*`, i, trimer, value = beep[trimer]) : 
#	  subscript out of bounds
#	Calls: mut.to.sigs.input
#	Execution halted
#	




Sys.time()
message("Running mut.to.sigs.input. Takes about 25 minutes.")
message("Memory usage up to 50GB")
mut.counts <- mut.to.sigs.input(mut.ref = deconstructSigs_input, sample.id = "sample", chr = "chr", pos = "pos",
		ref = "ref", alt = "alt", bsg = hg38)
Sys.time()
rm(deconstructSigs_input)

head(mut.counts)
print(humanReadable(mem_used()))
print("object_size(mut.counts)")
print(object_size(mut.counts))
message("ls()")
ls()



# This is never explicitly used?
# However, the code references signatures.cosmic which is never set?
# Yet everything seems to work?



#signatures.nature2013 <- load("cosmic/signatures.nature2013.rda")
#signatures.cosmic <- load("cosmic/signatures.nature2013.rda")
#signatures.cosmic <- load("cosmic/signatures.cosmic.rda")





Sys.time()
message("getTriContextFraction")
context <- getTriContextFraction(mut.counts.ref = mut.counts, trimer.counts.method = "default")
head(context)
Sys.time()

context$tca_tct <- context[,"T[C>T]A"] + context[,"T[C>T]T"] + context[,"T[C>G]A"] + context[,"T[C>G]T"]
head(context$tca_tct)

context$sample <- rownames(context)
head(context$sample)

tca_tct <- subset(context, select = c("sample", "tca_tct"))
head(tca_tct)

rownames(tca_tct) <- NULL
head(tca_tct)

# cleanup
context$sample <- NULL
context$tca_tct <- NULL

message("ls()")
ls()

#output.sigs.final <- as.data.frame(whichSignatures(context,
#		sample.id = "ZR-75-30",
#		signatures.cosmic,
#		contexts.needed = F))
#head(output.sigs.final)

if( exists("output.sigs.final") ){
	rm(output.sigs.final)
}
Sys.time()
message("looping whichSignatures")
nrow(context)

# signatures.cosmic is part of the deconstructSigs package so guessing that is why it works without me loading it.
# Wonder what happens if I use signatures.nature2013
for(i in (1:nrow(context))) {
	#message(i," - ",nrow(context))
	output.sigs <- as.data.frame(whichSignatures(context,
			sample.id = rownames(context[i,]),
			signatures.cosmic,
			contexts.needed = F))
	if( exists("output.sigs.final")){
		output.sigs.final <- rbind(output.sigs.final, output.sigs)
	} else {
		output.sigs.final <- output.sigs
	}
}
Sys.time()

message("head(output.sigs.final)")
head(output.sigs.final)

#message("length(output.sigs.final)")
#length(output.sigs.final)

#	tail(output.sigs.final)

#	Don't need to trim this anymore as only load ZR-75-30 once. Should still be 1020
#output.sigs.final <- head(output.sigs.final,-1)

message("nrow(output.sigs.final)")
nrow(output.sigs.final)

print(humanReadable(mem_used()))
print("object_size(output.sigs.final)")
print(object_size(output.sigs.final))
message("ls()")
ls()

#	length(output.sigs.final)

#	tail(output.sigs.final)

#	combine to separate signatures. Not sure exactly what 2 and 13 are just yet
message("output.sigs.final$zAPOBEC.Sig")
output.sigs.final$zAPOBEC.Sig <- output.sigs.final$weights.Signature.2 + output.sigs.final$weights.Signature.13

message("head(output.sigs.final[,c(1:30,319,320)])")
head(output.sigs.final[,c(1:30,319,320)])

message("colnames(output.sigs.final)[c(1:30,319,320)]")
colnames(output.sigs.final)[c(1:30,319,320)]

# Only want 32 of these columns?
output.sigs.final <- output.sigs.final[,c(1:30,319,320)]
head(output.sigs.final)

output.sigs.final$sample <- rownames(output.sigs.final)
head(output.sigs.final$sample)

rownames(output.sigs.final) <- NULL
head(output.sigs.final)

message("sample_types")
sample_types <- read.table(file = "sample_types.csv",
		header = F, stringsAsFactors = F, fill = T, sep="\t")
colnames(sample_types) <- c("sample", "type")
head(sample_types)
nrow(sample_types)



#	cosmic_tissue_type <- read.table(file = "cosmic/cosmic_tissue_type.txt", header = F, stringsAsFactors = F,
#			fill = T, sep="\t")
#	head(cosmic_tissue_type)
#
#	colnames(cosmic_tissue_type) <- c("sample", "tissue")
#	head(cosmic_tissue_type)
#
#	length(cosmic_tissue_type)
#
#	# Unnecessary
#	cosmic_tissue_type <- unique(cosmic_tissue_type)
#	length(cosmic_tissue_type)
#
#	nrow(cosmic_tissue_type)
#
#	tissues <- cosmic_tissue_type[order(cosmic_tissue_type$tissue),]
#	tissues <- unique(as.vector(tissues[,"tissue"]))
#	head(tissues)


message("Types:")
types <- sample_types[order(sample_types$type),]
types <- unique(as.vector(types[,"type"]))
head(types)
length(types)


#	length(tissues)
#
#	cosmic_mut_tissue <- merge(mut_all_sort, cosmic_tissue_type, by = "sample", all.x = T)
#	head(cosmic_mut_tissue)

message("merge(mut_all_sort, sample_types,")
Sys.time()
mut_type <- merge(mut_all_sort, sample_types, by = "sample", all.x = T)
head(mut_type)
Sys.time()

print(humanReadable(mem_used()))
print("object_size(mut_type)")
print(object_size(mut_type))
message("ls()")
ls()

#	table uses the cross-classifying factors to build a contingency table of the counts at each combination of factor levels.
#	cell_line_mutload <- as.data.frame(table(cosmic_mut_tissue$sample))
#	head(cell_line_mutload)

cell_line_mutload <- as.data.frame(table(mut_type$sample))
head(cell_line_mutload)

colnames(cell_line_mutload) <- c("sample", "mut_tot")
head(cell_line_mutload)

#	cell_line_mutload <- merge(cell_line_mutload, cosmic_tissue_type, by = "sample", all.x = T)
#	head(cell_line_mutload)

print("merge(cell_line_mutload, sample_types")
cell_line_mutload <- merge(cell_line_mutload, sample_types, by = "sample", all.x = T)
message("head(cell_line_mutload)")
head(cell_line_mutload)

print(humanReadable(mem_used()))
print("object_size(cell_line_mutload)")
print(object_size(cell_line_mutload))
message("ls()")
ls()

#	sigs_tissues <- merge(output.sigs.final, cell_line_mutload, by = "sample")
#	head(sigs_tissues)

print("merge(output.sigs.final, cell_line_mutload")
sigs_types <- merge(output.sigs.final, cell_line_mutload, by = "sample")
message("head(sigs_types)")
head(sigs_types)

print(humanReadable(mem_used()))
print("object_size(sigs_types)")
print(object_size(sigs_types))
message("ls()")
ls()

#	#> x=c(5,6,7,8,9)
#	#> x
#	#[1] 5 6 7 8 9
#	#> x  %in% c(3,4,5,6)
#	#[1]  TRUE  TRUE FALSE FALSE FALSE
#	#> x[x  %in% c(3,4,5,6)]
#	#[1] 5 6
#
#	colnames(sigs_tissues)[c(3,14,34)]
#	colnames(sigs_tissues)
#	colnames(sigs_tissues)[!colnames(sigs_tissues) %in% c('weights.Signature.2','weights.Signature.13','mut_tot')]
#	head(sigs_tissues)

colnames(sigs_types)[c(3,14,34)]
colnames(sigs_types)
colnames(sigs_types)[!colnames(sigs_types) %in% c('weights.Signature.2','weights.Signature.13','mut_tot')]
head(sigs_types)

#	#sigs_tissues <- sigs_tissues[,-c(3,14,34)]
#	#remove signature2, signature13, mut_tot?
#	#
#	#sigs_tissues <- sigs_tissues[,!colnames(sigs_tissues) %in% c('weights.Signature.2','weights.Signature.13','mut_tot')]
#
#	sigs_tissues <- sigs_tissues[,!colnames(sigs_tissues) %in% c('weights.Signature.2','weights.Signature.13')]
#	head(sigs_tissues)

sigs_types <- sigs_types[,!colnames(sigs_types) %in% c('weights.Signature.2','weights.Signature.13')]
head(sigs_types)

#	#gonna need mut_tot later so can't do this here
#
#	sigs_individual <- subset(sigs_tissues, tissue == "L. Intestine")
#	head(sigs_individual)
#
#	sigs_individual <- sigs_individual[,!colnames(sigs_individual) %in% c('tissue','mut_tot')]
#	head(sigs_individual)
#
#	colnames(sigs_individual)
#
#	#colnames(sigs_individual)[32]
#
#	## remove column 32??  tissue
#	#sigs_individual <- sigs_individual[,!colnames(sigs_individual) %in% c('tissue')]
#	##sigs_individual <- sigs_individual[,-c(32)]
#	#head(sigs_individual)
#
#	sigs_melt <- melt(sigs_individual, id = "sample")
#	head(sigs_melt)
#
#	colnames(sigs_melt) <- c("sample", "sig", "value")
#	head(sigs_melt)
#
#	nrow(sigs_melt)
#
#	sigs_melt[,"sig"] <- gsub("weights.", "", sigs_melt[,"sig"])
#
#	nrow(sigs_melt)
#
#	head(sigs_melt)
#
#	tail(sigs_melt)
#
#	sigs_melt[,"sig"] <- gsub("Signature.10", "I", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.11", "J", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.12", "K", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.14", "L", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.15", "M", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.16", "N", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.17", "O", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.18", "P", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.19", "Q", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.20", "R", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.21", "S", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.22", "T", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.23", "U", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.24", "V", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.25", "W", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.26", "X", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.27", "Y", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.28", "Z", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.29", "ZZ", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.30", "ZZZ", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("unknown", "ZZZZ", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("zAPOBEC.Sig", "ZZZZZ", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.1", "A", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.3", "B", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.4", "C", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.5", "D", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.6", "E", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.7", "F", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.8", "G", sigs_melt[,"sig"])
#	sigs_melt[,"sig"] <- gsub("Signature.9", "H", sigs_melt[,"sig"])
#
#	nrow(sigs_melt)
#
#	list <- sigs_individual[order(sigs_individual$zAPOBEC.Sig),]
#	head(list)
#
#	list1 <- as.vector(list[,"sample"])
#	head(list1)
#
#	length(list1)
#
#	# Adjust plot size
#	options(repr.plot.width=16, repr.plot.height=6)
#
#	ggplot(sigs_melt, aes(sample, value, fill = sig)) +
#		geom_col() +
#		ggtitle( paste0("Large Intestine (n=", length(list1), ")")) +
#		#scale_fill_brewer() +
#		theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
#		xlab("Cancer Cell Line") +
#		ylab("Mutational Signature Proportion") +
#		scale_x_discrete(limits = list1) +
#		theme_bw() +
#		theme(axis.text.x=element_text(angle = 45, hjust = 1),
#			panel.border = element_blank(),
#			panel.grid.major = element_blank(),
#			panel.grid.minor = element_blank(),
#			axis.line = element_line(colour = "black"))
#
#	tissues
#
#	#tissues = c("Adrenal Gland","Autonomic Ganglia","Biliary Tract","Bladder","Bone","Breast",
#	#		"Cervix","CNS","Endometrium","Kidney","L. Intestine","Liver","Lung","NS",
#	#		"Oesophagus","Ovary","Pancreas","Placenta","Pleura","Prostate","Salivary Gland",
#	#		"S. Intestine","Skin","Soft Tissue","Stomach","Testis","Thyroid",
#	#		"Upper Aerodigestive Tract","Vulva","WBC")
#
#	options(repr.plot.width=16, repr.plot.height=6)
#
#	for( this_tissue in tissues ){
#		sigs_individual <- subset(sigs_tissues, tissue == this_tissue)
#		sigs_individual <- sigs_individual[,!colnames(sigs_individual) %in% c('tissue','mut_tot')]
#		sigs_melt <- melt(sigs_individual, id = "sample")
#		colnames(sigs_melt) <- c("sample", "sig", "value")
#		sigs_melt[,"sig"] <- gsub("weights.", "", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.10", "I", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.11", "J", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.12", "K", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.14", "L", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.15", "M", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.16", "N", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.17", "O", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.18", "P", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.19", "Q", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.20", "R", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.21", "S", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.22", "T", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.23", "U", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.24", "V", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.25", "W", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.26", "X", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.27", "Y", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.28", "Z", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.29", "ZZ", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.30", "ZZZ", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("unknown", "ZZZZ", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("zAPOBEC.Sig", "ZZZZZ", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.1", "A", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.3", "B", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.4", "C", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.5", "D", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.6", "E", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.7", "F", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.8", "G", sigs_melt[,"sig"])
#		sigs_melt[,"sig"] <- gsub("Signature.9", "H", sigs_melt[,"sig"])
#		list <- sigs_individual[order(sigs_individual$zAPOBEC.Sig),]
#		list1 <- as.vector(list[,"sample"])
#		print(ggplot(sigs_melt, aes(sample, value, fill = sig)) +
#			geom_col() +
#			ggtitle( paste0(this_tissue," (n=", length(list1), ")")) +
#			#scale_fill_brewer() +
#			theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
#			xlab("Cancer Cell Line") +
#			ylab("Mutational Signature Proportion") +
#			scale_x_discrete(limits = list1) +
#			theme_bw() +
#			theme(axis.text.x=element_text(angle = 45, hjust = 1),
#				panel.border = element_blank(),
#				panel.grid.major = element_blank(),
#				panel.grid.minor = element_blank(),
#				axis.line = element_line(colour = "black")))
#
#			sigs_individual <- subset(sigs_individual, zAPOBEC.Sig > 0)
#			if( nrow(sigs_individual) > 0){
#				sigs_melt <- melt(sigs_individual, id = "sample")
#				colnames(sigs_melt) <- c("sample", "sig", "value")
#				sigs_melt <- subset(sigs_melt, sig == "zAPOBEC.Sig")
#				list <- sigs_individual[order(sigs_individual$zAPOBEC.Sig),]
#				list1 <- as.vector(list[,"sample"])
#				print(ggplot(sigs_melt, aes(sample, value, fill = sig)) +
#					geom_col() +
#					ggtitle( paste0(this_tissue," (n=", length(list1), ")")) +
#					#scale_fill_brewer() +
#					theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
#					xlab("Cancer Cell Line") +
#					ylab("Mutational Signature Proportion") +
#					scale_x_discrete(limits = list1) +
#					theme_bw() +
#					theme(axis.text.x=element_text(angle = 45, hjust = 1),
#						panel.border = element_blank(),
#						panel.grid.major = element_blank(),
#						panel.grid.minor = element_blank(),
#						axis.line = element_line(colour = "black")))
#			}
#	}






message("About to melt stuff")
print(types)

#	About to melt stuff
#	[1] "normal" "tumor" 
#	Error in data.frame(ids, x, data[, x]) : 
#		arguments imply differing number of rows: 0, 1
#	Calls: melt ... melt.data.frame -> do.call -> lapply -> FUN -> data.frame
#	Execution halted

#	Only tumor data. Matter?

#	types includes 'normal' but no data here so the melt command fails

#for( this_type in types ){
for( this_type in c('tumor') ){
	sigs_individual <- subset(sigs_types, type == this_type)
	head(sigs_individual)
	sigs_individual <- sigs_individual[,!colnames(sigs_individual) %in% c('type','mut_tot')]
	head(sigs_individual)
	sigs_melt <- melt(sigs_individual, id = "sample")
	colnames(sigs_melt) <- c("sample", "sig", "value")
	sigs_melt[,"sig"] <- gsub("weights.", "", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.10", "I", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.11", "J", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.12", "K", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.14", "L", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.15", "M", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.16", "N", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.17", "O", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.18", "P", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.19", "Q", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.20", "R", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.21", "S", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.22", "T", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.23", "U", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.24", "V", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.25", "W", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.26", "X", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.27", "Y", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.28", "Z", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.29", "ZZ", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.30", "ZZZ", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("unknown", "ZZZZ", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("zAPOBEC.Sig", "ZZZZZ", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.1", "A", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.3", "B", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.4", "C", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.5", "D", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.6", "E", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.7", "F", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.8", "G", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("Signature.9", "H", sigs_melt[,"sig"])
	list <- sigs_individual[order(sigs_individual$zAPOBEC.Sig),]
	list1 <- as.vector(list[,"sample"])
	print(ggplot(sigs_melt, aes(sample, value, fill = sig)) +
		geom_col() +
		ggtitle( paste0(this_type," (n=", length(list1), ")")) +
		#scale_fill_brewer() +
		theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
		xlab("Sample") +
		ylab("Mutational Signature Proportion") +
		scale_x_discrete(limits = list1) +
		theme_bw() +
		theme(axis.text.x=element_text(angle = 45, hjust = 1),
			panel.border = element_blank(),
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			axis.line = element_line(colour = "black")))

	sigs_individual <- subset(sigs_individual, zAPOBEC.Sig > 0)
	if( nrow(sigs_individual) > 0){
		sigs_melt <- melt(sigs_individual, id = "sample")
		colnames(sigs_melt) <- c("sample", "sig", "value")
		sigs_melt <- subset(sigs_melt, sig == "zAPOBEC.Sig")
		list <- sigs_individual[order(sigs_individual$zAPOBEC.Sig),]
		list1 <- as.vector(list[,"sample"])
		print(ggplot(sigs_melt, aes(sample, value, fill = sig)) +
			geom_col() +
			ggtitle( paste0(this_type," (n=", length(list1), ")")) +
			#scale_fill_brewer() +
			theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
			xlab("Sample") +
			ylab("Mutational Signature Proportion") +
			scale_x_discrete(limits = list1) +
			theme_bw() +
			theme(axis.text.x=element_text(angle = 45, hjust = 1),
				panel.border = element_blank(),
				panel.grid.major = element_blank(),
				panel.grid.minor = element_blank(),
				axis.line = element_line(colour = "black")))
	}
}

message("nrow(mut_all_sort)")		#	90475122
nrow(mut_all_sort)

Sys.time()
#message("unique(mut_all_sort).  Takes quite a while.")
#	Why? Does it do anything? Takes quite a while. Currently using 133GB memory (into swap so slow)
#	So far about 20 hours. Considering killing it.
#enrich_tot <- unique(mut_all_sort)
#Sys.time()

#message("nrow(enrich_tot)")
#nrow(enrich_tot)

#	enrich_tot$Mut_TCW <- "0"
#	enrich_tot$Mut_C <- "0"
#	enrich_tot$Con_TCW <- "0"
#	enrich_tot$Con_C <- "0"
#	mut <- data.frame(do.call('rbind', strsplit(as.character(enrich_tot$mut),'>',fixed=T)))
#	enrich_tot$mut_ref <- mut[,1]
#	enrich_C <- subset(enrich_tot, mut_ref == "C")

mut_all_sort$Mut_TCW <- "0"
mut_all_sort$Mut_C <- "0"
mut_all_sort$Con_TCW <- "0"
mut_all_sort$Con_C <- "0"
mut <- data.frame(do.call('rbind', strsplit(as.character(mut_all_sort$mut),'>',fixed=T)))
mut_all_sort$mut_ref <- mut[,1]
enrich_C <- subset(mut_all_sort, mut_ref == "C")

message("enrich_CtoK <- subset(enrich_C")
Sys.time()
enrich_CtoK <- subset(enrich_C, mut != "C>A") # Remove C>A mutations!
Sys.time()

enrich_CtoK[which(enrich_CtoK$mut_ref == "C"),"Mut_C"] <- "1"
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>G]A"),"Mut_TCW"] <- "1"
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>G]T"),"Mut_TCW"] <- "1"
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>T]A"),"Mut_TCW"] <- "1"
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>T]T"),"Mut_TCW"] <- "1"

enrich_CtoK$Con_C <- str_count(enrich_CtoK$context, "C") + str_count(enrich_CtoK$context, "G")

enrich_CtoK$Con_TCW <- str_count(enrich_CtoK$context, "TCA") +
		str_count(enrich_CtoK$context, "TCT") +
		str_count(enrich_CtoK$context, "TGA") +
		str_count(enrich_CtoK$context, "TGT")

enrich_final <- enrich_CtoK[,16:20]
enrich_final$Mut_TCW <- as.integer(enrich_final$Mut_TCW)
enrich_final$Mut_C <- as.integer(enrich_final$Mut_C)

message("ddply(enrich_final")
Sys.time()
enrich_final <- ddply(enrich_final, "sample", numcolwise(sum))
Sys.time()

rownames(enrich_final) <- enrich_final$sample
enrich_final$sample <- NULL
enrich_final$enrich_score <- (enrich_final$Mut_TCW / enrich_final$Con_TCW) / (enrich_final$Mut_C / enrich_final$Con_C)

enrich_matrix <- as.data.frame(enrich_final$Mut_TCW)
enrich_matrix$Mut_Denom <- enrich_final$Mut_C - enrich_final$Mut_TCW
enrich_matrix$Con_TCW <- enrich_final$Con_TCW
enrich_matrix$Con_Denom <- enrich_final$Con_C - enrich_final$Con_TCW
rownames(enrich_matrix) <- rownames(enrich_final)
colnames(enrich_matrix) <- c("Mut_TCW", "Mut_Denom", "Con_TCW", "Con_Denom")

message("as.matrix(enrich_matrix)")
Sys.time()
enrich_matrix <- as.matrix(enrich_matrix)
Sys.time()


exe_fisher <- function(x) {
	m <- matrix(unlist(x), ncol = 2, nrow = 2, byrow = T)
	f <- fisher.test(m)
	return(as.data.frame(f$p.value))
}

message("t(as.data.frame(apply(enrich_matrix, 1, exe_fisher)))")
Sys.time()
fishers <- t(as.data.frame(apply(enrich_matrix, 1, exe_fisher)))
Sys.time()
fishers <- as.data.frame(fishers)

enrich_final$fisher_pval <- fishers$V1
enrich_final$bh_adj_qval <- p.adjust(enrich_final$fisher_pval, method = "BH")

enrich_final$Mut_Ratio <- enrich_final$Mut_TCW/(enrich_final$Mut_C - enrich_final$Mut_TCW)
enrich_final$Con_Ratio <- enrich_final$Con_TCW/(enrich_final$Con_C - enrich_final$Con_TCW)
enrich_final[which(enrich_final$Mut_Ratio < enrich_final$Con_Ratio), "bh_adj_qval"] <- 1
enrich_final$Mut_Ratio <- NULL
enrich_final$Con_Ratio <- NULL
enrich_final$sample <- rownames(enrich_final)
rownames(enrich_final) <- NULL

Sys.time()

#	message("head(cell_line_mutload)")
#	head(cell_line_mutload)
#	head(subset(cell_line_mutload,tissue=="Lung"))
#	print(class("Lung"))

if( exists("mut_med_quantiles") ){
	rm(mut_med_quantiles)
}

message("med quantiles loop")
Sys.time()
#	for( this_tissue in tissues ) {
for( this_type in types ) {
	#mut_sub <- subset(cell_line_mutload, tissue == this_tissue)
	mut_sub <- subset(cell_line_mutload, type == this_type)
	if( exists("mut_med_quantiles") ){
		x <- as.data.frame(t(quantile(mut_sub$mut_tot)))
		mut_med_quantiles <- rbind(mut_med_quantiles, x)
	} else {
		mut_med_quantiles <- as.data.frame(t(quantile(mut_sub$mut_tot)))
	}
}
Sys.time()

#	rownames(mut_med_quantiles) = tissues
rownames(mut_med_quantiles) = types
#	mut_med_quantiles$tissue <- rownames(mut_med_quantiles)
mut_med_quantiles$type <- rownames(mut_med_quantiles)
#colnames(mut_med_quantiles) <- c("low", "first", "med", "third", "high", "tissue")
colnames(mut_med_quantiles) <- c("low", "first", "med", "third", "high", "type")

mut_med_quantiles

mut_med_quantiles <- mut_med_quantiles[order(mut_med_quantiles$med),]
head(mut_med_quantiles)

#	plot_order <- as.vector(mut_med_quantiles[,"tissue"])
plot_order <- as.vector(mut_med_quantiles[,"type"])
head(plot_order)

# Adjust plot size
options(repr.plot.width=16, repr.plot.height=6)

#ggplot(mut_med_quantiles, aes(tissue, med)) +
ggplot(mut_med_quantiles, aes(type, med)) +
	geom_col() +
	theme(axis.text.x=element_text(angle = 45, hjust = 1), legend.position = "none") +
	geom_errorbar(aes(ymin=first, ymax=third), width=.3) +
	scale_y_continuous(limits = c(0,3501),
		breaks = c(0,1200,2400,3600)) +
	#xlab("Tissue Type") +
	xlab("Type") +
	ylab("Median Number of Mutations") +
	#geom_text(aes(label = freq), vjust = -0.2) +
	theme_bw() +
	theme(axis.text.x=element_text(angle = 45, hjust = 1),
		panel.border = element_blank(),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		axis.line = element_line(colour = "black")) +
	scale_fill_gradient(low = "blue", high = "red") +
	scale_x_discrete(limits = plot_order ) +
	ggtitle("Median Mutations by Type")
	#ggtitle("Median Mutations by Tissue Type")

#	number <- as.data.frame(table(cosmic_tissue_type$tissue))
number <- as.data.frame(table(sample_types$type))
#	colnames(number) <- c("tissue", "freq")
colnames(number) <- c("type", "freq")
#	ggplot(number, aes(tissue, freq)) +
ggplot(number, aes(type, freq)) +
	geom_point(size = 4) +
	#ylim(0,200) +
	theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
	scale_x_discrete(limits = types )
#	  scale_x_discrete(limits = tissues )

print("f")

# use same sort as median number of mutations plot
#	number <- as.data.frame(table(cosmic_tissue_type$tissue))
number <- as.data.frame(table(sample_types$type))

print("g")

#	colnames(number) <- c("tissue", "freq")
colnames(number) <- c("type", "freq")

print("h")

#	ggplot(number, aes(tissue, freq)) +
ggplot(number, aes(type, freq)) +
	geom_point(size = 4) +
	#ylim(0,200) +
	theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
	scale_x_discrete(limits = plot_order)

print("i")

#	sigs_tissues_individual <- subset(sigs_tissues, tissue == "L. Intestine")
#	head(sigs_tissues_individual)
#
#	length(sigs_tissues_individual)
#
#	sigs_tissues_individual_1 <- sigs_tissues_individual[order(sigs_tissues_individual$zAPOBEC.Sig),]
#	rownames(sigs_tissues_individual_1) <- c(1:nrow(sigs_tissues_individual_1))
#	sigs_tissues_individual_1[,"order"] <- rownames(sigs_tissues_individual_1)
#	head(sigs_tissues_individual_1)
#
#	length(sigs_tissues_individual_1)
#
#	#sigs_tissues_individual_1 <- sigs_tissues_individual_1[
#	#    ,!colnames(sigs_tissues_individual_1) %in% c('weights.Signature.2','weights.Signature.13','tissue')]
#	#head(sigs_individual_1)
#
#	ggplot(sigs_tissues_individual_1, aes(as.numeric(order), mut_tot)) +
#		geom_point(shape = 18, size = 4) +
#		geom_smooth(span = 0.75) +
#		theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
#		xlab("Cancer Cell Line") +
#		ylab("Mut Burden") +
#		ylim(0,1600) +
#		theme_bw() +
#		theme(axis.text.x=element_text(angle = 45, hjust = 1),
#			panel.border = element_blank(),
#			panel.grid.major = element_blank(),
#			panel.grid.minor = element_blank(),
#			axis.line = element_line(colour = "black"))


print("Another types loop")

#	Error in `.rowNamesDF<-`(x, value = value) : invalid 'row.names' length
#	Calls: rownames<- ... row.names<- -> row.names<-.data.frame -> .rowNamesDF<-
#	Execution halted

#for( this_tissue in tissues ){
#for( this_type in types ){
for( this_type in c('tumor') ){
	#sigs_tissues_individual <- subset(sigs_tissues, tissue == this_tissue)
	sigs_types_individual <- subset(sigs_types, type == this_type)
	#sigs_tissues_individual_1 <- sigs_tissues_individual[order(sigs_tissues_individual$zAPOBEC.Sig),]
	sigs_types_individual_1 <- sigs_types_individual[order(sigs_types_individual$zAPOBEC.Sig),]
	#rownames(sigs_tissues_individual_1) <- c(1:nrow(sigs_tissues_individual_1))
	rownames(sigs_types_individual_1) <- c(1:nrow(sigs_types_individual_1))
	#sigs_tissues_individual_1[,"order"] <- rownames(sigs_tissues_individual_1)
	sigs_types_individual_1[,"order"] <- rownames(sigs_types_individual_1)
	#print(ggplot(sigs_tissues_individual_1, aes(as.numeric(order), mut_tot)) +
	print(ggplot(sigs_types_individual_1, aes(as.numeric(order), mut_tot)) +
		geom_point(shape = 18, size = 4) +
		geom_smooth(span = 0.75) +
		theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
		#ggtitle(this_tissue) +
		ggtitle(this_type) +
		xlab("Sample") +
		ylab("Mut Burden") +
		#ylim(0,1600) +
		theme_bw() +
		theme(axis.text.x=element_text(angle = 45, hjust = 1),
			panel.border = element_blank(),
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			axis.line = element_line(colour = "black")))
}


print("j")

#sigs_enrich <- merge(sigs_tissues, enrich_final, by = "sample")
sigs_enrich <- merge(sigs_types, enrich_final, by = "sample")
head(sigs_enrich)

message("Merging sigs_enrich and tca_tct")
Sys.time()
sigs_enrich_tcw <- merge(sigs_enrich, tca_tct, by = "sample")
head(sigs_enrich_tcw)
Sys.time()

print("k")

# Adjust plot size
options(repr.plot.width=10, repr.plot.height=10)

print("l")

#ggplot(sigs_enrich_tcw, aes(enrich_score, tca_tct)) +
#	geom_point() +
#	xlim(0,5) +
#	ylim(0,0.5)

ggplot(sigs_enrich_tcw, aes(tca_tct,enrich_score)) +
	geom_point() #	+ ylim(0,5) + xlim(0,0.5)

print("m")

ggplot(sigs_enrich_tcw, aes(zAPOBEC.Sig, tca_tct)) +
	geom_point() #	+ xlim(0,0.8) + ylim(0,0.5)

print("n")

ggplot(sigs_enrich_tcw, aes(zAPOBEC.Sig, enrich_score)) +
	geom_point() #	+ xlim(0,0.8) + ylim(0,5)

print("o")

# Try to plot "Mutation Fraction"/"Trinucleotide Context" from "context"

head(context)

context$sample <- rownames(context)
head(context)

#	context <- merge(context, cosmic_tissue_type, by = "sample", all.x = T)
#	head(context)

print("p")

#context_melt <- melt(context,id=c("sample","tissue"))
context_melt <- melt(context,id="sample")
head(context_melt)

context_melt$alt <- substr(context_melt$variable, 5, 5)
head(context_melt)

print("q")

context_melt$trinuc <- paste0(substr(context_melt$variable, 1, 1),
		substr(context_melt$variable, 3, 3),
		substr(context_melt$variable, 7, 7))
head(context_melt)

print("r")

# Adjust plot size
options(repr.plot.width=16, repr.plot.height=6)

samples <- unique(as.vector(context_melt[,"sample"]))
head(samples)

print("s")

length(samples)

message("Plotting")

print("t")

#for( this_tissue in tissues ){
for( this_sample in samples ){
	cell_line = subset(context_melt, sample == this_sample ) #& tissue == this_tissue )
	if( nrow(cell_line) > 0 ){
		print(ggplot(cell_line, aes(trinuc, value, fill = alt)) +
			geom_col() +
			ylim(0,0.40) +  # fixed y limit for easier viewing and comparison
			ggtitle( this_sample ) +
			#ggtitle( paste0( this_sample, " - ", cell_line$tissue[1] ) ) +
			#ggtitle( paste0( this_tissue, " - ", this_sample ) ) +
			theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
			xlab("Trinucleotide Context") +
			ylab("Mutation Fraction") +
			#      scale_x_discrete(limits = list1) +
			theme_bw() +
			theme(axis.text.x=element_text(angle = 45, hjust = 1),
				panel.border = element_blank(),
				panel.grid.major = element_blank(),
				panel.grid.minor = element_blank(),
				axis.line = element_line(colour = "black")))
	}
} # }
