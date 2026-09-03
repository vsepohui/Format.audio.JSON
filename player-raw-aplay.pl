#!/usr/bin/perl

use 5.022;
use warnings;

use JSON::XS;

use lib 'lib';
use VectorTracer;

# Настройки аудио
my $sample_rate = 44100;  # Частота дискретизации (Гц)
my $frequency   = 440;    # Частота синусоиды (Нота Ля, Гц)
my $duration    = 3;      # Длительность звука (секунды)
my $volume      = 0.5;    # Громкость от 0.0 до 1.0

my $pi = 3.14159265358979;
my $max_amplitude = 32767 * $volume;


# Load file

my @input = <>;
my $s = join '', @input;

my $json = decode_json $s;

my $length = $json->{data}->{length};
my $f = $json->{data}->{f};


my $tracer = new VectorTracer(debug => 0);
my $node = $tracer->parse($f);

open(my $fh, '>', 'tmp-play.pcm');

# Render wave
my @s = ();
for my $x (0 .. $length * 44100) {
	# Формула синуса: sin(2 * pi * f * t)
    my $t = $x / $sample_rate;	
    
	# Render audio from formula
	my $signal = $tracer->trace(undef, $t);


    
    my $sample = $signal * $max_amplitude;
    
    # Округляем до целого числа
    my $int_sample = int($sample + 0.5);

    # Упаковываем в 16-битное знаковое целое (Little-Endian, шаблон 's')

    print $fh pack('s', $int_sample);
	
}

close $fh;

`aplay -f s16_le -r 44100 -c 1 tmp-play.pcm`;

unlink 'tmp-play.pcm';



1;
