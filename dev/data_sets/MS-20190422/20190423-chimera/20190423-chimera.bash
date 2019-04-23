#!/usr/bin/env bash


human=hg38.chr6	#	hg38_no_alts


echo $0

project=$( basename $PWD )
echo $project

for virus in HERV_K113 SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do
echo $virus

mkdir 20180802-chimera-${virus}-hg38_no_alts
cd 20180802-chimera-${virus}-hg38_no_alts

#	CEPH-ENA-PRJEB3246
#	CEPH-ENA-PRJEB3381
#	CEPH-ENA-PRJNA186949

#command chimera.bash --human hg38_no_alts --viral ${virus} --threads 4 /raid/data/raw/${project}/*.fastq.gz
chimera.bash --human ${human} --viral ${virus} --threads 4 /raid/data/raw/${project}/*.fastq.gz &

cd ..

done

