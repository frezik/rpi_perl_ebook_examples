#!perl
use v5.24;
use warnings;
use RPi::WiringPi;
use RPi::Const qw{ :all };

my $rpi = RPi::WiringPi->new;
my $tmp102 = $rpi->i2c( 0x48 );
