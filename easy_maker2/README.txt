# easy_marker 2

update to the second version, adapt to SGE cluseter

###0. install
  a. install EVM
  http://evidencemodeler.github.io/ 
  b. install easy_maker2
  git clone https://links
  chmod +x easy_maker2/*
  export PATH=/your/path/to/easy_maker2/
  

###1. generate scripts for SGE qsub
  easy_maker2 -n 100 -r genome.fasta -h homolog.pro.fasta -e trinity.dn.fasta -a augustus_training_folder \
  -s snap_training_hmm 

###2. harvest your results
  harvest.pl -g genome.fasta -d ~/software/EVidenceModeler -a anno_out
  rename_maker.pl lable              ###if you want rename genes' name

###3. understand results
  FASTA/ directory contains all sequences, including cDNA, cds, gene, protein and genome
  GFF/contig.all.gff is the combined gff3 file annotated by maker
  result/ contains gff and sequence files after rename
