#!/usr/bin/perl

use 5.022;
use warnings;
use Math::Complex;
use JSON::XS;

my $input = $ARGV[0];
my $M_PI = pi;


#my $out = `ffmpeg -i $input -f f32le pipe:1`;

#my @chunks = unpack("(A4)*", $out);

my $x = [0, 	1,		2, 		3,		4,		5];
my $y = [0.5, 	1.2, 	0.1, 	-0.8, 	-0.2,	0.6];

my $period = 5;
my $m = 2;

# Interpolate

open my $tmp, '>tmp.1';
say $tmp $period;
say $tmp $m;
say $tmp scalar @$x;
for (0..scalar(@$x)-1) {
	say $tmp $x->[$_];
	say $tmp $y->[$_];
}
close $tmp;

my $data = `./interpolator < ./tmp.1`;

unlink 'tmp.1';

say $data;


#my $num = 0;
#for my $c (@chunks) {
#	my $s = unpack('f', $c);
#	next unless defined $s;
#	push @$x, $num / 400;
#	push @$y, $s;
#
#	$num ++;
#}



1;
