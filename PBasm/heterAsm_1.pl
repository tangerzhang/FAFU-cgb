#!/usr/bin/perl -w

###This script was used to extract information from a manually checked allele table.
###In this case, allele table was generated from MCScanX and then manually assigned genes to a four-column csv table
###After running this script, users should use fill_HiC_scaffolds.pl to generate a new groups which could be subjected to further ALLHiC scaffolding


my %genedb;
open(IN, "grep 'gene' target.gff3 |") or die"";
while(<IN>){
	chomp;
	my @data = split(/\s+/,$_);
	my $ctg  = $data[0];
	my $gene = $1 if(/Name=(\S+)/);
	$genedb{$gene} = $ctg;
	}
close IN; 

open(IN, "BF.allele.table.csv") or die"";
<IN>;
while(<IN>){
	chomp;
	my @data = split(/,/,$_);
	my $chrn = $data[0];
	   $chrn =~ s/Chr//;
	   $chrn = sprintf("%02d",$chrn);
	   $chrn = "Chr".$chrn;
	my $ctgA = "";
	my $ctgB = "";
	if($data[2]=~/\|/ or $data[2] eq ""){
		$ctgA = "NA";
	  }else{
		$ctgA = $genedb{$data[2]};
		}
	if($data[3]=~/\|/ or $data[3] eq ""){
		$ctgB = "NA";
	  }else{
		$ctgB = $genedb{$data[3]};
		}
	my $gidA = $chrn."A";
	my $gidB = $chrn."B";
  $tigdb{$ctgA}->{$gidA}++  if($ctgA ne "NA");
  $tigdb{$ctgB}->{$gidB}++  if($ctgB ne "NA");
  
	}
close IN;


my %anchordb;
open(OUT, "> anchor.list") or die"";
foreach my $ctg (keys %tigdb){
	my $count = 0;
	$anchordb{$ctg}++;
	foreach my $gid (sort {$tigdb{$ctg}->{$b}<=>$tigdb{$ctg}->{$a}} keys %{$tigdb{$ctg}}){
	  $count++;
	  last if($count>1);
		print OUT "$gid	$ctg	+\n";
		}
	}
close OUT;

open(OUT, "> unanchor.list") or die"";
open(IN, "grep '>' draft.asm.fasta |sed 's/>//g' |") or die"";
while(<IN>){
	chomp;
	my $ctg = $_;
	$ctg =~ s/\s+//g;
	print OUT "$ctg\n" if(!exists($anchordb{$ctg}));
	}
close IN;
close OUT;

system(" perl ~/software/code/jcvi/HiC/fill_HiC_scaffolds.pl -b merge.clean.bam -a anchor.list -u unanchor.list -r draft.asm.fasta");

system("cat new_ordering/*A.ordering|cut -f2 > HA.list");
system("cat new_ordering/*B.ordering|cut -f2 > HB.list");
system("perl ~/software/script/getSeqFromList.pl -l HA.list -d draft.asm.fasta -o HA.fasta");
system("perl ~/software/script/getSeqFromList.pl -l HB.list -d draft.asm.fasta -o HB.fasta");



