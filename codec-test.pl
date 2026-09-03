#!/usr/bin/perl

use 5.022;
use warnings;
use Math::Complex;
use JSON::XS;

my $input = $ARGV[0];
my $M_PI = pi;

# Настройки аудио
my $sample_rate = 44100;  # Частота дискретизации (Гц)
my $frequency   = 440;    # Частота синусоиды (Нота Ля, Гц)
my $duration    = 3;      # Длительность звука (секунды)
my $volume      = 0.5;    # Громкость от 0.0 до 1.0

my $pi = 3.14159265358979;
my $max_amplitude = 32767 * $volume;


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
	push @$y, $i / $max;
		
	$t ++;
}

open(my $fh, '>', 'tmp-play.pcm');

my @s = ();

my $x_2 = 0;
for (@$y) {
    my $t = $x_2 / $sample_rate;	
    
	my $signal = $_;
   
    my $sample = $signal * $max_amplitude;
    
    # Округляем до целого числа
    my $int_sample = int($sample + 0.5);

    # Упаковываем в 16-битное знаковое целое (Little-Endian, шаблон 's')

    print $fh pack('s', $int_sample);
    
    $x_2 ++;
	
}

close $fh;

`aplay -f s16_le -r 44100 -c 1 tmp-play.pcm`;

unlink 'tmp-play.pcm';


1;
