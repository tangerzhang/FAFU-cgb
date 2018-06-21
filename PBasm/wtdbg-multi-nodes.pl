#!/usr/bin/perl -w

use Getopt::Std;
getopts "n:r:";


if ((!defined $opt_n)|| (!defined $opt_r)) {
    die "************************************************************************
    Usage: perl $0 -n num_of_jobs -r input.reads.fa
      -h : help and usage.
      -n : number of jobs
      -r : input.reads.fa
************************************************************************\n";
}

my $N   = $opt_n;
system("ln -s $opt_r ./rds.fa");

system("split_seqs_2.pl $N rds.fa");

open(OUT, "> run_wtdbg.sh") or die"";
my $wtdbg_cmd = "wtdbg-1.2.8 -t 16 -i rds.fa \\";
system("rm -rf script");
system("mkdir script");
my $id = "";
foreach my $i(1..$N){
	foreach my $j (1..$N){
		$id      = $i."-".$j;
		my $opbs = "script_".$id.".pbs";
		my $olog = "log.".$id.".txt";
		my $osh  = "run_".$id.".sh";
		my $cmd  = "kbm-1.2.8 -t 20 -d rds.fa.shuffle".$i." -i rds.fa.shuffle".$j." -c -fo ".$id.".kbmap";
		open(my $out, ">script/$opbs") or die"";
		print $out "#!/bin/bash -x\n";
		print $out "#PBS -N wtdbg\n";
		print $out "#PBS -o $olog\n";
		print $out "#PBS -e $olog\n";
		print $out "#PBS -q high\n";
		print $out "#PBS -j oe\n";
		print $out "#PBS -l nodes=1:ppn=20\n";
		print $out "cd \$PBS_O_WORKDIR\n";
		print $out "$cmd\n";
		close $out;
		
		open($out, ">script/$osh") or die"";
		print $out "$cmd\n";
		close $out;
		$wtdbg_cmd .= "\n --load-alignments ".$id.".kbmap \\";			
		}
	

	}


$wtdbg_cmd .= "\n -fo dbg --rescue-low-cov-edges \\\n";

print OUT "$wtdbg_cmd\n";
print OUT "wtdbg-cns -t 16 -f -i dbg.ctg.lay -o dbg.ctg.lay.fa\n";

close OUT;

print "1. batch run scripts in script/\n";
print "2. run wtdbg and wtdbg-cns in run_wtdbg.sh\n";

