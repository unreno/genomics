#!/usr/bin/env Rscript

library(foreach)
library(doParallel)
library(optparse)

option_list = list(
	make_option(c('-c', '--case_or_control'), type='character', default=NULL, 
		help='case or control', metavar='character')
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
message( 'Case or Control: ',opt$case_or_control )
message()

if ( ( ! paste0('',opt$case_or_control) %in% c('case','control') ) ){
  print_help(opt_parser)
  stop('Case or Control required.\n', call.=FALSE)
}

cl<-makeCluster(1)
registerDoParallel(cl)

#	This file must be opened outside the loop to allow for the chunky loop.
con = file(paste0(opt$case_or_control,'_out_w_bonf_top.kmerDiff'), 'r')

Z <- read.table('pcs.evec',header=FALSE);

input <- read.table('gwas_eigenstratX.ind');

Y <- matrix(nrow=nrow(Z),ncol=1);
cov <- matrix(nrow=nrow(Z),ncol=1);

totals <- read.table('total_kmer_counts.txt');

counts<- vector(length=length(Y));

for(i in 1:length(Y)) {
	if(input[i,3]=='Case') {
		Y[i,1]=1;
	} else if(input[i,3]=='Control') {
		Y[i,1]=0;
	} else {
		Y[i,1]=input[i,3];
	}
}

print(Y);

if (FALSE) { 
	input <- read.table('covariates.txt');
	for(i in 1:length(cov)) {
		if(input[i,1]=='M') {
			cov[i,1]=0;
		} else {
			cov[i,1]=1;
		}
	}
}

totalKmers <- read.table('total_kmers.txt',header=FALSE);

n<-nrow(Z);

cat('', file = paste0('pvals_',opt$case_or_control,'_top.txt'))

CHUNK_SIZE=10000;

ptm <- proc.time()


#	what if number of records is a multiple of chunk size? it'll crash on last loop? Better way?
#	the case_out_w_bonf_top.kmerDiff has exactly 200,000! How does this work for anyone????
#	why reading in chunks anyway? perhaps expecting this to be HUGE
while(TRUE){

# tried a fixed loop but no difference in output
#for(l in 1:20){

	#	the file must be opened outside the loop so that the pointer can be preserved.
	#kmercounts <- read.table(con,nrow=CHUNK_SIZE);

	#kmercounts <- read.table(con);

	#	If we really want to do this chunky style, using a try seems like a better option.
	#	Still refining this though.
	#	And the results are identical so no real benefit
	error_status = tryCatch(kmercounts <- read.table(con,nrow=CHUNK_SIZE),
		error = function(e){
			#	break; 	#	doesn't work in trycatch
			TRUE
		}
	)
	if( isTRUE(error_status) ) break


	nr=nrow(kmercounts);

	ls<-foreach(j=icount(nr), .combine=cbind) %dopar% {

		for(i in 1:length(Y)) {
			counts[i]=kmercounts[j,4+i]/totals[i,1];
		}

		#	model1<-glm(formula = Y ~ counts, family = binomial(link = 'logit'));

		model2<-glm(formula = Y ~ Z[,1]+Z[,2]+totals[,1]+counts, family = binomial(link = 'logit'));

		#summary(model1);

		#	v1<-anova(model1, test='Chisq');

		#summary(model2);

		v2<-anova(model2, test='Chisq');

		#	rbind(v1$'Pr(>Chi)'[2],v2$'Pr(>Chi)'[13]);

		v2$'Pr(>Chi)'[5];
	}

	write(ls,file=paste0('pvals_',opt$case_or_control,'_top.txt'),ncolumns=1,append=TRUE,sep='\t');

	#	This doesn't quite work when last read IS the chunk size?
	#if(nr<CHUNK_SIZE) {
	#	break;
	#}

} #	while or for loop


close(con); 

print(proc.time() - ptm)

stopCluster(cl)

