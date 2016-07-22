#!/usr/bin/perl -w


#$tmp_info = `grep -v 'mRNA' GFF/contig.all.gff |grep -v 'exon'|grep 'gene' |sort -k1,1 -k4,4n > gene.order.tmp`;
my $lable = $ARGV[0];

if(!defined $lable){
	die "Usage: perl $0 lable\n";
	}

system("rm -rf result");
system("mkdir result");

my $count = 0;
my %infordb;
my $gene_o_name = "";
#my %countdb;
open(IN, "grep -v 'mRNA' GFF/contig.all.gff |grep -v 'exon'|grep 'gene' |sort -k1,1 -k4,4n |") or die"";
while(<IN>){
	chomp;
	my @data = split(/\s+/,$_);
	my $chrn = $data[0];
	my $posi = $data[3];
	if($data[8]=~/ID=(.*)\;Name/){
		$gene_o_name = $1;
		}
  $count += 10;
	$count = sprintf("%07d",$count);
  my $gene_n_name = $lable."".$count;
	$infordb{$gene_o_name} = $gene_n_name;
#	$countdb{$gene_n_name} = $count;
	}
close IN;

my %gffdb ;

my $gene;
open(IN, "GFF/contig.all.gff") or die"";
while(<IN>){
	chomp;
	next if(/#/);
	my @data = split(/\s+/,$_);
	my $feature = $data[2];
	if($feature eq "gene"){
		if(/ID=(.*)\;Name=/){
			$gene = $1;
			}
	}else{
		if(/ID=(.*)-mRNA.*;Parent=/){
			$gene = $1;
			}
	}

	my $line = $_;
	$line =~ s/$gene/$infordb{$gene}/g;
	my $id = $infordb{$gene};
	$id =~ s/$lable//g;
	$gffdb{$id} .= $line."\n";
	}
close IN;

my $out_gff = $lable.".gff3";
open(OUT, "> result/$out_gff") or die"";
print OUT "##gff-version 3\n";
foreach my $id(sort {$a<=>$b} keys %gffdb){
	print OUT "$gffdb{$id}";
	}
close OUT;

my $out_cDNA = $lable.".cDNA.fasta";
open(OUT, ">result/$out_cDNA") or die"";
open(IN, "FASTA/cDNA.fasta") or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($gene,$seq) = split(/\n/,$_,2);
	$gene =~ s/\s+.*//g;
	$gene =~ s/-mRNA-1//g;
	my $new_name = $infordb{$gene};
	print OUT ">$new_name\n$seq";
	}
close IN;
close OUT;

my $out_cds = $lable.".cds.fasta";
open(OUT, ">result/$out_cds") or die"";
open(IN, "FASTA/cds.fasta") or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($gene,$seq) = split(/\n/,$_,2);
	$gene =~ s/\s+.*//g;
	$gene =~ s/-mRNA-1//g;
	my $new_name = $infordb{$gene};
	print OUT ">$new_name\n$seq";
	}
close IN;
close OUT;


my $out_gene = $lable.".gene.fasta";
open(OUT, ">result/$out_gene") or die"";
open(IN, "FASTA/gene.fasta") or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($gene,$seq) = split(/\n/,$_,2);
	$gene =~ s/\s+.*//g;
	$gene =~ s/-mRNA-1//g;
	my $new_name = $infordb{$gene};
	print OUT ">$new_name\n$seq";
	}
close IN;
close OUT;

my $out_protein = $lable.".protein.fasta";
open(OUT, ">result/$out_protein") or die"";
open(IN, "FASTA/protein.fasta") or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($gene,$seq) = split(/\n/,$_,2);
	$gene =~ s/\s+.*//g;
	$gene =~ s/-mRNA-1//g;
	my $new_name = $infordb{$gene};
	print OUT ">$new_name\n$seq";
	}
close IN;
close OUT;