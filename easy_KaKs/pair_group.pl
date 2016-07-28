#!/usr/bin/perl -w

my $count = 0;
my %infordb;
open(IN, $ARGV[0]) or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($gene,$seq) = split(/\n/,$_,2);
	$count++;
	$infordb{$count} = $gene;
	}
close IN;

my $num = keys %infordb;

foreach my $i(1..$num-1){
	foreach my $j(($i+1)..$num){
		next if($infordb{$i}	eq $infordb{$j});
		print "$infordb{$i}	$infordb{$j}\n";
		}
	}

