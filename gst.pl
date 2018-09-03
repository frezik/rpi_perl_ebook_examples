#!/usr/bin/perl
use v5.24;
use warnings;
use GStreamer1;
use Glib qw( TRUE FALSE );

my $OUT_FILE = shift || die "Need file to save to\n";
 
 
sub dump_to_file
{
    my ($output_file, $jpeg_data) = @_;
    my @jpeg_bytes = @$jpeg_data;
    say "Got jpeg, saving " . scalar(@jpeg_bytes) . " bytes . . . ";
 
    open( my $fh, '>', $output_file ) or die "Can't open '$output_file': $!\n";
    binmode $fh;
    print $fh pack( 'C*', @jpeg_bytes );
    close $fh;
 
    say "Saved jpeg to $output_file (size: " . (-s $output_file) . ")";
    return 1;
}
 
 
GStreamer1::init([ $0, @ARGV ]);
my $loop = Glib::MainLoop->new( undef, FALSE );
my $pipeline = GStreamer1::Pipeline->new( 'pipeline' );
 
my $rpi        = GStreamer1::ElementFactory::make( rpicamsrc => 'src' );
my $h264parse  = GStreamer1::ElementFactory::make( h264parse => 'parser' );
my $capsfilter = GStreamer1::ElementFactory::make(
    capsfilter => 'h264_caps' );
my $avdec_h264 = GStreamer1::ElementFactory::make(
    avdec_h264 => 'h264_decode' );
my $jpegenc    = GStreamer1::ElementFactory::make( jpegenc => 'jpg_encode' );
my $appsink    = GStreamer1::ElementFactory::make(
    appsink => 'sink' );
 
my $caps = GStreamer1::Caps::Simple->new( 'video/x-h264',
    width  => 'Glib::Int' => 800,
    height => 'Glib::Int' => 600,
);
$capsfilter->set( caps => $caps );
 
$appsink->set( 'max-buffers'  => 20 );
$appsink->set( 'emit-signals' => TRUE );
$appsink->set( 'sync'         => FALSE );
 
 
my @link = ( $rpi, $h264parse, $capsfilter, $avdec_h264, $jpegenc, $appsink );
$pipeline->add( $_ ) for @link;
foreach my $i (0 .. $#link) {
    last if ! exists $link[$i+1];
    my $this = $link[$i];
    my $next = $link[$i+1];
    $this->link( $next );
}
 
$pipeline->set_state( "playing" );
my $jpeg_sample = $appsink->pull_sample;
$pipeline->set_state( "null" );
 
my $jpeg_buf = $jpeg_sample->get_buffer;
my $size = $jpeg_buf->get_size;
my $buf = $jpeg_buf->extract_dup( 0, $size, undef, $size );
dump_to_file( $OUT_FILE, $buf );
