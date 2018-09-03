#!perl
use v5.24;
use warnings;
use GPS::NMEA;

my $dev = '/dev/ttyAMA0';
my $baud = 9600;


my $nmea = GPS::NMEA->new(
    Port => $dev,
    Baud => $baud,
);
while(1) {
    my($ns,$lat,$ew,$lon) = $nmea->get_position;
    $lat = int($lat) + ($lat - int($lat)) * 1.66666667;
    $lon = int($lon) + ($lon - int($lon)) * 1.66666667;

    say "($ns,$lat,$ew,$lon)";
}
