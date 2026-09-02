#!/usr/bin/perl

use 5.022;
use warnings;
use Math::Complex;
use JSON::XS;

my $input = $ARGV[0];
my $M_PI = pi;

die "Usage:\n$0 Input_file.mp3\n" unless $input;
die "Input file $input not found\n" unless -f $input;

my $out = `ffmpeg -i $input -f f32le pipe:1`;

my @chunks = unpack("(A4)*", $out);

my $t = 0;
my $x = [];
my $y = [];

for (@chunks) {
	next unless defined $_;
	push @$x, $t / 400;
	push @$y, $_;
	
	$t ++;
}

use Data::Dumper;

my $period = 5;
my $m = 50;

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
