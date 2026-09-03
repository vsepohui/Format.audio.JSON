#!/usr/bin/perl

use 5.022;
use warnings;

use JSON::XS;

use lib 'lib';
use VectorTracer;


# Constants
my $sample_rate 	= 44100;
my $volume      	= 0.5;
my $max_amplitude 	= 32767 * $volume;


# Load file from STDIN
my @input = <>;
my $s = join '', @input;

# Decode from JSON
my $json = decode_json $s;

my $data 	= $json->{data};

my $length 	= $data->{length};
my $f 		= $data->{f};


# Init f(x) parser
my $tracer = new VectorTracer(debug => 0);
# Parse f(x) function
my $node = $tracer->parse($f);

# Open tmp file to store PCM
open(my $fh, '>', 'tmp-play.pcm');

# Render wave
my @s = ();
for my $x (0 .. int ($length * $sample_rate)) {
    my $t = $x / $sample_rate;	
    
	# Render audio from funtion f(x)
	my $signal = $tracer->trace($node, $t);
   
    my $sample = $signal * $max_amplitude;
    my $int_sample = int($sample + 0.5);

    print $fh pack('s', $int_sample);
}
close $fh;

# Let's play audio by aplay utility
`aplay -f s16_le -r 44100 -c 1 tmp-play.pcm`;

# Remove tmp PCM file
unlink 'tmp-play.pcm';


1;
