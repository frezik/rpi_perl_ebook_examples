#!perl
use v5.20;
use RPi::WiringPi;
use RPi::Const qw(:all);

my $pi = RPi::WiringPi->new;
my $pin2 = $pi->pin( 2 );

$pin2->mode( INPUT );
$pin2->pull( PUD_UP );
$pin2->set_interrupt( EDGE_RISING, 'input_handler' );


say "Awaiting input . . . ";
while(1) {
    sleep 10;
}


sub input_handler
{
    say "Pin 2 triggered";
}
