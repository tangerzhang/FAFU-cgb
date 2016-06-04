#!/usr/bin/perl 

use Getopt::Std;
getopts "i:o:";


if ((!defined $opt_i)|| (!defined $opt_o) ) {
    die "************************************************************************
    Usage: perl falcon_format.pl -i input.fasta -o preads.fasta
      -h : help and usage.
      -i : input.fasta
      -o : preads.fasta
************************************************************************\n";
}else{
  print "************************************************************************\n";
  print "Version 1.0\n";
  print "Copyright to Tanger\n";
  print "RUNNING...\n";
  print "************************************************************************\n";
    }

my $count;
open(OUT, "> $opt_o") or die"";
open(IN, $opt_i) or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($name,$seq) = split(/\n/,$_,2);
	$seq =~ s/\s+//g;
	my $len = length $seq;
	$count++;
	$count = sprintf("%09d",$count);
	$name = "prolog/".$count."/0_".$len;
	print OUT ">$name\n$seq\n";
	}
close IN;
close OUT;
