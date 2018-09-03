#!perl
use v5.20;
use RPi::WiringPi;
use RPi::Const qw(:all);
use Time::HiRes 'sleep';

my $pi = RPi::WiringPi->new;
my $pin = $pi->pin( 2 );
$pin->mode( INPUT );

while(1) {
    say $pin->read ? "High" : "Low";
    sleep 0.1;
}
