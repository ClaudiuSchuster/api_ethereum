package API::methods::eth::address;

use strict; use warnings; use utf8; use feature ':5.10';


sub balance {
    my ($cgi, $data, $node, $params) = @_;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params && ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' needed. Abort!" }
        unless( $params->{address} );
    
    my $balance_wei         = $node->eth_getBalance($params->{address}, "latest");
    $data->{balance_wei}    = $balance_wei->bstr().'';
    $data->{balance_eth}    = $node->wei2ether( $balance_wei )->numify();
    
    return { 'rc' => 200 };
}


1;
