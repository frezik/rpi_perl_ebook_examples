#!perl
# Copyright (c) 2018  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
use v5.24;
use warnings;
use RPi::WiringPi;
use RPi::Const qw{ :all };

use constant SPI_CHANNEL => 0;


my $rpi = RPi::WiringPi->new;
my $spi = $rpi->spi( SPI_CHANNEL );

set_bandwidth_rate();
set_range();
enable_measurement();
run();


sub set_bandwidth_rate
{
    my @buf = ();
    $buf[0] = 0 << 7 # write bit
        | 1 << 6 # multi-byte bit
        | 0x2C; # rate address
    $buf[1] = 0 << 4 # low power mode
        | 0x0A; # 100Hz measurement rate
    $spi->rw( \@buf, scalar @buf );

    return;
}

sub set_range
{
    my @buf = ();
    $buf[0] = 0 << 7 # write bit
        | 1 << 6 # multi-byte bit
        | 0x31; # range address
    $buf[1] = 0 << 7 # self-test bit
        | 0 << 6 # spi bit (1 = three wire, 0 = four wire)
        | 0 << 5 # interupt bit
        | 0 << 4 # always 0 bit
        | 0 << 3 # full resolution bit
        | 0 << 2 # justify bit
        | 0 << 1 # range bit 1
        | 0 << 0; # range bit 0
    $spi->rw( \@buf, scalar @buf );

    return;
}

sub enable_measurement
{
    my @buf = ();
    $buf[0] = 0 << 7 # write bit
        | 1 << 6 # multi-byte bit
        | 0x2D; # power savings control address
    $buf[1] = 0 << 5 # link bit
        | 0 << 4 # auto sleep bit
        | 1 << 3 # measure bit
        | 0 << 2 # sleep bit
        | 0 << 1 # first wake bit
        | 0; # second wake bit
    $spi->rw( \@buf, scalar @buf );
    return;
}

sub run
{
    while(1) {
        my @buf = x_axis_read_buf();
        my @x_buf = $spi->rw( \@buf, scalar @buf );
        @buf = y_axis_read_buf();
        my @y_buf = $spi->rw( \@buf, scalar @buf );
        @buf = z_axis_read_buf();
        my @z_buf = $spi->rw( \@buf, scalar @buf );

        my $x = convert_data( @x_buf );
        my $y = convert_data( @y_buf );
        my $z = convert_data( @z_buf );
        say "($x, $y, $z)";
    }
}


sub x_axis_read_buf
{
    my @buf;
    $buf[0] = 0 << 7 # Read bit
        | 1 << 6 # Multibyte
        | 0x32; # x data 0
    $buf[1] = 0x33; # x data 1
    return @buf;
}

sub y_axis_read_buf
{
    my @buf;
    $buf[0] = 0 << 7 # Read bit
        | 1 << 6 # Multibyte
        | 0x34; # y data 0
    $buf[1] = 0x35; # y data 1
    return @buf;
}

sub z_axis_read_buf
{
    my @buf;
    $buf[0] = 0 << 7 # Read bit
        | 1 << 6 # Multibyte
        | 0x36; # z data 0
    $buf[1] = 0x37; # z data 1
    return @buf;
}

sub convert_data
{
    my (@buf) = @_;
    my $data = $buf[0] << 8
        | $buf[1];
    return $data;
}
