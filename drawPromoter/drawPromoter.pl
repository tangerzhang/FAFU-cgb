#!/usr/bin/perl -w

use strict;
use SVG;



my $svg = SVG->new(
   width  => 5000,
   height => 5000,
);

my $start_x = 30;
my $start_y = 50;
my $bin = 20;
my $size = 2;
my $family = "Arial";
my %infordb;
my %featuredb;
open(IN, "dp_input.txt") or die"";
while(<IN>){
	chomp;
	my @data = split(/\s+/,$_);
	$data[3] =~ s/,//g;
	$infordb{$data[0]}->{$data[2]} = $data[3];
	$featuredb{$data[3]}->{'count'}++;
	}
close IN;

###0. plot shapes for each kind of cis-element
my @shape = qw/circle ellipse rectangle diamond fiveSide SixSide/;
my @color;
while(<DATA>){
	chomp;
	push @color, $_;
	}
my $num_c = @color;
my $num_s = @shape;
my $s_x   = $start_x;
my $s_y   = $start_y;
foreach my $cis (sort keys %featuredb){
	my $color  = $color[int rand $num_c];
	my $shape  = $shape[int rand $num_s];
	$featuredb{$cis}->{'color'} = $color;
	$featuredb{$cis}->{'shape'} = $shape;
	$s_x += 10 * $bin;
#	print "$cis	\n$c	\n$s\n";
	if($shape eq "circle"){
		my $cx = $s_x;
		my $cy = $s_y;
		&circle(-cx=>$cx,-cy=>$cy,-color=>$color,-text=>$cis);
	}elsif($shape eq "rectangle"){
		my $rx     = $s_x;
		my $ry     = $s_y-1.5*$bin;
		&rect(-rx=>$rx,-ry=>$ry,-color=>$color,-text=>$cis);
	}elsif($shape eq "diamond"){
		my $dx1    = $s_x; 
		my $dy1    = $s_y;
    &diamond(-x1=>$dx1,-y1=>$dy1,-color=>$color,-text=>$cis);
	}elsif($shape eq "fiveSide"){
		my $x1     = $s_x; 
		my $y1     = $s_y;
		&fiveSide(-x1=>$x1,-y1=>$y1,-color=>$color,-text=>$cis);
	}elsif($shape eq "SixSide"){
		my $x1     = $s_x;
		my $y1     = $s_y;
		&sixSide(-x1=>$x1,-y1=>$y1,-color=>$color,-text=>$cis);
	}elsif($shape eq "ellipse"){
		my $cx     = $s_x ;
		my $cy     = $s_y;
    &ellipse(-cx=>$cx,-cy=>$cy,-color=>$color,-text=>$cis);
		}
	}


###1. plot features for each gene
#my @shape = qw/circle ellipse rectangle diamond fiveSide SixSide/;
foreach my $gene(sort keys %infordb){
	$s_x = $start_x;
  $s_y = $s_y + 10*$bin;
  my $m_x = $s_x;
  my $m_y = $s_y;
  $svg->text('x',5, 'y',$s_y-2*$bin,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$gene);
  $svg->line('x1',$start_x,'y1',$s_y,'x2',5000,'y2',$s_y,'stroke','black','stroke-width',2);
  foreach my $posi(sort {$a<=>$b} keys %{$infordb{$gene}}){
  	my $cis   = $infordb{$gene}->{$posi};
  	my $color = $featuredb{$cis}->{'color'};
  	my $shape = $featuredb{$cis}->{'shape'};
  	$m_x     += 8*$bin;
  	$svg->text('x',$m_x, 'y',$m_y-2*$bin,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$posi);
  	if($shape eq "circle"){
  		my $p_x = $m_x + 2*$bin;
  		my $p_y = $m_y;
  		&circle(-cx=>$p_x,-cy=>$p_y,-color=>$color,-text=>$cis);
  	}elsif($shape eq "rectangle"){
  		my $p_x = $m_x;
  		my $p_y = $m_y - 1.5*$bin;
  		&rect(-rx=>$p_x,-ry=>$p_y,-color=>$color,-text=>$cis);
  	}elsif($shape eq "diamond"){
  		&diamond(-x1=>$m_x,-y1=>$m_y,-color=>$color,-text=>$cis);
  	}elsif($shape eq "fiveSide"){
  		my $p_x = $m_x;
  		my $p_y = $m_y - $bin;
  		&fiveSide(-x1=>$p_x,-y1=>$p_y,-color=>$color,-text=>$cis);
  	}elsif($shape eq "SixSide"){
  		&sixSide(-x1=>$m_x,-y1=>$m_y,-color=>$color,-text=>$cis);
  	}elsif($shape eq "ellipse"){
  		my $p_x = $m_x + $bin;
  		my $p_y = $m_y;
  		&ellipse(-cx=>$p_x,-cy=>$p_y,-color=>$color,-text=>$cis);
  		}
  	}
  
	}


