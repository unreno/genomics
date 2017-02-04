
#source("https://bioconductor.org/biocLite.R")
#biocLite("TCGAbiolinks")

library(TCGAbiolinks)

barcodes=c( "TCGA-02-2483", "TCGA-02-2485", "TCGA-06-0124", "TCGA-06-0125", "TCGA-06-0128", "TCGA-06-0145", "TCGA-06-0152", "TCGA-06-0155", "TCGA-06-0157", "TCGA-06-0185", "TCGA-06-0190", "TCGA-06-0208", "TCGA-06-0210", "TCGA-06-0211", "TCGA-06-0214", "TCGA-06-0221", "TCGA-06-0648", "TCGA-06-0686", "TCGA-06-0744", "TCGA-06-0745", "TCGA-06-0877", "TCGA-06-0881", "TCGA-06-1086", "TCGA-06-2557", "TCGA-06-2570", "TCGA-06-5411", "TCGA-06-5415", "TCGA-14-0786", "TCGA-14-1034", "TCGA-14-1401", "TCGA-14-1402", "TCGA-14-1454", "TCGA-14-1459", "TCGA-14-1823", "TCGA-14-2554", "TCGA-15-1444", "TCGA-16-1063", "TCGA-16-1460", "TCGA-19-1389", "TCGA-19-2620", "TCGA-19-2624", "TCGA-19-2629", "TCGA-19-5960", "TCGA-26-1438", "TCGA-26-5132", "TCGA-26-5135", "TCGA-27-1831", "TCGA-27-2523", "TCGA-27-2528", "TCGA-32-1970", "TCGA-41-5651")

query.exp.hg19 <- GDCquery(project = "TCGA-GBM", data.category = "Gene expression", data.type = "Gene expression quantification", platform = "Illumina HiSeq", file.type  = "normalized_results", experimental.strategy = "RNA-Seq", barcode = barcodes, legacy = TRUE)

GDCdownload(query.exp.hg19)

data <- GDCprepare(query.exp.hg19)



