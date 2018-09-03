#!perl
use v5.20;
use RPi::WiringPi;
use RPi::Const qw(:all);

my $pi = RPi::WiringPi->new;
my $pin = $pi->pin( 2 );
$pin->mode( OUTPUT );

my $set = 0;
while(1) {
    $pin->write( $set );
    $set = ! $set;
    sleep 1;
}
