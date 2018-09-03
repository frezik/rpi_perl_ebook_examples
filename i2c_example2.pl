while(1) {
    my $temp = $tmp102->read_bytes( 2, 0x00 );
    say "${temp}C";
    sleep 1;
}
