#!perl
use v5.14;
use warnings;
use RPi::WiringPi;
use RPi::Const qw{ :all };

my $rpi = RPi::WiringPi->new;
my $tmp102 = $rpi->i2c( 0x48 );

while(1) {
    my $temp = $tmp102->read_bytes( 2, 0x00 );
    say "${temp}C";
    sleep 1;
}
