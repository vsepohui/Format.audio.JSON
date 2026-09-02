#!/usr/bin/perl

use 5.022;
use warnings;
use Math::Complex;
use JSON::XS;

my $input = $ARGV[0];
my $M_PI = pi;

die "Usage:\n$0 Input_file.mp3\n" unless $input;
die "Input file $input not found\n" unless -f $input;

my $out = `ffmpeg -hide_banner -loglevel error -i $input -f f32le pipe:1`;

my @chunks = unpack("(A4)*", $out);


my $t = 0;
my $x = [];
my $y = [];

use Data::Dumper;

for (@chunks) {
	next unless defined $_;
	my @l = map {sprintf("%X", $_)} map {ord $_} unpack("(A1)*", $_);  
	my $hex = join '', @l;
	my $i = unpack("d<", pack("H*", hex $hex));
	
	push @$x, $t / 4000.0;
	push @$y, $i // 0;
	
	$t ++;
}


my $period = 5;
my $m = 20;
my $omega = 2.0 * $M_PI / $period;

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
	$f .= "+($ak*cos($i*$omega*x(1))+($bk*sin($i*$omega*x(1))";
}

$json->{data} = {f => $f, length => 500};


say encode_json $json;


1;
