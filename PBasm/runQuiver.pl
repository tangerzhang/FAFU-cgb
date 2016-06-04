#!/usr/bin/perl -w

use Getopt::Std;
getopts "i:d:t:";


if ((!defined $opt_i)|| (!defined $opt_d) ) {
    die "************************************************************************
    Usage: perl runQuiver.pl -i pb.asm.fasta -d baxh5 folder -t threads
      -h : help and usage.
      -i : pacbio assembly fasta file
      -d : directory containing all bax.h5 files
      -t : threads, default 20
************************************************************************\n";
}else{
  print "************************************************************************\n";
  print "Version 1.1\n";
  print "Copyright to Tanger, tanger.zhang\@gmail.com\n";
  print "RUNNING...\n";
  print "************************************************************************\n";
        
        }

my $dir     = $opt_d;
my $pbctg   = $opt_i;
my $threads = (defined $opt_t)?$opt_t:20;

my %infordb;
while(my $file = glob "$dir/*.1.bax.h5"){
	my $sample = $file;
	$sample =~ s/.1.bax.h5//g;
	$infordb{$sample}++;
	}

system("rm -rf input");
system("mkdir input");
system("rm -rf outcmp");
system("mkdir outcmp");
system("rm -rf script");
system("mkdir script");
system("rm -rf tmp");
system("mkdir tmp");

my $count = 0;
foreach my $sample(sort keys %infordb){
	$count++;
	my $output = "input.".$count.".fofn";
	my $bax1 = $sample.".1.bax.h5";
	my $bax2 = $sample.".2.bax.h5";
	my $bax3 = $sample.".3.bax.h5";
	open(my $out, ">input/$output") or die"";
	print $out "$bax1\n$bax2\n$bax3";
	close $out;
	}

open(OUT, ">script.sh") or die"";
print OUT "#!/bin/bash\n\n";
while(my $input = glob "input/*.fofn"){
  my $id = $input;
  $id =~ s/input\/input\.//g;
  $id =~ s/\.fofn//g;
	my $out_cmp = "outcmp/out_".$id.".cmp.h5";
	my $cmd = "pbalign --minLength 1000 --nproc $threads $input $pbctg $out_cmp --forQuiver";
	print OUT "$cmd\n";
	my $qsub = "script.".$id.".pbs";
	open(my $out, ">script/$qsub") or die"";
	my $name = "run_".$id;
	print $out "#!/bin/bash
#\$ -N $name
#\$ -S /bin/bash
#\$ -cwd
#\$ -j y
#\$ -pe make $threads
";
   print $out "$cmd\n";
   close $out;
	}

close OUT;

open(QO, "> quiver.sh") or die"";
print QO "
#!/bin/bash
#\$ -N quiver
#\$ -S /bin/bash
#\$ -cwd
#\$ -j y
#\$ -pe make 20

cmph5tools.py merge --outFile out_all.cmp.h5 outcmp/*
cmph5tools.py sort --deep out_all.cmp.h5 --tmpDir ./tmp
quiver -j 20 out_all.cmp.h5 -r $pbctg -o variants.gff -o consensus.fasta\n";
close QO;




print "submit your job in SGE:\nqsub script/script.x.pbs\n";
print "Or submit your job in single node: \nsh script.sh\n";
