#!/usr/bin/perl -w

system("rm -rf script");
system("mkdir script");
system("rm -rf log");
system("mkdir log");
my $count=0;
open(IN, "cmd.list") or die"";
while(<IN>){
	chomp;
	$count++;
	my $opbs = "script.".$count.".pbs";
	my $olog = "log/log.".$count.".txt";
	my $cmd = "maker_running maker_opts.".$count.".ctl ".$count." anno_out";
	open(my $out, ">script/$opbs") or die"";
	print $out "#!/bin/bash -x\n";
	print $out "#PBS -N maker\n";
	print $out "#PBS -o $olog\n";
	print $out "#PBS -e $olog\n";
	print $out "#PBS -q high\n";
	print $out "#PBS -j oe\n";
	print $out "#PBS -l nodes=1:ppn=4\n";
	print $out "cd \$PBS_O_WORKDIR\n";
	print $out "$cmd\n";
	close $out;
	
	}
close IN;
