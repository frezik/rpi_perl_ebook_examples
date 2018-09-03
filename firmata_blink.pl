#!perl
use v5.24;
use warnings;
use Device::Firmata::Constants qw{ :all };
use Device::Firmata;
use Device::SerialPort;

my $led_pin = 13;
my $usb_dev = '/dev/ttyACM0';

my $dev = Device::Firmata->open( $usb_dev )
    or die "Could not connect to Firmata\n";

$dev->pin_mode( $led_pin => PIN_OUTPUT );
my $setting = 0;
say "Blinking . . . ";
while(1) {
    $setting = ! $setting;
    $dev->digital_write( $led_pin => $setting );
    sleep 1;
}
