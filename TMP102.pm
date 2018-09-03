package TMP102;
use v2.20;
use warnings;

use constant CELSIUS_FACTOR => 0.0625;

sub convert_temp
{
    my ($bits, $binary_temp) = @_;
    $binary_temp <<= 8;
    $binary_temp = $binary_temp >> 4;

    warn "# Bin temp [created]: $binary_temp";
    my $temp = $binary_temp / 16;

    return $temp;
}

sub convert_temp_premade
{
    my ($bits, $temp) = @_;
    $temp <<= 8;

    # The TMP102 temperature registers are left justified, correctly
    # right justify them
    $temp = $temp >> 4;

    # test for negative numbers
    if ( $temp & ( 1 << 11 ) ) {
warn "# Is negative [premade]";
        # twos compliment plus one, per the docs
        $temp = ~$temp + 1;

        # keep only our 12 bits
        $temp &= 0xfff;

        # negative
        $temp *= -1;
    }

    # convert to a celsius temp value
    warn "# Bin temp [premade]: $temp";
    $temp = $temp / 16;

    return $temp;
}


1;
__END__

