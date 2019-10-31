#!/usr/bin/env Rscript


pdf("DESeq2.plots.pdf")

#	BiocManager::install(c('DESeq2','parathyroidSE'))
library( "DESeq2" )
df = read.csv('mirna.loc.bam.counts.csv')
#df = read.csv('hairpin.loc.bam.counts.csv')
#df = read.csv('mature.loc.bam.counts.csv')
head(df)

message("Reading metadata.csv")
metadata = read.csv('metadata.csv',
	header=TRUE,
	stringsAsFactors = FALSE,
	colClasses='character')

print(metadata)

dds <- DESeqDataSetFromMatrix(
	colData = metadata,
	countData = df,
	design = ~cc,
	tidy = TRUE )
print(dds)


#	dds$cc <- relevel( dds$cc, "Control" )


dds <- DESeq(dds)
print(dds)


res <- results(dds)
head(results(dds, tidy=TRUE))


summary(res) #summary of results


plotMA( res, ylim = c(-1, 1) )


plotDispEsts( dds, ylim = c(1e-6, 1e1) )


hist( res$pvalue, breaks=20, col="grey" )


res <- res[order(res$padj),]
head(res)

message("Looping over top 5")
for(gene in row.names(head(res,5))){
	message(gene)
	print(plotCounts(dds, gene=gene, intgroup="cc"))
}
message("end loop over top 5")
	


#	par(mfrow=c(2,3))
#	plotCounts(dds, gene="ENSG00000152583", intgroup="dex")
#	plotCounts(dds, gene="ENSG00000179094", intgroup="dex")
#	plotCounts(dds, gene="ENSG00000116584", intgroup="dex")
#	plotCounts(dds, gene="ENSG00000189221", intgroup="dex")
#	plotCounts(dds, gene="ENSG00000120129", intgroup="dex")
#	plotCounts(dds, gene="ENSG00000148175", intgroup="dex")




#reset par
par(mfrow=c(1,1))

# Make a basic volcano plot
with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main="Volcano plot", xlim=c(-3,3)))

# Add colored points: blue if padj<0.01, red if log2FC>1 and padj<0.05)
with(subset(res, padj<.01 ), points(log2FoldChange, -log10(pvalue), pch=20, col="blue"))
with(subset(res, padj<.01 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="red"))



#
#	vsdata <- vst(dds, blind=FALSE)
#
#	Error in vst(dds, blind = FALSE) : less than 'nsub' rows,
#	  it is recommended to use varianceStabilizingTransformation directly
#
#	plotPCA(vsdata, intgroup="cc") #using the DESEQ2 plotPCA fxn we can
#




#	From manual https://bioconductor.org/packages/release/bioc/manuals/DESeq2/man/DESeq2.pdf
#
#	print("DESeq")
#	dds <- DESeq(dds)
#	print("plotMA")
#	plotMA(dds)
#	print("results")
#	res <- results(dds)
#	print("plotMA")
#	plotMA(res)
#
#	# using rlog transformed data:
#	#dds <- makeExampleDESeqDataSet(betaSD=1)
#	print("rlog")
#	rld <- rlog(dds)
#	print("plotPCA")
#	#plotPCA(rld)
#	plotPCA(rld, intgroup=c( 'disease' ))
#	# also possible to perform custom transformation:
#	print("estimateSizeFactors")
#	dds <- estimateSizeFactors(dds)
#	# shifted log of normalized counts
#	print("SummarizedExperiment")
#	se <- SummarizedExperiment(log2(counts(dds, normalized=TRUE) + 1), colData=colData(dds))
#
#	# the call to DESeqTransform() is needed to
#	# trigger our plotPCA method.
#	print("plotPCA")
#	#plotPCA( DESeqTransform( se ) )
#	plotPCA( DESeqTransform( se ), intgroup=c( 'disease' ) )
#
#	print("estimateSizeFactors")
#	dds <- estimateSizeFactors(dds)
#	print("plotSparsity")
#	plotSparsity(dds)
#
#	print("varianceStabilizingTransformation")
#	vsd <- varianceStabilizingTransformation(dds)
#	print("dist(t(assay(vsd)))")
#	dists <- dist(t(assay(vsd)))
#	print("plot(hclust(dists))")
#	plot(hclust(dists))
#
