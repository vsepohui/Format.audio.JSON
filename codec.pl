#!/usr/bin/perl

use 5.022;
use warnings;
use Math::Complex;
use JSON::XS;

my $input = $ARGV[0];
my $M_PI = pi;

die "Usage:\n$0 Input_file.mp3\n" unless $input;
die "Input file $input not found\n" unless -f $input;

my $out = `ffmpeg -loglevel quiet -i $input -f s16le -acodec pcm_s16le pipe:1`;

my @chunks = unpack("(a4)*", $out);


my $t = 0;
my $x = [];
my $y = [];

my $max = 0;

for (@chunks) {
	my ($left, $right) = unpack('s<s<', $_);
	
	my $i = $left;
		
	$max = 32767;

	push @$x, $t;
	push @$y, $i / $max;
		
	$t ++;
}

$y = [map {$_ / $max} @$y];

my $period = 5*44100;
my $m = 10;
my $omega = 880*3.1415;

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

chomp $data;

my @k = split /\n/, $data;


my $json = {format => 'audio', 'verion' => '0.1'};

my $f = $k[0];

for (my $i = 1 ; $i <= $m ; $i++) {
	my $ak = $k[2 * $i - 1];
	my $bk = $k[2 * $i];
	my $p = $i*$omega;
	$f .= "+($ak*cos(x(1)*$p))+($bk*sin(x(1)*$p))";
}

$json->{data} = {f => $f, length => scalar (@$x) / 44100};


say encode_json $json;


1;
