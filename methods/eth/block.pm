package API::methods::eth::block;

use strict; use warnings; use utf8; use feature ':5.10';


my $check_basics = sub {
    my $params = shift;
    
    return { 'rc' => 400, 'msg' => "No 'params' array[] for block_number / block_hash submitted. Abort!" }
        unless( defined $params && ref($params) eq 'ARRAY' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted. Abort!" }
        unless( $params->[0] );
        
    return { 'rc' => 200 };
};

sub byNumber {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    $data->{block} = $node->eth_getBlockByNumber($params->[0], $params->[1]);
    
    return { 'rc' => 200 };
}

sub byHash {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    $data->{block} = $node->eth_getBlockByHash($params->[0], $params->[1]);
    
    
    return { 'rc' => 200 };
}


1;
