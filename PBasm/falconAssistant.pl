#!/usr/bin/perl -w

###Help me to decide length_cutoff and length_cutoff_pr parameters in FALCON 

my %lendb;
my $sum;
if( (!defined($ARGV[0])) or (!defined($ARGV[1]))){
	die "Usage: perl falconAssistant raw.fasta genome_size\n";

	}
open(IN, $ARGV[0]) or die"Usage: perl falconAssistant raw.fasta genome_size";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($name,$seq) = split(/\n/,$_,2);
	$seq =~ s/\s+//g;
	my $len = length $seq;
	$lendb{$name} = $len;
	$sum += $len;
	}
close IN;

my $genome_size = $ARGV[1];
if($genome_size =~ /\d+[M|m]/){
	$genome_size =~ s/[M|m]//g;
	$genome_size = $genome_size * 1000000;
}elsif($genome_size =~ /[G|g]/){
	$genome_size =~ s/[G|g]//g;
	$genome_size = $genome_size * 1000000000;
	}
my $count = 0;
my $coverage = 0;
foreach my $name (sort {$lendb{$b}<=>$lendb{$a}} keys %lendb){
	$count += $lendb{$name};
  $coverage = $count/$genome_size;
  if($coverage > 50){
  	print "length_cutoff for 50 x genome:	$lendb{$name}\n";
  	last;
  	}
	}

$count = 0;
$coverage = 0;
foreach my $name (sort {$lendb{$b}<=>$lendb{$a}} keys %lendb){
	$count += $lendb{$name};
  $coverage = $count/$genome_size;
  if($coverage > 30){
  	print "length_cutoff for 30 x genome:	$lendb{$name}\n";
  	last;
  	}
	}

$count = 0;
$coverage = 0;
foreach my $name (sort {$lendb{$b}<=>$lendb{$a}} keys %lendb){
	$count += $lendb{$name};
  $coverage = $count/$genome_size;
  if($coverage > 25){
  	print "length_cutoff for 25x genome:	$lendb{$name}\n";
  	last;
  	}
	}

$count = 0;
$coverage = 0;
foreach my $name (sort {$lendb{$b}<=>$lendb{$a}} keys %lendb){
	$count += $lendb{$name};
  $coverage = $count/$genome_size;
  if($coverage > 20){
  	print "length_cutoff for 20x genome:	$lendb{$name}\n";
  	last;
  	}
	}

$count = 0;
$coverage = 0;
foreach my $name (sort {$lendb{$b}<=>$lendb{$a}} keys %lendb){
	$count += $lendb{$name};
  $coverage = $count/$genome_size;
  if($coverage > 18){
  	print "length_cutoff for 18x genome:	$lendb{$name}\n";
  	last;
  	}
	}

$count = 0;
$coverage = 0;
foreach my $name (sort {$lendb{$b}<=>$lendb{$a}} keys %lendb){
	$count += $lendb{$name};
  $coverage = $count/$genome_size;
  if($coverage > 15){
  	print "length_cutoff for 15x genome:	$lendb{$name}\n";
  	last;
  	}
	}