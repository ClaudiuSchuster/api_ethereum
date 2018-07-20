package API::methods::eth::address;

use strict; use warnings; use utf8; use feature ':5.10';


my $check_basics = sub {
    my $params = shift;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params && ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' needed. Abort!" }
        unless( $params->{address} );
        
    return { 'rc' => 200 };
};

sub balance {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    my $balance_wei         = $node->eth_getBalance($params->{address}, "latest");
    $data->{balance_wei}    = $balance_wei->bstr().'';
    $data->{balance_eth}    = $node->wei2ether( $balance_wei )->numify();
    
    return { 'rc' => 200 };
}

sub logs {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    return { 'rc' => 400, 'msg' => "Argument 'topics' must be an array[]. Abort!" }
        if( defined $params->{topics} && ref($params->{topics}) ne 'ARRAY' );
    
    $data->{logs} = $node->eth_getLogs($params->{address}, $params->{fromBlock}, $params->{topics});
    
    return { 'rc' => 200 };
}


1;
