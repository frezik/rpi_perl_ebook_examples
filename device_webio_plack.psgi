#!perl
use v5.24;
use warnings;
use Dancer;
use Device::WebIO::Dancer;
use Device::WebIO;
use Device::WebIO::RaspberryPi;
use Device::WebIO::Firmata;
use Plack::Builder;

use constant DOCROOT => '/home/pi/Device-WebIO-Dancer-0.004/public';


my $webio = Device::WebIO->new;
my $rpi = Device::WebIO::RaspberryPi->new;
my $firmata = Device::WebIO::Firmata->new({
    port => '/dev/ttyACM0',
});

$webio->register( 'rpi', $rpi );
$webio->register( 'firmata', $firmata );

Device::WebIO::Dancer::init( $webio, 'rpi', DOCROOT );

builder {
    set log => 'info';
    set show_errors => 1;
    set public => DOCROOT;

    dance;
};
