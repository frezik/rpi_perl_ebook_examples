#!perl
use v5.24;
use warnings;
use RPi::Serial;
use Time::HiRes 'sleep';

my $dev = '/dev/ttyAMA0';
my $baud = 9600;

my $serial = RPi::Serial->new( $dev, $baud );

while( 1 ) {
    my $num_bytes = $serial->avail;
    print $serial->gets( $num_bytes );
    sleep 0.1;
}

$serial->close;
