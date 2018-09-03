#!perl
use v5.24;
use warnings;
use Device::WebIO;
use Device::WebIO::RaspberryPi;
use Device::WebIO::Firmata;
use Time::HiRes 'sleep';

my $webio = Device::WebIO->new;
my $rpi = Device::WebIO::RaspberryPi->new;
my $firmata = Device::WebIO::Firmata->new({
    port => '/dev/ttyACM0',
});

$webio->register( 'rpi', $rpi );
$webio->register( 'firmata', $firmata );

$webio->set_as_output( 'rpi', 2 );
$webio->set_as_output( 'firmata', 13 );

say "Running . . . ";
my $is_set_on_rpi = 1;
while(1) {
    $webio->digital_output( 'rpi', 2, $is_set_on_rpi );
    $webio->digital_output( 'firmata', 13, ! $is_set_on_rpi );

    $is_set_on_rpi = ! $is_set_on_rpi;
    sleep 0.5;
}
