#!/usr/bin/env python3

import pandas as pd

def trimsubjectname(name):
	#name = HG00250.1.M_111124_4.bam  
	return name.split(".")[0]
	

#a = pd.read_csv("subjects_info.csv")

a = pd.read_csv("/raid/data/raw/gEUVADIS/subjects_info.csv")
a = a.drop(["Family ID","Population Description","Relationship","Unexpected Parent/Child ","Non Paternity","Siblings","Grandparents","Avuncular","Half Siblings","Unknown Second Order","Third Order","Other Comments"], axis=1)

#b = pd.read_csv("/raid/data/working/1000genomes/20160701.1000genomes.chimeric_hg19_no_alts_alignment/overlappers_table.hg19_no_alts.Q00.transposed.csv")
b = pd.read_csv("/raid/data/working/1000genomes/20160701.1000genomes.chimeric_hg19_no_alts_alignment/overlappers_table.hg19_no_alts.Q20.transposed.csv")

merged = pd.merge(a, b, left_on = 'Sample', right_on = 'position', how = 'left')
merged = merged.drop(["position"], axis=1)
merged.rename(columns={"Sample":"subject", "Population":"population", "Gender":"gender" },inplace=True)


c = pd.read_csv("/raid/data/working/gEUVADIS/20170508.geuvadis.rna_viral_alignment_check.counts.tsv",sep="\t")
c['subject'] = c['bam'].apply(trimsubjectname)
c.drop(['bam','Unnamed: 19'], axis=1, inplace=True)

c.rename(columns={
	"gi|1944536|emb|X14112.1|":"Human herpesvirus 1",
	"gi|556197549|gb|JN561323.2|":"Human herpesvirus 2 strain HG52",
	"gi|59989|emb|X04370.1|":"Human herpesvirus 3 (strain Dumas)",
	"gi|94734074|emb|V01555.2|":"Epstein-Barr virus (EBV) genome strain B95-8",
	"gi|155573622|ref|NC_006273.2|":"Human herpesvirus 5 strain Merlin",
	"gi|224020395|ref|NC_001664.2|":"Human herpesvirus 6A",
	"gi|9633069|ref|NC_000898.1|":"Human herpesvirus 6B",
	"gi|51874225|ref|NC_001716.2|":"Human herpesvirus 7",
	"gi|336284682|ref|NC_001545.2|":"Rubella virus",
	"gi|356457872|ref|NC_000883.2|":"Human parvovirus B19",
	"gi|545714221|gb|KF477318.1|":"Torque teno virus isolate NTHA",
	"gi|380082986|gb|JQ040513.1|":"Human coxsackievirus B3 strain Macocy",
	"gi|325305968|gb|GU942823.1|":"Human coxsackievirus A7 isolate Parker",
	"gi|209811|gb|J01917.1|ADRCG":"Adenovirus type 2",
	"gi|527487091|dbj|AB775201.1|":"Hepatitis B virus DNA isolate: HB12-0929",
	"gi|221612|dbj|D11168.1|HPCJTA":"Hepatitis C virus (HCV)"
},inplace=True)

merged = pd.merge(merged, c, on = "subject" )
merged.to_csv("all_subjects_info.csv", index=False)

