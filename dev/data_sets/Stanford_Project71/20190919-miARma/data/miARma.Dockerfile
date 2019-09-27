
#	docker build --file miARma.Dockerfile --tag miarma ./

FROM miarmaseq/ubuntu

RUN apt update && apt -y full-upgrade && apt -y autoremove && apt install wget

RUN cd /home/miARma/miARma/ \
	&& wget https://sourceforge.net/projects/miarma/files/Examples/Examples_miARma_miRNAs.tar.bz2 \
	&& tar xvfj Examples_miARma_miRNAs.tar.bz2 \
	&& /bin/rm -rf Examples_miARma_miRNAs.tar.bz2
 
RUN cd /home/miARma/miARma/ \
	&& wget https://sourceforge.net/projects/miarma/files/Genomes/Index_bowtie1_hg19.tar.bz2 \
	&& tar xvfj Index_bowtie1_hg19.tar.bz2 \
	&& /bin/rm -rf Index_bowtie1_hg19.tar.bz2
 
RUN cd /home/miARma/miARma/ \
	&& wget https://sourceforge.net/projects/miarma/files/Examples/Examples_miARma_mRNAs.tar.bz2 \
	&& tar xvfj Examples_miARma_mRNAs.tar.bz2 \
	&& /bin/rm -rf Examples_miARma_mRNAs.tar.bz2



#	ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_31/gencode.v31.long_noncoding_RNAs.gtf.gz



#	export PERL5LIB=/home/miARma/miARma/lib/Perl:/home/miARma/miARma/lib
ENV PERL5LIB=/home/miARma/miARma/lib/Perl:/home/miARma/miARma/lib

#	prepend PATH with /home/miARma/miARma
ENV PATH="/home/miARma/miARma:${PATH}"



RUN wget -P /home/miARma/miARma/ ftp://mirbase.org/pub/mirbase/22.1/genomes/hsa.gff3



WORKDIR /home/miARma/miARma


#	docker build --file miARma.Dockerfile --tag miarma /
#	docker run -v /raid/data/working/tmp:/mnt --rm -it miarma /home/miARma/miARma/miARma /mnt/Known_miRNAs_pipeline.ini


