#!/usr/bin/perl -w

print "seqId	length	num_of_gc GC_percentage\n";
open(IN, $ARGV[0]) or die"Usage: perl countGC.pl input.fasta\n";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($name,$seq) = split(/\n/,$_,2);
	$seq =~ s/\s+//g;
	$seq = uc $seq;
	my $len = length $seq;
	my $num_gc = ($seq =~ tr/[GC]/[gc]/);
	my $per_gc = $num_gc/$len;
	$per_gc = sprintf("%.2f",$per_gc);
	print "$name	$len	$num_gc	$per_gc\n";
	}
close IN;