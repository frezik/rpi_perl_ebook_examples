#!/usr/bin/perl
use v5.14;
use warnings;
use GStreamer1;
use Glib qw( TRUE FALSE );
use RPi::WiringPi;
use RPi::Const qw(:all);
use File::Spec::Functions 'catfile';

my $SAVE_DIR = shift or die "Usage: $0 [save directory]\n";

my $PIN = do {
    my $pi = RPi::WiringPi->new;
    my $pin = $pi->pin( 2 );
    $pin->mode( PUD_UP );
    $pin;
};


sub bus_error_callback
{
    my ($bus, $msg, $loop) = @_;
    my $s = $msg->get_structure;
    warn $s->get_value('gerror')->message . "\n";
    $loop->quit;
    return FALSE;
}

sub handoff_callback
{
    my ($fakesink, $buffer, $pad) = @_;

    if(! $PIN->read ) {
        my $size = $buffer->get_size;
        my $frame_data = $buffer->extract_dup( 0, $size );

        my $timestamp = time;
        my $file = catfile( $SAVE_DIR, $timestamp . '.jpg' );

        open( my $out, '>', $file )
            or die "Can't open $file for writing: $!\n";
        print $out $frame_data;
        close $out;

        say "Saved picture to $file\n";
    }

    return TRUE;
}


{
    my $loop = Glib::MainLoop->new( undef, FALSE );
    GStreamer1::init([ $0, @ARGV ]);
    my $pipeline = GStreamer1::Pipeline->new( 'pipeline' );

    my $rpisrc = GStreamer1::ElementFactory::make( rpicamsrc => 'rpi');
    my $capsfilter = GStreamer1::ElementFactory::make(
        capsfilter => 'caps' );
    my $fakesink = GStreamer1::ElementFactory::make(
        fakesink => 'sink' );

    my $caps = GStreamer1::Caps::Simple->new( 'image/jpeg',
        width     => 'Glib::Int'    => 640,
        height    => 'Glib::Int'    => 480,
    );
    $capsfilter->set( caps => $caps );

    $fakesink->set(
        'signal-handoffs' => TRUE,
    );

    my @link = ( $rpisrc, $capsfilter, $fakesink );
    $pipeline->add( $_ ) for @link;
    foreach my $i (0 .. $#link) {
        last if ! exists $link[$i+1];
        my $this = $link[$i];
        my $next = $link[$i+1];
        $this->link( $next );
    }

    my $bus = $pipeline->get_bus;
    $bus->add_signal_watch;
    $bus->signal_connect( 'message::error', \&bus_error_callback, $loop );
    $fakesink->signal_connect( 'handoff', \&handoff_callback );

    say "Running . . . ";
    $pipeline->set_state( 'playing' );
    $loop->run;
    $pipeline->set_state( 'null' );
}
