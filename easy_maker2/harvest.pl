#!/usr/bin/perl -w

use Getopt::Std;
getopts "g:d:a:";


my $genome      = $opt_g;
my $EVM_loc     = $opt_d;
my $anno_out    = $opt_a;
if ((!defined $opt_g) || (!defined $opt_d) || (!defined $opt_a)) {
    die "************************************************************************
    Usage: perl $0 -g genome.fasta -d EVM location -a anno_out
      -h : help and usage.
      -g : genome file
      -d : location of EVidenceModeler, eg. ~/software/EVidenceModeler
      -a : anno_out dir, i.e. easy_maker2 output
************************************************************************\n";
}


my $sum_err = "";
while(my $part_dir = glob "$anno_out/part_*"){
	my $log_file = $part_dir."/part*_master_datastore_index.log";
	my $err_info = `grep \'FAILED\' $log_file`;
#	print "$part_dir failed\n" if(($err_info =~ /FAILED/) or ($err_info =~ /No such file or directory/));
	$sum_err .= $part_dir." failed\n" if(($err_info =~ /FAILED/) or ($err_info =~ /No such file or directory/));
	}

print "$sum_err\n";
die "Please re-run FAILED parts !!!\n" if($sum_err =~ /failed/);


system("rm -rf GFF");
mkdir GFF;
system("rm -rf FASTA");
mkdir FASTA;
$content = `find -name "*_index.log"`;
@linedb = split(/\n/,$content);

foreach $line(@linedb){
	@tmp = split(/\//,$line);
	$dir_name = $tmp[-1];
	$dir_name =~ s/_master_datastore_index.log//g;
	$cmd = "gff3_merge -g -n -d $line";
	system($cmd);
	$orig_gff = `ls *.all.gff`;
	$orig_gff =~ s/\s+//g;
	$rena_gff = $dir_name.".rename.gff";
	$cmd = "mv $orig_gff GFF/$rena_gff";
	system($cmd);
	
	}

$cmd = "cat GFF/*.rename.gff > GFF/contig.all.gff";
system($cmd);
$cmd = "maker_gff_sep_features_by_type.pl GFF/contig.all.gff";
system($cmd);
system("mv *.gff GFF/");
system("mv GFF/maker.gff ./");
open(OUT, "> FASTA/genome.fasta") or die"";
open(IN, $genome) or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	($gene,$seq) = split(/\n/,$_,2);
	$seq =~ s/\s+//g;
	print OUT ">$gene\n$seq\n";
	}
close IN;
close OUT;

###below need install EVidenceModeler
$cmd = "perl $EVM_loc/EvmUtils/gff3_file_to_proteins.pl GFF/contig.all.gff FASTA/genome.fasta CDS > FASTA/cds.fasta";
system($cmd);
$cmd = "perl $EVM_loc/EvmUtils/gff3_file_to_proteins.pl GFF/contig.all.gff  FASTA/genome.fasta prot > FASTA/protein.fasta";
system($cmd);
$cmd = "perl $EVM_loc/EvmUtils/gff3_file_to_proteins.pl GFF/contig.all.gff  FASTA/genome.fasta cDNA > FASTA/cDNA.fasta";
system($cmd);
$cmd = "perl $EVM_loc/EvmUtils/gff3_file_to_proteins.pl GFF/contig.all.gff  FASTA/genome.fasta gene > FASTA/gene.fasta";
system($cmd);

