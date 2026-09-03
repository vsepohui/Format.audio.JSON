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

use Data::Dumper;

my $max = 0;

for (@chunks) {
	my ($left, $right) = unpack('s<s<', $_);
	#say "$left -- $right";
	#die $left;
	
	my $i = $left;
		
	$max = 32_767;
	#warn $i;

	#$i = 1 if $i > 1;
	#$i = -1 if $i < -1;
		
	#warn $i;
	
	$i = '0' if $i eq 'NaN';
		
	push @$x, $t / 44000;
	push @$y, $i // 0;
		
	$t ++;
}

#my @t = sort {abs $a <=> abs $b} @$y;
#warn $t[-1];

#warn $max;


$y = [map {$_ / $max} @$y];

#@t = sort {abs $a <=> abs $b} @$y;
#die $t[-1];

#use Data::Dumper;
#say Dumper $y;
#exit;




my $period = 1;
my $m = 40;
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
	$f .= "+($ak*cos($i*$omega*x(1))+($bk*sin($i*$omega*x(1)))";
}

$json->{data} = {f => $f, length => 130};


say encode_json $json;


1;
