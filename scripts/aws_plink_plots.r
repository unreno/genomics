
mfiles <- list.files(path="for_plots", pattern="*.for.manhattan.plot", full.names=T, recursive=FALSE)
qfiles <- list.files(path="for_plots", pattern="*.for.qq.plot", full.names=T, recursive=FALSE) 

print( mfiles )

length(mfiles)
length(qfiles)

#	Output dir MUST already exist. R won't create it.
somePNGPath = "plots/"
#pdf(file=somePDFPath)  

library("qqman") 

#for (i in length(mfiles))   
for (i in 1:length(mfiles))   
{   
	print( i )
	print( mfiles[i] )
	 
	png(paste(somePNGPath, basename(mfiles[i]), '.png', sep=""))
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

print( 'Done' )
