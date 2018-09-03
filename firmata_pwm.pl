#!perl
use v5.24;
use warnings;
use Device::Firmata::Constants qw{ :all };
use Device::Firmata;
use Device::SerialPort;
use Math::Round 'round';
use Time::HiRes 'sleep';


my @pwm_pins = qw{ 3 5 6 9 10 11 };
my @gradient = reverse( 0, 0, 0, map {
    round( log($_) * 255 )
} 1 .. 3 );
my $usb_dev = '/dev/ttyACM0';


my $dev = Device::Firmata->open( $usb_dev )
    or die "Could not connect to Firmata\n";
$dev->pin_mode( $_ => PIN_PWM ) for @pwm_pins;


say "Lighting . . . ";
while(1) {
    $dev->analog_write( $pwm_pins[$_] => $gradient[$_] )
        for 0 .. $#pwm_pins;

    @gradient = @gradient[ $#gradient, 0 .. ($#gradient - 1) ];

    sleep 0.4;
}
