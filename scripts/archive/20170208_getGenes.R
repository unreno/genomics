
#source("https://bioconductor.org/biocLite.R")
#biocLite("ballgown")

#	wget https://www.dropbox.com/s/4gd05ghjkurj170/Homo_sapiens.GRCh37.73_chrPrefix.gtf

library(ballgown)

load("eQTL_GEUVADIS_imputed_list_cis_1e6_snpM)IKZF.rda")
load("eqtl_rs2290400.rda")
load("gownTransMap2.rda")

## annotate to Ensembl genes
gtf="Homo_sapiens.GRCh37.73_chrPrefix.gtf"
genes = getGenes(gtf, gownTransMap2, UCSC=FALSE, attribute = "gene_name")
names(genes) = names(gownTransMap2)
eqtl$geneSymbol = genes[match(eqtl$gene, names(genes))]

genes2 = getGenes(gtf, gownTransMap2, UCSC=FALSE, attribute = "gene_id")
names(genes2) = names(gownTransMap2)
eqtl$ensemblGeneID = genes2[match(eqtl$gene, names(genes2))]

sig = eqtl[eqtl$FDR < 0.05,]

save(sig, file="sig_eQTL_GEUVADIS_imputed_list_cis_1e6_annotated_.rda" ,compress=TRUE)




















me<-me2

eqtl = me$cis$eqtls
eqtl$snps = as.character(eqtl$snps)
eqtl$gene = as.character(eqtl$gene)
eqtl$snpChr = snpspos$chr[match(eqtl$snps, snpspos$name)]


#	what's snpspos?


eqtl$snpPos = snpspos$pos[match(eqtl$snps, snpspos$name)]

eqtl$transChr = genepos$chr[match(eqtl$gene, genepos$txID)]
eqtl$transStart = genepos$start[match(eqtl$gene, genepos$txID)]
eqtl$transEnd = genepos$end[match(eqtl$gene, genepos$txID)]

eqtl$distStartMinusSnp = eqtl$transStart - eqtl$snpPos
eqtl = DataFrame(eqtl)

