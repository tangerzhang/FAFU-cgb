# easy_marker 2

update to the second version, adapt to SGE cluseter

###0. install
  a. install EVM
  http://evidencemodeler.github.io/
  b. install easy_maker2
  git clone https://github.com/tangerzhang/easy_marker.git
  cp easy_maker/*.pl /your/working/dir/
  
###1. prepare your config files and data
  a. EST or assembled RNA-seq data
  b. homologous proteins, several species
  c. your genome, which you want to annotation
  d. maker -CTL files, and modify them according to your needs
  e. special note: modify "genome=contig.fasta" in maker_opts.ctl, do not need your genome file.
  f. special note: use absolute path when config EST and homologous protein files in maker_opts.ctl

###2. split big genome into N fragments
  perl step01maker_split.pl -n 4 -g your.genome.fasta

###3. run each part
  After the big genome were splited into N parts, you need to run each part separately.
  Go to each part directory, and submit job.pbs if you are using PBS system; otherwise, run run.sh script in a stand-alone linux server.

###4. harvest your results
  perl step02 harvest.pl -g your.genome.fasta
  perl rename_maker.pl lable  ###if you want rename genes' name
###5. understand results
  FASTA/ directory contains all sequences, including cDNA, cds, gene, protein and genome
  GFF/contig.all.gff is the combined gff3 file annotated by maker
  result/ contains gff and sequence files after rename