BEGIN{FS=OFS="\t"}{
  samtools = "samtools faidx /raid/refs/fasta/hg38.fa "$1":"$2-2"-"$2+2" "
  while(samtools | getline x ){};
  close(samtools);
  print $1,$2,$3,$4,toupper(x) \
}
