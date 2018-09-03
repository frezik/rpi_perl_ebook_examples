#!/usr/bin/perl
use v5.14;
use warnings;
use GStreamer1;
use Glib qw( TRUE FALSE );


sub bus_error_callback
{
    my ($bus, $msg, $loop) = @_;
    my $s = $msg->get_structure;
    warn $s->get_value('gerror')->message . "\n";
    $loop->quit;
    return FALSE;
}

sub bus_message_callback
{
    my ($bus, $msg) = @_;
    my $s = $msg->get_structure;

    if( $s->get_name eq 'facedetect' ) {
        say $s->to_string;
    }

    return TRUE;
}


{
    my $loop = Glib::MainLoop->new( undef, FALSE );
    GStreamer1::init([ $0, @ARGV ]);

    my $pipeline = GStreamer1::Pipeline->new( 'pipeline' );
    my $rpi        = GStreamer1::ElementFactory::make( rpicamsrc => 'src' );
    my $capsfilter = GStreamer1::ElementFactory::make(
        capsfilter => 'filter_caps' );
    my $vidconvert1 = GStreamer1::ElementFactory::make(
        videoconvert => 'vidconvert' );
    my $facedetect = GStreamer1::ElementFactory::make(
        facedetect => 'detect' );
    my $fakesink = GStreamer1::ElementFactory::make(
        fakesink => 'sink' );

    my $caps = GStreamer1::Caps::Simple->new( 'video/x-raw',
        width     => 'Glib::Int'    => 320,
        height    => 'Glib::Int'    => 240,
    );
    $capsfilter->set( caps => $caps );

    my @link = (
        $rpi,
        $capsfilter,
        $vidconvert1,
        $facedetect,
        $fakesink,
    );
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
    $bus->signal_connect( 'message::element', \&bus_message_callback );

    say "Running";
    $pipeline->set_state( 'playing' );
    $loop->run;
    say "Done";
    $pipeline->set_state( 'null' );
}
