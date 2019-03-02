#!/usr/bin/env Rscript

message()
message("My Modified Mutation Signatures Script.")
message()


#	JAKE - added automatic package installation
list.of.packages <- c("deconstructSigs","ggplot2","BSgenome.Hsapiens.UCSC.hg38","reshape","stringr","plyr","gridExtra")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
#	Use Bioconductor to install packages
if(length(new.packages)) {
	source("https://bioconductor.org/biocLite.R")
	biocLite( new.packages )
}



message("Final analysis/visualization script for Jarvis et al., 2017, JNCI-CS")


message("ANALYSIS: Mutational Signatures")
require(deconstructSigs)
require(ggplot2)

require(BSgenome.Hsapiens.UCSC.hg38)
hg38 <- BSgenome.Hsapiens.UCSC.hg38

message("1. Read in and start formatting the dataframe")


#Error in with(cosmic_mut, cosmic_mut[order(cosmic_mut[, "sample"]), ]) : 
#  object 'cosmic_mut' not found
#	JAKE - added this read.table

cosmic_mut = read.table("cosmic_mut.txt",header = F, sep="\t",col.names = c("chr","pos","ref","alt","sample"))

#	JAKE - added
head(cosmic_mut)

cosmic_mut_sort <- with(cosmic_mut, cosmic_mut[order(cosmic_mut[,"sample"]),])

rownames(cosmic_mut_sort) <- NULL
cosmic_mut_sort$sample <- as.factor(cosmic_mut_sort$sample)

#	JAKE - added
head(cosmic_mut_sort)

#	Error: object 'cosmic_mut_all_sort' not found
#	JAKE - move this read.table from below
#	JAKE - changed to header=F
cosmic_mut_all_sort <- read.table(file = "cosmic_mut_all_sort.txt", header = F, sep = "\t", stringsAsFactors = T)

#	JAKE - moved here from below and corrected
colnames(cosmic_mut_all_sort) <- c("chr", "pos", "5_tetnuc", "3_tetnuc", "trinuc", "mut", "trinuc_mut", "strand", "context", "C_count", "TC_count", "TCA_count", "TCT_count", "YTCA_count", "RTCA_count", "sample")

#	JAKE - added
head(cosmic_mut_all_sort)


#	Searching
#Error in `$<-.data.frame`(`*tmp*`, ref, value = character(0)) : 
#  replacement has 0 rows, data has 609605
#Calls: $<- -> $<-.data.frame

deconstructSigs_input <- cosmic_mut_all_sort[,c(1:2,6,16)]
deconstructSigs_input$ref <- substr(deconstructSigs_input$mut, 1, 1) 
deconstructSigs_input$alt <- substr(deconstructSigs_input$mut, 3, 3) 
deconstructSigs_input <- subset(deconstructSigs_input, select = c("chr", "pos", "ref", "alt", "sample"))


message("1a. Due to the size of the dataframe, we must split it into 3 discrete sections so the matricies can be created")
message("efficiently. Be sure not to split up mutations within a cell line between different files.")
message("Beyond that requirement, breakpoints for files are arbitrary.")
deconstructSigs_input_1 <- deconstructSigs_input[c(1:224680),]
deconstructSigs_input_2 <- deconstructSigs_input[c(224681:443115),]
deconstructSigs_input_3 <- deconstructSigs_input[c(443116:663075),]


message("2. Create nx96 matrix, mapping number of trinucleotide muts to each sample (cell line)")
mut.counts_1 <- mut.to.sigs.input(mut.ref = deconstructSigs_input_1, sample.id = "sample", chr = "chr", pos = "pos", ref = "ref", alt = "alt", bsg = hg38)
mut.counts_2 <- mut.to.sigs.input(mut.ref = deconstructSigs_input_2, sample.id = "sample", chr = "chr", pos = "pos", ref = "ref", alt = "alt", bsg = hg38)
mut.counts_3 <- mut.to.sigs.input(mut.ref = deconstructSigs_input_3, sample.id = "sample", chr = "chr", pos = "pos", ref = "ref", alt = "alt", bsg = hg38)

mut.counts_12 <- rbind(mut.counts_1, mut.counts_2)
mut.counts <- rbind(mut.counts_12, mut.counts_3)

