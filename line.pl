#!perl
use v5.20;
use RPi::SPI;
use Time::HiRes 'sleep';

use constant INTENSITY_REG => 0b0000_1010;
use constant DECODE_MODE_REG => 0b0000_1001;
use constant SCAN_LIMIT_REG => 0b0000_1011;
use constant SHUTDOWN_REG => 0b0000_1100;


my $spi = RPi::SPI->new( 0 );

say "Setting intensity";
my @buf = ( INTENSITY_REG, 0b0000_0010 ); # 5/32 duty cycle
$spi->rw( \@buf, scalar @buf );

say "Setting no-decode mode";
@buf = ( DECODE_MODE_REG, 0 ); # No decode mode
$spi->rw( \@buf, scalar @buf );

say "Set scan for all digits";
@buf = ( SCAN_LIMIT_REG, 0b0000_0111 );
$spi->rw( \@buf, scalar @buf );

say "Coming out of shutdown";
@buf = ( SHUTDOWN_REG, 0b0000_0001 );
$spi->rw( \@buf, scalar @buf );


say "Ready";
my $line = 1;
while( 1 ) {
    say "Setting line $line";
    for my $digit (1 .. 8) {
        @buf = ( $digit, $line );
        $spi->rw( \@buf, scalar @buf );
    }

    $line <<= 1;
    $line = 1 if $line >= 129;
    sleep 0.1;
}
