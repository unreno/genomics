#!/usr/bin/env Rscript


#	20190528 - try to use bioconductor to install, update and manage these packages
#
#	update.packages(checkBuilt = TRUE, ask = FALSE) 
#	list.of.packages <- c("deconstructSigs","ggplot2","BSgenome.Hsapiens.UCSC.hg38","reshape","stringr","plyr","gridExtra")
#	new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
#
#	if (!requireNamespace("BiocManager", quietly = TRUE))
#		install.packages("BiocManager")
#	BiocManager::install()
#	if(length(new.packages))
#		BiocManager::install( new.packages )




#	Sys.setenv("DISPLAY"=":0")
#options(bitmapType='cairo')
#	Need to ssh -Y to server to save these png plots.

require(deconstructSigs)
require(ggplot2)
require(reshape)
require(stringr)
require(plyr)
require(gridExtra)
require(pryr)  # for object_size, mem_used
require(gdata) # for humanReadable
require(gtools)


require(BSgenome.Hsapiens.UCSC.hg38)
hg38 <- BSgenome.Hsapiens.UCSC.hg38

pdf("mutations.pdf", width=16, height=9)

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




colnames(mut_all_sort) <- c("chr", "pos", "5_tetnuc", "3_tetnuc", "trinuc", "mut", "trinuc_mut",
		"strand", "context", "C_count", "TC_count", "TCA_count", "TCT_count",
		"YTCA_count", "RTCA_count", "sample")
head(mut_all_sort)

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


message("nrow(output.sigs.final)")
nrow(output.sigs.final)

print(humanReadable(mem_used()))
print("object_size(output.sigs.final)")
print(object_size(output.sigs.final))
message("ls()")
ls()



#
#message("colnames(output.sigs.final)")
#colnames(output.sigs.final)
#
#quit()
#





#	combine to separate signatures. Not sure exactly what 2 and 13 are just yet
#	rename zAPOBEC.Sig zAPOBEC
message("output.sigs.final$zAPOBEC")
output.sigs.final$zAPOBEC <- output.sigs.final$weights.Signature.2 + output.sigs.final$weights.Signature.13

#	319 is "unknown"
#	320 is this newly created zAPOBED

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



message("Types:")
types <- sample_types[order(sample_types$type),]
types <- unique(as.vector(types[,"type"]))
head(types)
length(types)


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

cell_line_mutload <- as.data.frame(table(mut_type$sample))
head(cell_line_mutload)

colnames(cell_line_mutload) <- c("sample", "mut_tot")
head(cell_line_mutload)


print("merge(cell_line_mutload, sample_types")
cell_line_mutload <- merge(cell_line_mutload, sample_types, by = "sample", all.x = T)
message("head(cell_line_mutload)")
head(cell_line_mutload)

print(humanReadable(mem_used()))
print("object_size(cell_line_mutload)")
print(object_size(cell_line_mutload))
message("ls()")
ls()


print("merge(output.sigs.final, cell_line_mutload")
sigs_types <- merge(output.sigs.final, cell_line_mutload, by = "sample")
message("head(sigs_types)")
head(sigs_types)

print(humanReadable(mem_used()))
print("object_size(sigs_types)")
print(object_size(sigs_types))
message("ls()")
ls()


colnames(sigs_types)[c(3,14,34)]
colnames(sigs_types)
colnames(sigs_types)[!colnames(sigs_types) %in% c('weights.Signature.2','weights.Signature.13','mut_tot')]
head(sigs_types)

#	Drop 2 and 13 as they were merged into zAPOBEC?
#	if not removed, the stacked bar will add to over 100%.
sigs_types <- sigs_types[,!colnames(sigs_types) %in% c('weights.Signature.2','weights.Signature.13')]
head(sigs_types)



csv = sigs_types[mixedorder(sigs_types$sample),]
colnames(csv) = gsub("weights.Signature.", "", colnames(csv))
head(csv)
write.csv(csv, file = "mutations.csv", row.names=FALSE)
#quit()




message("About to melt stuff")
print(types)

#	About to melt stuff
#	[1] "normal" "tumor" 
#	Error in data.frame(ids, x, data[, x]) : 
#		arguments imply differing number of rows: 0, 1
#	Calls: melt ... melt.data.frame -> do.call -> lapply -> FUN -> data.frame
#	Execution halted



