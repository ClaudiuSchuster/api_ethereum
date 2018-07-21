package API::helpers;

use strict; use warnings; use utf8; use feature ':5.10';


### trim function (removes also \n in beginning and end of string)
sub trim($) { 
    my $string = shift;
    $string =~ s/^\n+//; $string =~ s/^\s+//; $string =~ s/\n+$//; $string =~ s/\s+$//;
    return $string;
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