#!/usr/bin/env bash


export SAMTOOLS_VERSION=1.5
export BOWTIE2_VERSION=2.3.3.1

export SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download
export HTSLIB_URL=https://github.com/samtools/htslib/releases/download
export BOWTIE2_URL=https://sourceforge.net/projects/bowtie-bio/files/bowtie2
export BOWTIE2_FILE=bowtie2-${BOWTIE2_VERSION}-source.zip
 
cd \
	&& wget ${HTSLIB_URL}/${SAMTOOLS_VERSION}/htslib-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar xvfj htslib-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd htslib-${SAMTOOLS_VERSION} \
	&& ./configure --prefix $HOME/.local \
	&& make \
	&& make install \
	&& cd ~ \
	&& /bin/rm -rf htslib-${SAMTOOLS_VERSION}*
 

cd \
	&& wget ${SAMTOOLS_URL}/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar xvfj samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd samtools-${SAMTOOLS_VERSION} \
	&& ./configure --prefix $HOME/.local \
	&& make \
	&& make install \
	&& cd ~ \
	&& /bin/rm -rf samtools-${SAMTOOLS_VERSION}*


cd \
	&& wget https://github.com/01org/tbb/archive/2018_U1.tar.gz \
	&& tar xvfz 2018_U1.tar.gz \
	&& cd tbb-2018_U1 \
	&& make \
	&& sudo cp -r ~/tbb-2018_U1/include/tbb /usr/include/ \
	&& sudo mkdir /usr/lib/tbb \
	&& sudo cp ~/tbb-2018_U1/build/linux_intel64_gcc_cc4.8.5_libc2.17_kernel4.4.14_release/*.so* /usr/lib/tbb/ \
	&& cd ~ \
	&& /bin/rm -rf ~/tbb-2018_U1 2018_U1.tar.gz


cd \
	&& wget ${BOWTIE2_URL}/${BOWTIE2_VERSION}/${BOWTIE2_FILE}/download -O ${BOWTIE2_FILE} \
	&& unzip ${BOWTIE2_FILE} \
	&& cd bowtie2-${BOWTIE2_VERSION} \
	&& sed -i 's;/usr/local;~/.local;' Makefile \
	&& LD_LIBRARY_PATH="/usr/lib/tbb/" INC="-I /usr/include/tbb/ -L /usr/lib/tbb/" make -e \
	&& make install \
	&& cd ~ \
	&& /bin/rm -rf bowtie2-${BOWTIE2_VERSION}*

