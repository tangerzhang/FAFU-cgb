#!/usr/bin/perl -w

my %infordb;        
open(IN, $ARGV[0]) or die"Usage: perl conver.pl promoter_info.txt promoter.seq\n";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($gene,$infor) = split(/\n/,$_,2);
	$gene =~ s/\s+//g;
	my @data = split(/\n/,$infor);
	foreach my $i(0..$#data){
		my @tmpdb = split(/\t/,$data[$i]);
		my $num = @tmpdb;
		next if($num < 5);
		$infordb{$gene}->{$tmpdb[2]} .= $tmpdb[0].",";
		}
	}
close IN;

my %lendb;
open(IN, $ARGV[1]) or die"Usage: perl conver.pl promoter_info.txt promoter.seq\n";
$/='>';
<IN>;
while(<IN>){
	chomp;
	my ($gene,$seq) = split(/\n/,$_,2);
	$seq =~ s/\s+//g;
	my $len = length $seq;
	$lendb{$gene} = $len;
	}
close IN;

open(OUT, "> dp_input.txt") or die"";
foreach my $gene(sort keys %infordb){
	my $p_len = $lendb{$gene};
	foreach my $posi (sort {$a<=>$b} keys %{$infordb{$gene}}){
		my $pro_posi = $posi - $p_len + 1; 
		print OUT "$gene	$posi	$pro_posi	$infordb{$gene}->{$posi}\n";
		}
	}
close OUT;