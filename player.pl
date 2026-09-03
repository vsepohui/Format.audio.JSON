#!/usr/bin/perl

use 5.022;
use warnings;

use Audio::PortAudio;
use JSON::XS;

use lib 'lib';
use VectorTracer;


# Init audio system
my $api = Audio::PortAudio::default_host_api();
my $device  = $api->default_output_device;

my $sample_rate = 44100;

my $stream = $device->open_write_stream(
	{ channel_count => 1 },
    $sample_rate,
    400,
    0
);

# Load file from STDIN
my @input = <>;
my $s = join '', @input;

# Decode input file from JSON
my $json = decode_json $s;

my $data 	= $json->{data};

my $length 	= $data->{length};
my $f 		= $data->{f};

# f(x) parser init
my $tracer = new VectorTracer(debug => 0);

# parse fuction f(x)
my $node = $tracer->parse($f);

# Render wave
my @s = ();
for my $x (0 .. int ($length * $sample_rate)) {
	# Render audio from formula
	push @s, $tracer->trace($node, $x / $sample_rate);
}

# Convert data
my $wave = pack "f*", @s;

# Let's play audio!
$stream->write($wave);

1;
