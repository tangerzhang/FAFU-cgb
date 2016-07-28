#!/usr/bin/perl -w

###This script was used to convert fasta sequences to axt format, which is the input of KaKs_calculator

use Getopt::Std;
getopts "i:";


if (!defined $opt_i ) {
    die "************************************************************************
    Usage: perl cds2axt.pl -i label 
      -h : help and usage.
      -i : input cds file, fasta format
      -o : dir_out
************************************************************************\n";
}

my $cds      =  $opt_i."cds.fasta";
my $pro      =  $opt_i."pro.fasta";
my $out_dir  =  $opt_i;

system("rm -rf  $out_dir");
###generate homologs pairs

open(IN, "pair_group.pl cds_fasta/$cds|") or die"";
while(<IN>){
	chomp;
	my $homo    = $_;
	$homo       =~ s/\s+/_/g;
	$homo    = $homo."homo.txt";
	open(my $out, "> homo_dir/$homo") or die"";
	print $out "$_\n";
	close $out;
	`ParaAT.pl -h homo_dir/$homo -n cds_fasta/$cds -a pro_fasta/$pro -p proc -o $out_dir -f axt`;
	system("mv $out_dir/* axt_dir");
	system("rm -rf $out_dir");
	}
close IN;



