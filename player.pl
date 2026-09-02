#!/usr/bin/perl

#use 5.022;
use warnings;

use Audio::PortAudio;
use JSON::XS;

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



#for (0 .. 400) {
#    $stream->write($sine);
#}

1;
