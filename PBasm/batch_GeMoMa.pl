#!/usr/bin/perl -w

use Getopt::Std;
getopts "g:m:c:";


if ((!defined $opt_g)|| (!defined $opt_m) || (!defined $opt_c)) {
    die "************************************************************************
    Usage: perl $0 -g target.genome.fasta -m mapping.bam -c config.txt
      -h : help and usage.
      -g : target.genome.fasta
      -m : RNA-seq mapping bam file
      -c : species config file; format see the end of this script
************************************************************************\n";
}

my $pwd = `pwd`;
chomp $pwd;
system("ln -s $opt_g ./target.genome.fasta");
system("ln -s $opt_m ./RNAseq.mapping.bam");
system("rm -rf PBSscript/");
system("mkdir PBSscript");
my $count = 0;
open(OUT, "> cmd.list") or die"";
open(IN, $opt_c) or die"";
while(<IN>){
	chomp;
	next if(/#/);
	$count++;
	my @data    = split(/\s+/,$_);
	my $sp      = $data[0];
	my $gff     = $data[1];
	my $refSeq  = $data[2];
	my $outdir  = $sp."outdir";
	system("rm -rf $sp");
	system("mkdir $sp");
	my $cmd     = "sh ~/software/GeMoMa/run.sh ".$gff." ".$refSeq." ".$pwd."/target.genome.fasta ".$outdir." FR_UNSTRANDED ".$pwd."/RNAseq.mapping.bam";
	print OUT "$cmd\n";
	my $opb     = "run_".$count.".pbs";
	my $olog    = "log".$count.".txt";
	open(my $out, ">PBSscript/$opb") or die"";
  print $out "#!/bin/bash\n";
  print $out "#PBS -N GeMoMa\n";
  print $out "#PBS -o $olog\n";
  print $out "#PBS -e $olog\n";
  print $out "#PBS -q high\n";
  print $out "#PBS -j oe\n";
  print $out "#PBS -l nodes=1:ppn=8\n";
  print $out "cd \$PBS_O_WORKDIR/$sp\n";
  
  print $out "$cmd\n";
	close $out;
	}
close IN;
close OUT;

__DATA__
#Species	reference_anno	reference_genome
#Acyrthosiphon /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Acyrthosiphon.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Acyrthosiphongenome.fasta
#Apis /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Apis.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Apisgenome.fasta
#Bombyx /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Bombyx.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Bombyxgenome.fasta
#Danaus /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Danaus.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Danausgenome.fasta
#Diuraphis /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Diuraphis.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Diuraphisgenome.fasta
#Drosophila /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Drosophila.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Drosophilagenome.fasta
#Manduca /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Manduca.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Manducagenome.fasta
#Myzus /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Myzus.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Myzusgenome.fasta
#Rhodnius /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Rhodnius.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Rhodniusgenome.fasta
#Tribolium /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Tribolium.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Triboliumgenome.fasta
#Wasmannia /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Wasmannia.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Wasmanniagenome.fasta
#Zootermopsis /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Zootermopsis.gff3 /public/home/zhangxt/project/3_XLYC/GEMOMA/package/Zootermopsisgenome.fasta
