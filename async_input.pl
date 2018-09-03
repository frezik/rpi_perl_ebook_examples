#!perl
use v5.20;
use RPi::WiringPi;
use RPi::Const qw(:all);

my $pi = RPi::WiringPi->new;
my $pin2 = $pi->pin( 2 );
my $pin3 = $pi->pin( 3 );
my $pin4 = $pi->pin( 4 );

foreach ($pin2, $pin3, $pin4) {
    $_->mode( INPUT );
    $_->pull( PUD_UP );
}

$pin2->set_interrupt( EDGE_RISING, 'input_handler_2' );
$pin3->set_interrupt( EDGE_FALLING, 'input_handler_3' );
$pin4->set_interrupt( EDGE_BOTH, 'input_handler_4' );


say "Awaiting input . . . ";
while(1) {
    sleep 10;
}


sub input_handler_2
{
    say "Pin 2 triggered";
}

sub input_handler_3
{
    say "Pin 3 triggered";
}

sub input_handler_4
{
    say "Pin 4 triggered";
}