message("3. Match sample mutations to known signature mutational profiles:")
message("3a. Load the reference signature file first")
#signatures.nature2013 <- load("~/Desktop/RCRH Sequence Analysis/signatures.nature2013.rda") #If this doesn't work, load from the 'Files' tab in the view panel (if file is in the wd)

#	JAKE - changed location of this file
signatures.nature2013 <- load("/home/jake/.github/raerose01/deconstructSigs/data/signatures.nature2013.rda")


message("3b. Get sigature context for file")
context <- getTriContextFraction(mut.counts.ref = mut.counts, trimer.counts.method = "default")
context$tca_tct <- context[,"T[C>T]A"] + context[,"T[C>T]T"] + context[,"T[C>G]A"] + context[,"T[C>G]T"]
context$sample <- rownames(context)
tca_tct <- subset(context, select = c("sample", "tca_tct"))
rownames(tca_tct) <- NULL
context$sample <- NULL
context$tca_tct <- NULL

message("4. Create a function to write output.sigs for every cell line into one table")
message("4a. Split the dataframe into individual file")

#	JAKE - output.sigs.final doesn't exist yet? commenting out.
#	rm(output.sigs.final)

output.sigs.final <- as.data.frame(whichSignatures(context,
		sample.id = "ZR-75-30",
		signatures.cosmic,
		contexts.needed = F))
for(i in (1:nrow(context))) {
	message(i," - ",nrow(context))
	output.sigs <- as.data.frame(whichSignatures(context,
			sample.id = rownames(context[i,]),
			signatures.cosmic,
			contexts.needed = F))
	output.sigs.final <- rbind(output.sigs.final, output.sigs)
}


output.sigs.final <- output.sigs.final[-c(1021),]
output.sigs.final$zAPOBEC.Sig <- output.sigs.final$weights.Signature.2 + output.sigs.final$weights.Signature.13

output.sigs.final <- output.sigs.final[,c(1:30,319,320)]
output.sigs.final$sample <- rownames(output.sigs.final)
rownames(output.sigs.final) <- NULL

#	JAKE - added
message("output.sigs.final")
head(output.sigs.final)



#	need to load some of the tissue type code around line 300
#	Will need to get or create the cosmic_tissue_type.txt file
#'/Users/jakewendt/Downloads/pky002_supp/Supplementary Table 1-mutation counts.xls'
#'/Users/jakewendt/Downloads/pky002_supp/Supplementary Table 2-COSMIC signatures.xls'
#'/Users/jakewendt/Downloads/pky002_supp/Supplementary Table 3-APOBEC signatures.xls'

#	JAKE - These supplementary tables each contain 1021 rows, including header
#	JAKE - extracting as csv and selecting first 2 columns which are tissue and sample
#	JAKE - comparing hoping all exactly the same

#tail -n +2 Supplementary\ Table\ 1-mutation\ counts.csv | awk 'BEGIN{FS=",";OFS="\t"}{print $2,$1}' | sort > cosmic_tissue_type.txt-1
#tail -n +2 Supplementary\ Table\ 2-COSMIC\ signatures.csv | awk 'BEGIN{FS=",";OFS="\t"}{print $2,$1}' | sort > cosmic_tissue_type.txt-2
#tail -n +2 Supplementary\ Table\ 3-APOBEC\ signatures.csv | awk 'BEGIN{FS=",";OFS="\t"}{print $2,$1}' | sort > cosmic_tissue_type.txt-3
#diff cosmic_tissue_type.txt-1 cosmic_tissue_type.txt-2
#diff cosmic_tissue_type.txt-1 cosmic_tissue_type.txt-3
#	Cool. All the same.

#	This tissue file has more human readable tissues, L. Intestine rather than large_intestine
#	So either need to change several lines in this script or the tissues in the tissue file.