print $svg->xmlify;


sub ellipse{
	my %params    = @_;
	my $cx        = $params{-cx};
	my $cy        = $params{-cy};
	my $rx        = 2 * $bin;
	my $ry        = $bin;
	my $tx        = $cx;
	my $ty        = $cy;
	my $color     = $params{-color};
	my $text      = $params{-text};
	$svg->ellipse('cx',$cx,'cy',$cy,'rx',$rx,'ry',$ry,'stroke',$color,'fill',$color);
	$svg->text('x',$tx, 'y',$ty,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$text);	
	}

sub sixSide{
	my %params    = @_;
	my $x1        = $params{-x1};
	my $y1        = $params{-y1};
	my $x2        = $x1 + $bin;
	my $x3        = $x1 + 5*$bin;
	my $x4        = $x1 + 6*$bin;
	my $x5        = $x3;
	my $x6        = $x2;
	my $y2        = $y1 - $bin;
	my $y3        = $y2;
	my $y4        = $y1;
	my $y5        = $y1 + $bin;
	my $y6        = $y5;
	my $tx        = $x2;
	my $ty        = $y1;
	my $color     = $params{-color};
	my $text      = $params{-text};
	my $path      = $svg->get_path(
	   x          => [$x1,$x2,$x3,$x4,$x5,$x6],
	   y          => [$y1,$y2,$y3,$y4,$y5,$y6],
	   -type      => 'polygon');
	$svg->polygon(
	  %$path,
	  style => {
	  	'fill'            => $color,
	  	'stroke'          => $color,
	  	'stroke-width'    => 0,
      'stroke-opacity'  => 1,
      'fill-opacity'    => 1,
	  	},
	  );
	$svg->text('x',$tx, 'y',$ty,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$text);	 
	}

sub fiveSide{
	my %params    = @_;
	my $x1        = $params{-x1};
	my $y1        = $params{-y1};
	my $x2        = $x1 + 3*$bin;
	my $x3        = $x1 + 6*$bin;
	my $x4        = $x3 - $bin/2;
	my $x5        = $x1 + $bin/2;
	my $y2        = $y1 - $bin;
	my $y3        = $y1;
	my $y4        = $y1 + 2*$bin;
	my $y5        = $y1 + 2*$bin;
	my $tx        = $x1 + $bin;
	my $ty        = $y1;
	my $color     = $params{-color};
	my $text      = $params{-text};
	my $path      = $svg->get_path(
	   x          => [$x1,$x2,$x3,$x4,$x5],
	   y          => [$y1,$y2,$y3,$y4,$y5],
	   -type      => 'polygon');
	$svg->polygon(
	  %$path,
	  style => {
	  	'fill'            => $color,
	  	'stroke'          => $color,
	  	'stroke-width'    => 0,
      'stroke-opacity'  => 1,
      'fill-opacity'    => 1,
	  	},
	  );
	$svg->text('x',$tx, 'y',$ty,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$text);
	 
	}


