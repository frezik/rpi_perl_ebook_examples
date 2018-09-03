#!perl
use v5.14;
use warnings;
use DBI;
use RPi::WiringPi;
use RPi::Const qw{ :all };

use constant LOG_TIME_SEC => 60 * 5;
use constant SQLITE_FILE => 'temperature.sqlite';


my $rpi = RPi::WiringPi->new;
my $tmp102 = $rpi->i2c( 0x48 );

my $dbh = DBI->connect( 'dbi:SQLite:dbname=' . SQLITE_FILE, '', '' );


while(1) {
    my $temp = $tmp102->read_bytes( 2, 0x00 );
    log_to_database( $temp );
    sleep LOG_TIME_SEC;
}


sub log_to_database
{
    my ($temp) =  @_;
    my $sth = $dbh->prepare_cached( 'INSERT INTO temperature'
        . ' (temperature) VALUES (?)' )
        or die "Can't prepare statement: " . $dbh->errstr;
    $sth->execute( $temp )
        or die "Can't execute statement: " . $sth->errstr;
    $sth->finish;

    return;
}