#	JAKE - moved this code here from below
message("Format the tissue type info")
#cosmic_tissue_type <- read.table(file = "cosmic_tissue_type.txt", header = T, stringsAsFactors = F, fill = T)
#	JAKE - no header in my version, and as the tissue type has spaces, need to specify sep as tab
cosmic_tissue_type <- read.table(file = "/home/jake/.github/unreno/genomics/dev/data_sets/Mutation_Signatures_Including_APOBEC_in_Cancer_Cell_Lines/20190225/cosmic_tissue_type.txt", header = F, stringsAsFactors = F, fill = T, sep="\t")
cosmic_tissue_type <- cosmic_tissue_type[,c(1:2)]
colnames(cosmic_tissue_type) <- c("sample", "tissue")
cosmic_tissue_type <- unique(cosmic_tissue_type)

#	JAKE - added
message("cosmic_tissue_type")
head(cosmic_tissue_type)

message("Combine tissue and mutation information")
cosmic_mut_tissue <- merge(cosmic_mut_all_sort, cosmic_tissue_type, by = "sample", all.x = T)
cell_line_mutload <- as.data.frame(table(cosmic_mut_tissue$sample))
colnames(cell_line_mutload) <- c("sample", "mut_tot")
cell_line_mutload <- merge(cell_line_mutload, cosmic_tissue_type, by = "sample", all.x = T)

#cell_line_mutload[775,3] <- "upper_aerodigestive_tract"
#	JAKE - my tissue list has "Upper Aerodigestive Tract"
cell_line_mutload[775,3] <- "Upper Aerodigestive Tract"

#	JAKE - added
message("cell_line_mutload")
head(cell_line_mutload)



#	JAKE - cell_line_mutload not defined???
#Error in merge(output.sigs.final, cell_line_mutload, by = "sample") : 
#  object 'cell_line_mutload' not found
sigs_tissues <- merge(output.sigs.final, cell_line_mutload, by = "sample") 


#	JAKE - added
message("sigs_tissues")
head(sigs_tissues)



sigs_tissues <- sigs_tissues[,-c(3,14,34)]

message("5. Each mutation plot was created separatly by replaceing the tissue variable name in line 79, ")
message(" and running through the ggplot command (through line 134). Note that a lettering scheme is applied to individuals ")
# signatures to allow for correct sorting.
#sigs_individual <- subset(sigs_tissues, tissue == "large_intestine")

#	JAKE - my extracts tissues have "L. Intestine"
sigs_individual <- subset(sigs_tissues, tissue == "L. Intestine")

#	JAKE - added
message("sigs_individual 1")
head(sigs_individual)

sigs_individual <- sigs_individual[,-c(32)]

#	JAKE - added
message("sigs_individual 2")
head(sigs_individual)

#	JAKE - added reshape for melt function
require(reshape)
sigs_melt <- melt(sigs_individual, id = "sample")

#	JAKE - added
message("sigs_melt 1")
head(sigs_melt)


#Error in data.frame(ids, x, data[, x]) : 
#  arguments imply differing number of rows: 0, 1
#Calls: melt ... melt.data.frame -> do.call -> lapply -> FUN -> data.frame
#Execution halted



colnames(sigs_melt) <- c("sample", "sig", "value")

#	JAKE - added
message("sigs_melt 2")
head(sigs_melt)

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

# Bar plots for mutational signature proportion (Used in FIGURE_2)
#
ggplot(sigs_melt, aes(sample, value, fill = sig)) +
	geom_col() +
	#scale_fill_brewer() +
	theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
	xlab("Cancer Cell Line") +
	ylab("Mutational Signature Proportion") +
	scale_x_discrete(limits = list1) +
	theme_bw() + 
	theme(axis.text.x=element_text(angle = 45, hjust = 1),
		panel.border = element_blank(), 
		panel.grid.major = element_blank(), 
		panel.grid.minor = element_blank(), 
		axis.line = element_line(colour = "black"))

message("Enrichment Score Calculations (uses file created by the 'count_trinuc_muts.pl' script)")
library(stringr)
library(plyr)

#	JAKE - Need to read this file much earlier
#cosmic_mut_all_sort <- read.table(file = "cosmic_mut_all_sort.txt", header = T, sep = "\t", stringsAsFactors = T)

#	JAKE - what is "test"?
#	JAKE - think this should be cosmic_mut_all_sort so moving to beginning
#colnames(test) <- c("chr", "pos", "5_tetnuc", "3_tetnuc", "trinuc", "mut", "trinuc_mut", "strand", "context", "C_count", "TC_count", "TCA_count", "TCT_count", "YTCA_count", "RTCA_count", "sample")