sub diamond{
	my %params    = @_;
	my $x1        = $params{-x1};
	my $x2        = $x1 + 3*$bin;
	my $x3        = $x1 + 6*$bin;
	my $x4        = $x2;
	my $y1        = $params{-y1};
	my $y2        = $y1 - 1.5*$bin;
	my $y3        = $y1;
	my $y4        = $y1 + 1.5*$bin;
	my $tx        = $x1 + $bin;
	my $ty        = $y1;
	my $color     = $params{-color};
	my $text      = $params{-text};
	my $path      = $svg->get_path(
	   x          => [$x1,$x2,$x3,$x4],
	   y          => [$y1,$y2,$y3,$y4],
	   -type      => 'polygon');
	$svg->polygon(
	  %$path,
	  style => {
	  	'fill'            => $color,
	  	'stroke'          => $color,
	  	'stroke-width'    => 0,
      'stroke-opacity'  => 1,
      'fill-opacity'    => 1,
	  	},
	  );
	$svg->text('x',$tx, 'y',$ty,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$text);
	}


sub rect{
	my %params    = @_;
	my $rx        = $params{-rx};
	my $ry        = $params{-ry};
	my $width     = 6 * $bin;
	my $height    = 3 * $bin;
	my $color     = $params{-color};
	my $tx        = $rx + $bin;
	my $ty        = $ry + 2*$bin;
	my $text      = $params{-text};
	$svg->rect('x',$rx, 'y',$ry,'width',$width,'height',$height,'stroke',$color,'fill',$color);
	$svg->text('x',$tx, 'y',$ty,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$text);
	}


sub circle{
	my %params    = @_;
	my $cx     = $params{-cx};
	my $cy     = $params{-cy};
  my $color  = $params{-color};
  my $r      = 2 * $bin;
  my $tx     = $cx-$bin;
  my $ty     = $cy-$bin;
  my $text   = $params{-text};
	$svg->circle('cx',$cx,'cy',$cy,'r',$r,'stroke',$color,'fill',$color);
	$svg->text('x',$tx,'y',$ty,'stroke','black','font-family',$family,'font-size',$size,'-cdata',$text);	
	}

__DATA__
darkred
black
darkblue
darkgreen
yellow
darkmagenta
darkgoldenrod
deeppink
navy
mediumblue
blue
green
teal
darkcyan
deepskyblue
darkturquoise
mediumspringgreen
lime
springgreen
aqua
midnightblue
dodgerblue
lightseagreen
forestgreen
seagreen
darkslategray
limegreen
mediumseagreen
turquoise
royalblue
steelblue
darkslateblue
mediumturquoise
indigo
darkolivegreen
cadetblue
cornflowerblue
mediumaquamarine
dimgray
slateblue
olivedrab
slategray
lightslategray
mediumslateblue
lawngreen
chartreuse
aquamarine
maroon
purple
olive
gray
skyblue
lightskyblue
blueviolet
saddlebrown
darkseagreen
lightgreen
mediumpurple
darkviolet
palegreen
darkorchid
sienna
brown
darkgray
lightblue
greenyellow
paleturquoise
lightsteelblue
firebrick
mediumorchid
rosybrown
darkkhaki
silver
mediumvioletred
indianred
peru
chocolate
tan
lightgray
thistle
orchid
goldenrod
palevioletred
crimson
gainsboro
plum
burlywood
lightcyan
lavender
darksalmon
violet
palegoldenrod
lightcoral
khaki
aliceblue
honeydew
azure
sandybrown
wheat
beige
whitesmoke
mintcream
ghostwhite
salmon
antiquewhite
linen
lightgoldenrodyellow
oldlace
red
fuchsia
orangered
tomato
hotpink
coral
darkorange
lightsalmon
orange
lightpink
pink
gold
peachpuff
navajowhite
moccasin
bisque
mistyrose
blanchedalmond
papayawhip
lavenderblush
seashell
cornsilk
lemonchiffon
floralwhite
lightyellow