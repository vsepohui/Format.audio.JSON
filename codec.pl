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

	push @$x, $t / 44100;
	push @$y, $i;
		
	$t ++;
}

$y = [map {$_ / $max} @$y];

my $period = 1.0;
my $m = 5;
my $omega = 1;

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
	$f .= "+($ak*cos($i*$omega*x(1)))+($bk*sin($i*$omega*x(1)))";
}

$json->{data} = {f => $f, length => 1.3};


say encode_json $json;


1;
