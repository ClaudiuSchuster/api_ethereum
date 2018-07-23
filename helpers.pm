package API::helpers;

use strict; use warnings; use utf8; use feature ':5.10';
use JSON;
use HTTP::Request;
use LWP::UserAgent;

### trim function (removes also \n in beginning and end of string)
sub trim($) { 
    my $string = shift;
    $string =~ s/^\n+//; $string =~ s/^\s+//; $string =~ s/\n+$//; $string =~ s/\s+$//;
    return $string;
} 

# sub decode_input($$) {
    # my $contractName = shift;
    # my $input = shift;

    # return decode_json( `./ethereum-input-decoder.js $contractName $input` );
# }

sub decode_log($) {
    my $json = JSON->new->encode($_[0]);
    my $req = HTTP::Request->new( 'POST', 'http://127.0.0.1:880/' );
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( $json );

    my $lwp = LWP::UserAgent->new;
    my $res = $lwp->request( $req );

    return decode_json( $res->{_content} );
}

sub HexToAscii($) {
    my $hex = shift;
    my $str = "";
    for (my $i=2; $i < length($hex); $i+=2) {
        my $code = hex(substr($hex, $i, 2));
        $str .= chr($code);
    }
    return $str;
};



1;