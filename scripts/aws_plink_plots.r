#!/usr/bin/env Rscript

#mfiles <- list.files(path="for_plots", pattern="*.for.manhattan.plot", full.names=T, recursive=FALSE)
#qfiles <- list.files(path="for_plots", pattern="*.for.qq.plot", full.names=T, recursive=FALSE)

mfiles <- list.files(path="for_plots", pattern="*.for.manhattan.plot", full.names=T, recursive=TRUE)
qfiles <- list.files(path="for_plots", pattern="*.for.qq.plot", full.names=T, recursive=TRUE)

length(mfiles)
length(qfiles)

#	Output dir MUST already exist. R won't create it.
somePNGPath = "plots/"
#pdf(file=somePDFPath)

#dir.create(file.path(somePNGPath), showWarnings = FALSE)
dir.create(somePNGPath, showWarnings = FALSE)	#	works
library("qqman")

#	Disable all the warnings
options(warn=-1)
#Warning messages:
#1: In min(d[d$CHR == i, ]$pos) :
#  no non-missing arguments to min; returning Inf
#2: In max(d[d$CHR == i, ]$pos) :
#  no non-missing arguments to max; returning -Inf

for (i in 1:length(mfiles))
{
	message( i," / ",length(mfiles) )
	message( mfiles[i] )

	if( ( file.info(mfiles[i])$size == 0 ) || ( file.info(qfiles[i])$size == 0 ) ){
	  message("Manhattan or QQ file is empty. Skipping.")
		next
	}

#	png(paste(somePNGPath, basename(mfiles[i]), '.png', sep=""))
	png(paste(somePNGPath, mfiles[i], '.png', sep=""))
	db<-read.table(mfiles[i], sep=" ")
	dbgP<-data.frame(SNP=db$V2, CHR=db$V1, BP=db$V3, P=db$V4)
	dbgP$P<-ifelse(dbgP$P==0.000e+00,1.000e-302,dbgP$P)
	dq<-read.table(qfiles[i], sep=" ")
	dqgP<-data.frame(SNP=dq$V2, CHR=dq$V1, BP=dq$V3, P=dq$V4)
	par(mfrow=c(2,1))
	manhattan(dbgP, chr = "CHR", main=basename(mfiles[i]))
	qq(dqgP$P, main=basename(qfiles[i]))
	dev.off()
	rm(db)
	rm(dq)
	rm(dbgP)
	rm(dqgP)
}

message( 'Done' )
