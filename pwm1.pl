#!perl
use v5.20;
use RPi::WiringPi;
use RPi::Const qw(:all);
use Time::HiRes 'sleep';

my $pi = RPi::WiringPi->new;
my $pin = $pi->pin( 12 );
$pin->mode( PWM_OUT );

my $set = 0;
my $is_going_down = 0;
while(1) {
    $pin->pwm( $set );

    if( $is_going_down ) {
        if( $set > 0 ) {
            $set--;
        }
        else {
            $set++;
            $is_going_down = 0;
        }
    }
    else {
        if( $set < 1023 ) {
            $set++;
        }
        else {
            $set--;
            $is_going_down = 1;
        }
    }

    sleep 0.001;
}
