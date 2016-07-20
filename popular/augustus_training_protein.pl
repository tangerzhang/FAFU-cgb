#!/usr/bin/perl -w
####This script was used to select protein training set based homolog or self-protein
use Getopt::Std;
getopts "i:d:g:s:";


if ((!defined $opt_i)|| (!defined $opt_d)  || (!defined $opt_g) || (!defined $opt_s)) {
    die "************************************************************************
    Usage: perl $0 -i protein.fasta -d plant_database.fasta -g genome.fasta -s species_name
      -h : help and usage.
      -i : protein.fasta, could be the homologous protein or the protein sequences generated from your genome
      -d : database.fasta
      -g : genome.fasta
      -s : species label
************************************************************************\n";
}else{
  print "************************************************************************\n";
  print "Version demo\n";
  print "Copyright to Tanger, tanger.zhang\@gmail.com\n";
  print "RUNNING...\n";
  print "************************************************************************\n";
        
        }

print "######################################################################\n";
print "Please run check_env.pl first before running this script\n";
print "######################################################################\n";

print "1. blastp to plant protein database for identification of relatively complete protein sequences\n";


my $len_cmd = "perl ~/software/script/getFaLen.pl -i $opt_d -o len.txt";
system($len_cmd);
my $blast_cmd = "simple_blast -i $opt_i -d $opt_d -p blastp -c 40 -e 1e-10 -n 1";
system($blast_cmd);
system("rm dbname*");

my %lendb;
open(IN, "len.txt") or die"";
while(<IN>){
	chomp;
	my ($gene,$len) = split(/\s+/,$_);
	if(exists($lendb{$gene}) and $len > $lendb{$gene}){
		$lendb{$gene} = $len;
	}elsif(!exists($lendb{$gene})){
		$lendb{$gene} = $len; 
		}
	
	}
close IN;

open(OUT, "> out.1.txt") or die"";
open(IN, "blast.out") or die"";
while(<IN>){
	chomp;
	my @data   = split(/\s+/,$_);
	my $gene   = $data[0];
	my $p_gene = $data[1];
	my $p_len  = abs($data[8] - $data[9] + 1);
	my $ratio  = $p_len/$lendb{$p_gene};
	print OUT "$gene	$ratio	$p_gene	$p_len	$lendb{$p_gene}\n";
	}
close IN;
close OUT;

my %infordb;
my $gene;
open(IN, $opt_i) or die"";
while(<IN>){
	chomp;
	if(/>/){
		$gene = $_;
		$gene =~ s/>//g;
	}else{
		$infordb{$gene} .= $_;
		}
	}
close IN;

my %com_setdb;
open(OUT, "> tmp.1.protein.fasta") or die"";
open(IN, "sort -k 2 -n -r out.1.txt |head -n 2000 |") or die"";
while(<IN>){
	chomp;
	my ($gene,$ratio) = split(/\s+/,$_);
	print OUT ">$gene\n$infordb{$gene}\n";
	}
close IN;
close OUT;
#system("rm out.1.txt");
#system("tmp.*");

print "2. run cdhit to remove proteins with 70% identity or higher\n";
my $cdhit_cmd = "cd-hit -i tmp.1.protein.fasta -o training.set.fasta -c 0.7";
system($cdhit_cmd);

print "3. run scipio.1.4.1.pl to get final training protein\n";
my $scipio_cmd = "scipio.1.4.1.pl --blat_output=prot.vs.genome.psl $opt_g training.set.fasta > scipio.yaml";
system($scipio_cmd);
system("cat scipio.yaml | yaml2gff.1.4.pl > scipio.scipiogff");
system("scipiogff2gff.pl --in=scipio.scipiogff --out=scipio.gff");
system("cat scipio.yaml | yaml2log.1.4.pl > scipio.log");
system("gff2gbSmallDNA.pl scipio.gff $opt_g 1000 genes.raw.gb");
system("etraining --species=generic --stopCodonExcludedFromCDS=true genes.raw.gb 2> train.err");
system("cat train.err | perl -pe 's/.*in sequence (\\S+): .*/$1/' > badgenes.lst");
system("filterGenes.pl badgenes.lst genes.raw.gb > genes.gb");
system("grep -c \"LOCUS\" genes.raw.gb genes.gb");

print "4. runing training\n";
system("randomSplit.pl genes.gb 100");
system("new_species.pl --species=$opt_s");   ###$opt_s is the species name you need to specify
system("etraining --species=$opt_s genes.gb.train");
system("augustus --species=$opt_s genes.gb.test | tee firsttest.out ");
print "Please read the accuracy report\n";
system("grep -A 22 Evaluation firsttest.out");
system("optimize_augustus.pl --species=$opt_s genes.gb.train");  ###  will take ~1d
system("etraining --species=$opt_s genes.gb.train");
print "Please read the accuracy report after optimization\n";
system("augustus --species=$opt_s genes.gb.test");