for( this_type in types ){
	sigs_individual <- subset(sigs_types, type == this_type)
	print( this_type )
	print( nrow(sigs_individual) )
	if( nrow(sigs_individual) == 0 ){
		print( paste0("No data with this type: ",this_type) )
		next
	}
	head(sigs_individual)
	sigs_individual <- sigs_individual[,!colnames(sigs_individual) %in% c('type','mut_tot')]
	head(sigs_individual)
	sigs_melt <- melt(sigs_individual, id = "sample")
	colnames(sigs_melt) <- c("sample", "sig", "value")
	sigs_melt[,"sig"] <- gsub("weights.Signature.", "", sigs_melt[,"sig"])
	sigs_melt[,"sig"] <- gsub("^(\\d)$", "0\\1", sigs_melt[,"sig"])
	#	Added leading 0 to 1 digit signature to hold numerical order.
#	Why the renames? Likely to keep in order, which I can't seem to figure out.
#	sigs_melt[,"sig"] <- gsub("weights.", "", sigs_melt[,"sig"])
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
	list <- sigs_individual[order(sigs_individual$zAPOBEC),]
	list1 <- as.vector(list[,"sample"])


	#print(sigs_melt[order(as.numeric(sigs_melt$sig)),])

	#	Apparently in a loop, plot must be printed?
	#print(ggplot(sigs_melt, aes(sample, value, fill = sig)) +
	#
	#print(ggplot(sigs_melt[order(as.numeric(as.character(sigs_melt$sig))),], aes(sample, value, fill = sig)) +
	#print(ggplot(sigs_melt[order(as.numeric(sigs_melt$sig)),], aes(sample, value, fill = sig)) +
	print(ggplot(sigs_melt, aes(sample, value, fill = sig, order = as.numeric(sig) )) +
		geom_col() +
		ggtitle( paste0("Signatures for ",this_type," (n=", length(list1), ")")) +
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
	#ggsave(paste0("signatures_for_",this_type,".png"),width=6, height=4, dpi=1000)

	sigs_individual <- subset(sigs_individual, zAPOBEC > 0)
	if( nrow(sigs_individual) > 0){
		sigs_melt <- melt(sigs_individual, id = "sample")
		colnames(sigs_melt) <- c("sample", "sig", "value")
		sigs_melt <- subset(sigs_melt, sig == "zAPOBEC")
		list <- sigs_individual[order(sigs_individual$zAPOBEC),]
		list1 <- as.vector(list[,"sample"])

		#	Apparently in a loop, plot must be printed?
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
		#ggsave(paste0("APOBEC_signatures_for_",this_type,".png"),width=6, height=4, dpi=1000)
	}
}

message("nrow(mut_all_sort)")		#	90475122
nrow(mut_all_sort)

Sys.time()


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


if( exists("mut_med_quantiles") ){
	rm(mut_med_quantiles)
}

message("med quantiles loop")
Sys.time()
for( this_type in types ) {
	mut_sub <- subset(cell_line_mutload, type == this_type)
	if( exists("mut_med_quantiles") ){
		x <- as.data.frame(t(quantile(mut_sub$mut_tot)))
		mut_med_quantiles <- rbind(mut_med_quantiles, x)
	} else {
		mut_med_quantiles <- as.data.frame(t(quantile(mut_sub$mut_tot)))
	}
}
Sys.time()

rownames(mut_med_quantiles) = types
mut_med_quantiles$type <- rownames(mut_med_quantiles)
colnames(mut_med_quantiles) <- c("low", "first", "med", "third", "high", "type")

mut_med_quantiles

mut_med_quantiles <- mut_med_quantiles[order(mut_med_quantiles$med),]
head(mut_med_quantiles)

plot_order <- as.vector(mut_med_quantiles[,"type"])
head(plot_order)

# Adjust plot size
options(repr.plot.width=16, repr.plot.height=6)

ggplot(mut_med_quantiles, aes(type, med)) +
	geom_col() +
	theme(axis.text.x=element_text(angle = 45, hjust = 1), legend.position = "none") +
	geom_errorbar(aes(ymin=first, ymax=third), width=.3) +
	scale_y_continuous(limits = c(0,3501),
		breaks = c(0,1200,2400,3600)) +
	xlab("Type") +
	ylab("Median Number of Mutations") +
	theme_bw() +
	theme(axis.text.x=element_text(angle = 45, hjust = 1),
		panel.border = element_blank(),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		axis.line = element_line(colour = "black")) +
	scale_fill_gradient(low = "blue", high = "red") +
	scale_x_discrete(limits = plot_order ) +
	ggtitle("Median Mutations by Type")

number <- as.data.frame(table(sample_types$type))
colnames(number) <- c("type", "freq")
ggplot(number, aes(type, freq)) +
	geom_point(size = 4) +
	#ylim(0,200) +
	theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
	scale_x_discrete(limits = types )

# use same sort as median number of mutations plot
number <- as.data.frame(table(sample_types$type))

colnames(number) <- c("type", "freq")

ggplot(number, aes(type, freq)) +
	geom_point(size = 4) +
	#ylim(0,200) +
	theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
	scale_x_discrete(limits = plot_order)


print("Another types loop")

#	Error in `.rowNamesDF<-`(x, value = value) : invalid 'row.names' length
#	Calls: rownames<- ... row.names<- -> row.names<-.data.frame -> .rowNamesDF<-
#	Execution halted

for( this_type in types ){
	sigs_types_individual <- subset(sigs_types, type == this_type)
	print( this_type )
	print( nrow(sigs_types_individual) )
	if( nrow(sigs_types_individual) == 0 ){
		print( paste0("No data with this type: ",this_type) )
		next
	}
	head(sigs_individual)
	sigs_types_individual_1 <- sigs_types_individual[order(sigs_types_individual$zAPOBEC),]
	rownames(sigs_types_individual_1) <- c(1:nrow(sigs_types_individual_1))
	sigs_types_individual_1[,"order"] <- rownames(sigs_types_individual_1)

	#	Apparently in a loop, plot must be printed?
	print(ggplot(sigs_types_individual_1, aes(as.numeric(order), mut_tot)) +
		geom_point(shape = 18, size = 4) +
		geom_smooth(span = 0.75) +
		theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
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


sigs_enrich <- merge(sigs_types, enrich_final, by = "sample")
head(sigs_enrich)

message("Merging sigs_enrich and tca_tct")
Sys.time()
sigs_enrich_tcw <- merge(sigs_enrich, tca_tct, by = "sample")
head(sigs_enrich_tcw)
Sys.time()


# Adjust plot size
options(repr.plot.width=10, repr.plot.height=10)


ggplot(sigs_enrich_tcw, aes(tca_tct,enrich_score)) +
	geom_point() #	+ ylim(0,5) + xlim(0,0.5)

ggplot(sigs_enrich_tcw, aes(zAPOBEC, tca_tct)) +
	geom_point() #	+ xlim(0,0.8) + ylim(0,0.5)

ggplot(sigs_enrich_tcw, aes(zAPOBEC, enrich_score)) +
	geom_point() #	+ xlim(0,0.8) + ylim(0,5)

# Try to plot "Mutation Fraction"/"Trinucleotide Context" from "context"
head(context)

context$sample <- rownames(context)
head(context)

context_melt <- melt(context,id="sample")
head(context_melt)

context_melt$alt <- substr(context_melt$variable, 5, 5)
head(context_melt)

context_melt$trinuc <- paste0(substr(context_melt$variable, 1, 1),
		substr(context_melt$variable, 3, 3),
		substr(context_melt$variable, 7, 7))
head(context_melt)

# Adjust plot size
options(repr.plot.width=16, repr.plot.height=6)

samples <- unique(as.vector(context_melt[,"sample"]))
head(samples)

length(samples)

message("Plotting")

#for( this_sample in sort(as.numeric(gsub("[^[:digit:]]", "",samples)))){
for( this_sample in mixedsort(samples)){
	message(this_sample)
	cell_line = subset(context_melt, sample == this_sample ) #& tissue == this_tissue )
	if( nrow(cell_line) > 0 ){

		#	Apparently in a loop, plot must be printed?
		print(ggplot(cell_line, aes(trinuc, value, fill = alt)) +
			geom_col() +
			ylim(0,0.40) +  # fixed y limit for easier viewing and comparison
			ggtitle( paste0("Mutational Fraction for ",this_sample) ) +
			theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
			xlab("Trinucleotide Context") +
			ylab("Mutation Fraction") +
			theme_bw() +
			theme(axis.text.x=element_text(angle = 45, hjust = 1),
				panel.border = element_blank(),
				panel.grid.major = element_blank(),
				panel.grid.minor = element_blank(),
				axis.line = element_line(colour = "black")))
		#ggsave(paste0("mutation_fraction_for_",this_sample,".png"),width=6, height=4, dpi=1000)
	}
}

