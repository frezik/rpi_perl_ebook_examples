#!perl
use v5.24;
use warnings;
use RPi::SPI;
use Time::HiRes 'sleep';

my $channel = 0;
my $speed = 1_000_000;


my $spi = RPi::SPI->new( $channel, $speed );
# Get chip ID, should be 0x60 for BME280, 0x58 for BMP580
my (@id) = $spi->rw( [ 0xD0, 0xD0 ], 2 );
say "ID: " . join( ', ', @id );

=for comment
# Set humidity control register, oversampling x1
$spi->rw( [ 0xF2, 0x01 ], 2 );
# Set sleep mode so we can set config reg
$spi->rw( [ 0xF3, 
    0b00000011, # Sleep mode bits
], 2 );
$spi->rw( [ 0xF5,
    0b00000000, # 0.5ms standby time, IIR filter off, 4-wire SPI mode
], 2 );
# Set temp and pressure oversample x1, and come out of sleep mode
$spi->rw( [ 0xF3,
    0b00100111, # Oversample x1 on temp and pressure, go to normal mode
], 2 );
=cut

sleep 0.5; # Wait a bit for device to settle


# Temp calibration data
my @t_cal = $spi->rw( [
    0x88,
    0x89,
    0x89,
    0x8A,
    0x8B,
    0x8C,
    0x8D,
], 7 );
say "Raw temp calibration data: " . join( ', ', @t_cal );

# Pressure calibration data
my @p_cal = $spi->rw( [
    0x8E,
    0x8F,
    0x90,
    0x91,
    0x92,
    0x93,
    0x94,
    0x95,
    0x96,
    0x97,
    0x98,
    0x99,
    0x9A,
    0x9B,
    0x9C,
    0x9D,
    0x9E,
    0x9F,
], 18 );
say "Raw pressure calibration data: " . join( ', ', @p_cal );

my @h_cal = $spi->rw( [
    0xA1,
    0xE1,
    0xE2,
    0xE3,
], 4 );
say "Raw humidity calibration data: " . join( ', ', @h_cal );


while(1) {
    my $read_ready = 0;
    while(! $read_ready) {
        my (@status) = $spi->rw([
            0xF3,
            0xF3,
        ], 2 );
        say "Raw status: @status";
        $read_ready = 1 if $status[0] & 0b0000_1000;
        sleep 0.1 if ! $read_ready;
    }

    my @out = (
        0xFA,
        0xFA,
        0xFB,
        0xFC,
    );
    my @in = $spi->rw( \@out, scalar(@out) );

    say "Raw temp data: " . join( ', ', @in );
    sleep 0.1;
}