#	Error in eval(quote(list(...)), env) : object 'enrich1' not found
#	Calls: rbind -> standardGeneric -> eval -> eval -> eval
#	Execution halted

#	JAKE - STUCK HERE - Where do enrich1, enrich2, enrich3 and enrich4 come from?

#enrich_pre <- rbind(enrich1, enrich2)
#enrich_post <- rbind(enrich3, enrich4)
#enrich_tot <- rbind(enrich_pre, enrich_post)
#enrich_tot <- unique(enrich_tot)
#	JAKE - guessing here
enrich_tot <- unique(cosmic_mut_all_sort)



enrich_tot$Mut_TCW <- "0"
enrich_tot$Mut_C <- "0"
enrich_tot$Con_TCW <- "0"
enrich_tot$Con_C <- "0"

mut <- data.frame(do.call('rbind', strsplit(as.character(enrich_tot$mut),'>',fixed=T)))
enrich_tot$mut_ref <- mut[,1]

enrich_C <- subset(enrich_tot, mut_ref == "C")
enrich_CtoK <- subset(enrich_C, mut != "C>A") # Remove C>A mutations!

message("Mut_C")
enrich_CtoK[which(enrich_CtoK$mut_ref == "C"),"Mut_C"] <- "1"

message("Mut_TCW")
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>G]A"),"Mut_TCW"] <- "1"
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>G]T"),"Mut_TCW"] <- "1"
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>T]A"),"Mut_TCW"] <- "1"
enrich_CtoK[which(enrich_CtoK$trinuc_mut == "T[C>T]T"),"Mut_TCW"] <- "1"

message("Con_C")
enrich_CtoK$Con_C <- str_count(enrich_CtoK$context, "C") + str_count(enrich_CtoK$context, "G")

message("Con_TCW")
enrich_CtoK$Con_TCW <- str_count(enrich_CtoK$context, "TCA") + str_count(enrich_CtoK$context, "TCT") + str_count(enrich_CtoK$context, "TGA") + str_count(enrich_CtoK$context, "TGT")

message("Aggregate")
enrich_final <- enrich_CtoK[,16:20]
enrich_final$Mut_TCW <- as.integer(enrich_final$Mut_TCW)
enrich_final$Mut_C <- as.integer(enrich_final$Mut_C)

enrich_final <- ddply(enrich_final, "sample", numcolwise(sum))

rownames(enrich_final) <- enrich_final$sample
enrich_final$sample <- NULL
enrich_final$enrich_score <- (enrich_final$Mut_TCW / enrich_final$Con_TCW) / (enrich_final$Mut_C / enrich_final$Con_C)

enrich_matrix <- as.data.frame(enrich_final$Mut_TCW) 
enrich_matrix$Mut_Denom <- enrich_final$Mut_C - enrich_final$Mut_TCW
enrich_matrix$Con_TCW <- enrich_final$Con_TCW
enrich_matrix$Con_Denom <- enrich_final$Con_C - enrich_final$Con_TCW
rownames(enrich_matrix) <- rownames(enrich_final)
colnames(enrich_matrix) <- c("Mut_TCW", "Mut_Denom", "Con_TCW", "Con_Denom")

enrich_matrix <- as.matrix(enrich_matrix)

exe_fisher <- function(x) {
	m <- matrix(unlist(x), ncol = 2, nrow = 2, byrow = T)
	f <- fisher.test(m)
	return(as.data.frame(f$p.value))
}

fishers <- t(as.data.frame(apply(enrich_matrix, 1, exe_fisher)))
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


message("FIGURE_1: Median mutations in each cell line (uses columns 5 and 8 from the CosmicCLP_MutantExport.tsv file)")

