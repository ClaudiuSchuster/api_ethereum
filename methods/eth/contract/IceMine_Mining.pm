package API::methods::eth::contract::IceMine_Mining;

use strict; use warnings; use utf8; use feature ':5.10';



sub deploy {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{constructor} = {
        # _owner => '0x',
        _owner => '0xB7a96A6170A02e6d1FAf7D28A7821766afbc5ee3',
    } unless( $params->{constructor} );
    
    return API::methods::eth::contract::deploy($cgi, $data, $node, $params);
}



1;
