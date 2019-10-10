#!/usr/bin/env Rscript

#setwd(‘temp/’)
#filenames <- list.files(
#	pattern=".mature.loc.bam.counts",
#	full.names=FALSE )
#All <- lapply(filenames,function(i){
#	print(i);
#	read.csv(i,sep=" ",row.names="ref")	#, header=FALSE, skip=4)
#})
#head(All)
#df <- do.call(rbind.data.frame, All)
#df <- do.call("rbind", All)
#head(df)
#write.csv(df,"all_postcodes.csv", row.names=FALSE)

#de <- merge(All, by=0, all=TRUE)  # merge by row names (by=0 or by="row.names")
#de[is.na(de)] <- 0                 # replace NA values
#de

#Reduce(merge,All)

#library(reshape)
#merge_all(All)

#library(plyr)
#dat_csv = ldply(filenames, read.csv,sep=" ",row.names="ref")
#head(dat_csv)



#	BiocManager::install(c('DESeq2','parathyroidSE'))
library( "DESeq2" )
df = read.csv('mirna.loc.bam.counts.csv')
head(df)

metadata = read.csv('metadata.csv')
print(metadata)

dds <- DESeqDataSetFromMatrix(
	colData = metadata,
	countData = df,
	design = ~ disease,
	tidy = TRUE )
print(dds)
#	design = ~ disease + sex,


dds <- DESeq(dds)
print(dds)


res <- results(dds)
head(results(dds, tidy=TRUE))


summary(res) #summary of results


plotMA( res, ylim = c(-1, 1) )
plotMA( res, ylim = c(-2, 2) )
plotMA( res, ylim = c(-5, 5) )


plotDispEsts( dds, ylim = c(1e-6, 1e1) )
plotDispEsts( dds, ylim = c(1e-6, 1e4) )


hist( res$pvalue, breaks=20, col="grey" )


res <- res[order(res$padj),]
head(res)


par(mfrow=c(2,3))

for( id in rownames(res[1:12,])){
	print(id)
	#plotCounts(dds, gene=id, intgroup=c('disease','sex'))
	plotCounts(dds, gene=id, intgroup=c('disease'))
}



#reset par
par(mfrow=c(1,1))

# Make a basic volcano plot
with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main="Volcano plot", xlim=c(-3,3)))

# Add colored points: blue if padj<0.01, red if log2FC>1 and padj<0.05)
with(subset(res, padj<.01 ), points(log2FoldChange, -log10(pvalue), pch=20, col="blue"))
with(subset(res, padj<.01 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="red"))

with(subset(res, padj<.001 ), points(log2FoldChange, -log10(pvalue), pch=20, col="green"))
with(subset(res, padj<.001 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="yellow"))

#legend("topright",
#	c('a','b','c','d','e'),
#	col=c(2:5,1))
legend("topright",
	legend=c('All','padj<0.01','padj<0.01 & abs>2','padj<0.001','padj<0.001 & abs>2'),
	col=c('black','blue','red','green','yellow'),
	pch = 20,
	lty=1:2, cex=0.8)



#	col=c('black','blue','red','green','yellow'))
#						c(species.interest, "Noise"),
#						lty=rep(1, length(species.interest)+1),
#						cex=1.5,
#						col=c((1+1):(length(species.interest)+1),1))


#
#	vsdata <- vst(dds, blind=FALSE)
#
#	Error in vst(dds, blind = FALSE) : less than 'nsub' rows,
#	  it is recommended to use varianceStabilizingTransformation directly
#
#	plotPCA(vsdata, intgroup="cc") #using the DESEQ2 plotPCA fxn we can
#




#	From manual https://bioconductor.org/packages/release/bioc/manuals/DESeq2/man/DESeq2.pdf

#	print("DESeq")
#	dds <- DESeq(dds)
#	print("plotMA")
#	plotMA(dds)
#	print("results")
#	res <- results(dds)
#	print("plotMA")
#	plotMA(res)

# using rlog transformed data:
#dds <- makeExampleDESeqDataSet(betaSD=1)



print("rlog")
rld <- rlog(dds)
print("plotPCA")
#plotPCA(rld)
plotPCA(rld, intgroup=c( 'disease' ))




# also possible to perform custom transformation:
print("estimateSizeFactors")
dds <- estimateSizeFactors(dds)
# shifted log of normalized counts
print("SummarizedExperiment")
se <- SummarizedExperiment(log2(counts(dds, normalized=TRUE) + 1), colData=colData(dds))
# the call to DESeqTransform() is needed to
# trigger our plotPCA method.
print("plotPCA")
#plotPCA( DESeqTransform( se ) )
plotPCA( DESeqTransform( se ), intgroup=c( 'disease' ) )



#	Concentration of counts over total sum of counts
print("estimateSizeFactors")
dds <- estimateSizeFactors(dds)
print("plotSparsity")
plotSparsity(dds)


#	Cluster Dendrogram
print("varianceStabilizingTransformation")
vsd <- varianceStabilizingTransformation(dds)
print("dist(t(assay(vsd)))")
dists <- dist(t(assay(vsd)))
print("plot(hclust(dists))")
plot(hclust(dists))