#	JAKE - moved this code to above before first reference to cell_line_mutload
#message("Format the tissue type info")
#cosmic_tissue_type <- read.table(file = "cosmic_tissue_type.txt", header = T, stringsAsFactors = F, fill = T)
#cosmic_tissue_type <- cosmic_tissue_type[,c(1:2)]
#colnames(cosmic_tissue_type) <- c("sample", "tissue")
#cosmic_tissue_type <- unique(cosmic_tissue_type)
#
#message("Combine tissue and mutation information")
#cosmic_mut_tissue <- merge(cosmic_mut_all_sort, cosmic_tissue_type, by = "sample", all.x = T)
#cell_line_mutload <- as.data.frame(table(cosmic_mut_tissue$sample))
#colnames(cell_line_mutload) <- c("sample", "mut_tot")
#cell_line_mutload <- merge(cell_line_mutload, cosmic_tissue_type, by = "sample", all.x = T)
#cell_line_mutload[775,3] <- "upper_aerodigestive_tract"

message("Replace the tissue variable in line 218 with each tissue type sequentially and iteratively run through line 220")
message("to generate a complete quantile table")

#mut_sub <- subset(cell_line_mutload, tissue == "endometrium")
#	JAKE - my tissue list has Endometrium
mut_sub <- subset(cell_line_mutload, tissue == "Endometrium")

x <- as.data.frame(t(quantile(mut_sub$mut_tot)))




#Error in eval(quote(list(...)), env) : 
#  object 'mut_med_quantiles' not found
#Calls: rbind -> standardGeneric -> eval -> eval -> eval

#mut_med_quantiles <- rbind(mut_med_quantiles, x)
#	JAKE - guessing here
mut_med_quantiles <- x



#Error: object 'a' not found

#	JAKE - Guessin
#	rownames(mut_med_quantiles) <- a



mut_med_quantiles$tissue <- rownames(mut_med_quantiles)
colnames(mut_med_quantiles) <- c("low", "first", "med", "third", "high", "tissue")

ggplot(mut_med_quantiles, aes(tissue, med)) +
	geom_col() +
	theme(axis.text.x=element_text(angle = 45, hjust = 1), legend.position = "none") +
	geom_errorbar(aes(ymin=first, ymax=third), width=.3) +
	scale_y_continuous(limits = c(0,3501),
		breaks = c(0,1200,2400,3600)) +
	xlab("Tissue Type") +
	ylab("Median Number of Mutations") + 
	#geom_text(aes(label = freq), vjust = -0.2) +
	theme_bw() + 
	theme(axis.text.x=element_text(angle = 45, hjust = 1),
		panel.border = element_blank(), 
		panel.grid.major = element_blank(), 
		panel.grid.minor = element_blank(), 
		axis.line = element_line(colour = "black")) +
	scale_fill_gradient(low = "blue", high = "red") +
#	scale_x_discrete(limits = c("pleura","bone","kidney","prostate","pancreas",
#		"central_nervous_system","vulva","small_intestine","soft_tissue","upper_aerodigestive_tract",
#		"autonomic_ganglia","urinary_tract","breast","thyroid","ovary",
#		"testis","NS","haematopoietic_and_lymphoid_tissue","salivary_gland","liver",
#		"biliary_tract","adrenal_gland","cervix", "stomach","large_intestine",
#		"lung","oesophagus","skin","placenta","endometrium")) +
	scale_x_discrete(limits = c("Adrenal Gland","Autonomic Ganglia","Biliary Tract","Bladder","Bone","Breast","Cervix","CNS","Endometrium","Kidney","L. Intestine","Liver","Lung","NS","Oesophagus","Ovary","Pancreas","Placenta","Pleura","Prostate","Salivary Gland","S. Intestine","Skin","Soft Tissue","Stomach","Testis","Thyroid","Upper Aerodigestive Tract","Vulva","WBC")) +
	ggtitle("Median Mutations by Tissue Type")

#	JAKE - replaced tissue list with mine
#awk 'BEGIN{FS="\t"}{print $2}'  ../cosmic_tissue_type.txt | sort | uniq | paste -sd "," | sed 's/,/","/g'
#"Adrenal Gland","Autonomic Ganglia","Biliary Tract","Bladder","Bone","Breast","Cervix","CNS","Endometrium","Kidney","L. Intestine","Liver","Lung","NS","Oesophagus","Ovary","Pancreas","Placenta","Pleura","Prostate","Salivary Gland","S. Intestine","Skin","Soft Tissue","Stomach","Testis","Thyroid","Upper Aerodigestive Tract","Vulva","WBC"

