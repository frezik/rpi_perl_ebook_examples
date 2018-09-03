#!perl
use v5.20;
use RPi::WiringPi;
use RPi::Const qw(:all);
use Time::HiRes 'sleep';

use constant START => 50;
use constant STEP => 100;
use constant LIMIT => 250;

my $pi = RPi::WiringPi->new;
my $pin = $pi->servo( 18 );

say "Hit [Enter] to move servo";
my $set = START;
while(1) {
    say "Setting pulse to $set";
    $pin->pwm( $set );

    my $throwaway = <>;
    $set += STEP;
    $set = START if $set > LIMIT;
}
