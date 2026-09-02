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

my $stream = $device->open_write_stream(
    {
        channel_count => 1,
    },
    44100,
    400,
    0
);

# Load file

my @input = <>;
my $s = join '', @input;

my $json = decode_json $s;

my $length = $json->{data}->{length};
my $f = $json->{data}->{f};


my $tracer = new VectorTracer(debug => 0);
my $node = $tracer->parse($f);

my @s = ();
for my $x (0 .. $length) {
	# Render audio from formula
	my $signal = $tracer->trace(undef, $x);
	
	# Limiter
	$signal = 1 if ($signal > 1);
	$signal = -1 if ($signal < -1);
	push @s, $signal;
}

my $wave = pack "f*", @s;



# Play
for (0 .. 400) {
	$stream->write($wave);
}




1;