message("FIGURE_1: Dots for cell numbers")

number <- as.data.frame(table(cosmic_tissue_type$tissue))
colnames(number) <- c("tissue", "freq")
ggplot(number, aes(tissue, freq)) +
	geom_point(size = 4) +
	ylim(0,200) +
	scale_x_discrete(limits = c("Adrenal Gland","Autonomic Ganglia","Biliary Tract","Bladder","Bone","Breast","Cervix","CNS","Endometrium","Kidney","L. Intestine","Liver","Lung","NS","Oesophagus","Ovary","Pancreas","Placenta","Pleura","Prostate","Salivary Gland","S. Intestine","Skin","Soft Tissue","Stomach","Testis","Thyroid","Upper Aerodigestive Tract","Vulva","WBC"))
#	scale_x_discrete(limits = c("pleura","bone","kidney","prostate","pancreas",
#		"central_nervous_system","vulva","small_intestine","soft_tissue","upper_aerodigestive_tract",
#		"autonomic_ganglia","urinary_tract","breast","thyroid","ovary",
#		"testis","NS","haematopoietic_and_lymphoid_tissue","salivary_gland","liver",
#		"biliary_tract","adrenal_gland","cervix", "stomach","large_intestine",
#		"lung","oesophagus","skin","placenta","endometrium"))


message("FIGURE_2: Plotting mutload vs cell line order (model lines with shaded intervals)")

#sigs_tissues_individual <- subset(sigs_tissues, tissue == "large_intestine")
#	JAKE - my tissue list has L. Intestine
sigs_tissues_individual <- subset(sigs_tissues, tissue == "L. Intestine")

#	JAKE - added
message("sigs_tissues_individual")
head(sigs_tissues_individual)

sigs_tissues_individual_1 <- sigs_tissues_individual[order(sigs_tissues_individual$zAPOBEC.Sig),]

#	JAKE - added
message("sigs_tissues_individual_1")
head(sigs_tissues_individual_1)

rownames(sigs_tissues_individual_1) <- c(1:nrow(sigs_tissues_individual_1))

#	JAKE - added
message("sigs_tissues_individual_1")
head(sigs_tissues_individual_1)

sigs_tissues_individual_1[,"order"] <- rownames(sigs_tissues_individual_1)

#	JAKE - added
message("sigs_tissues_individual_1")
head(sigs_tissues_individual_1)



#	missing column??

#FIGURE_2: Plotting mutload vs cell line order (model lines with shaded intervals)
#Error in FUN(X[[i]], ...) : object 'mut_tot' not found
#Calls: <Anonymous> ... ggplot_build.ggplot -> by_layer -> f -> <Anonymous> -> f -> lapply -> FUN





ggplot(sigs_tissues_individual_1, aes(as.numeric(order), mut_tot)) +
	geom_point(shape = 18, size = 4) +
	geom_smooth(span = 0.75) +
	theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
	xlab("Breast Cancer Cell Line") +
	ylab("Mut Burden") +
	ylim(0,1600) +
	theme_bw() + 
	theme(axis.text.x=element_text(angle = 45, hjust = 1),
		panel.border = element_blank(), 
		panel.grid.major = element_blank(), 
		panel.grid.minor = element_blank(), 
		axis.line = element_line(colour = "black"))

message("FIGURE_3: TCW, enrichment, and APOBEC sig correlation plots")

library(gridExtra)
sigs_enrich <- merge(sigs_tissues, enrich_final, by = "sample")
sigs_enrich_tcw <- merge(sigs_enrich, tca_tct, by = "sample")

# Scatterplots
x <- ggplot(sigs_enrich_tcw, aes(enrich_score, tca_tct)) +
	geom_point() +
	xlim(0,5) +
	ylim(0,0.5)
y <- ggplot(sigs_enrich_tcw, aes(zAPOBEC.Sig, tca_tct)) +
	geom_point() +
	xlim(0,0.6) +
	ylim(0,0.5)
grid.arrange(x,y, ncol = 2, nrow = 1)

message("FIGURE_4: Images were created using a separate script that used values from the Supplementary Table 1 ")
message("(counts at all trinucleotide contexts).")

