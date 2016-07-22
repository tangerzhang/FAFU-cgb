#!/usr/bin/perl -w

use Getopt::Std;
getopts "r:h:e:l:s:g:a:n:o:";
my $version = "easy_maker v 2.0";
my $help    = "
###################################################################################################
#                     
#     ######    #     ##### #     #      ##       ##    #     #    #  ######  ##^##    22222222
#     #        # #    #      #   #       # #     # #   # #    #  #    #       #   #           2
#     ######  #####   #####   ###        #  #   #  #  #####   ##      ######  #####    22222222
#     #      #     #      #    #         #   # #   # #     #  #  #    #       #    #   2
#     #######       # #####    #         #    #    ##       # #    #  ######  #     #  22222222
#
###################################################################################################
# Usage:

# perl $0 -r reference.fasta -h homolog.fasta -e est.fasta
#
# Required:
#   
#   -r    <string>      : reference genome for annotation
#   -h    <string>      : homolog protein file
#   -e    <strint>      : EST sequences or RNA-seq assembled contigs
#
# Optional:
# 
#   -l     <string>      : repeatmasker lib file, fasta format
#   -s     <string>      : snap HMM file, could get from snap training
#   -g     <string>      : GeneMark HMM file, could get from GeneMark training
#   -a     <string>      : Augustus training folder
#   -n     <string>      : number of submitted jobs, default 100
#   -o     <string>      : output dir, default anno_out
#########################################################################################

";
foreach my $i (0..$#ARGV) {
	  my $arg   = $ARGV[$i];
    if (($arg eq "-h") ||
        ($arg eq "--help") ||
        ($arg eq "-help")) {
        print "$help\n";
        exit(0);
    }

    if (($arg eq "-version") ||
        ($arg eq "--version") ||
        ($arg eq "-v")) {
        print "$version\n";
        exit(0);
    }
}

if( (!defined $opt_r) or (!defined $opt_h) or (!defined $opt_e)){
	die "$help\n";
	}
my $refseq    = $opt_r;
my $homolog   = $opt_h;
my $est       = $opt_e;
my $rmlib     = (defined $opt_l)?$opt_l:"";
my $snaphmm   = (defined $opt_s)?$opt_s:"";
my $augustus  = (defined $opt_a)?$opt_a:"";
my $gmhmm     = (defined $opt_g)?$opt_g:"";
my $num_of_jobs = (defined $opt_n)?$opt_n:100;
my $anno_out  = (defined $opt_o)?$opt_o:"anno_out";
my $pwd = $ENV{'PWD'};

system("rm -rf $anno_out");
system("mkdir $anno_out");
open(LOG, "> running.log") or die"";
######1. split reference into $num_of_jobs files
print LOG "1. split reference into $num_of_jobs files\n";
system("splitFA2parts -i $refseq -n $num_of_jobs");

system("rm -rf split_fasta");
system("mkdir split_fasta");
print LOG "mkdir split_fasta\n";
system("mv part*.fasta split_fasta/");
print LOG "mv part*.fasta split_fasta/ \n";
my $fasta_dir = $pwd."/split_fasta/";
######2. generating maker option files
print LOG "2. generating maker option files\n";
system("maker -CTL");
system("rm -rf opt_dir");
system("mkdir opt_dir");
my %maker_optdb = ();
my $count = 0;
open(IN, "maker_opts.ctl") or die"";
while(<IN>){
	chomp;
	$maker_optdb{$count++} = $_;
	}
close IN;

my %infordb; ###store the name of opt file
foreach my $i(1..$num_of_jobs){
	my $out_opt = "maker_opts.".$i.".ctl";
	$infordb{$i} = $out_opt;
	my $fasta   = "part_".$i.".fasta";
	open(my $out, ">opt_dir/$out_opt") or die"";
	foreach my $j (sort {$a<=>$b} keys %maker_optdb){
		my $line = $maker_optdb{$j};
		if($line =~ /genome= \#genome sequence \(fasta file or fasta embeded in GFF3 file\)/){
		    $line = "genome=split_fasta/$fasta	\#reset by easy maker";
		    print $out "$line\n";
		  }elsif($line =~ /est= \#set of ESTs or assembled mRNA-seq in fasta format/){
		  	$line = "est=$est	\#reset by easy maker";
		  	print $out "$line\n";
		  }elsif($line =~ /protein=  \#protein sequence file in fasta format /){
		  	$line = "protein=$homolog	\#reset by easy maker";
		  	print $out "$line\n";
		  }elsif($line =~ /rmlib= \#provide an organism specific repeat library in fasta format for RepeatMasker/){
		  	$line = "rmlib=$rmlib	\#reset by easy maker";
		  	print $out "$line\n";
		  }elsif($line =~ /snaphmm= \#SNAP HMM file/){
		  	$line = "snaphmm=$snaphmm	\#reset by easy maker";
		  	print $out "$line\n";
		  }elsif($line =~ /gmhmm= \#GeneMark HMM file/){
		  	$line = "gmhmm=$gmhmm	\#reset by easy maker";
		  	print $out "$line\n";
		  }elsif($line =~ /augustus_species= \#Augustus gene prediction species model/){
		  	$line = "augustus_species=$augustus	\#reset by easy maker";
		  	print $out "$line\n";
		  }elsif($line =~ /cpus=1 \#max number of cpus to use in BLAST and RepeatMasker /){
		  	$line = "cpus=2	\#reset by easy maker";
		  	print $out "$line\n";
		  }else{
		  	print $out "$line\n";
		  	}
		}
	close $out;
	}


######3. generating maker scripts
print LOG "3. generating maker scripts\n";
open(OUT, "> run_maker.sh") or die"";
print OUT "#!/bin/sh
#\$ -S /bin/bash
#\$ -pe mpi 2
#\$ -cwd

jobid=\$SGE_TASK_ID
if [ x\$jobid = x -o x\$jobid = xundefined -o x\$jobid = x0 ]; then
  jobid=\$1
fi
if [ x\$jobid = x ]; then
  echo Error: I need SGE_TASK_ID set, or a job index on the command line.
  exit 1
fi

";


foreach my $j(1..$num_of_jobs){
	print OUT "if [ \"\$jobid\" -eq \"$j\" ] ; then jn=\"$infordb{$j}\"\; fi\n";
	}
print OUT "maker_running \$jn \$jobid $anno_out\n";
#print OUT "maker \$jn -fix_nucleotides";
close OUT;


print "qsub -t 1-$num_of_jobs run_maker.sh\n";


#system("chmod +x maker_running");

close LOG;


