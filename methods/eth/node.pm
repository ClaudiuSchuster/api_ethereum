package API::methods::eth::node;

use strict; use warnings; use utf8; use feature ':5.10';


sub sha3 {
    my ($cgi, $data, $node, $params) = @_;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params && ref($params) eq 'ARRAY' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: something needed. Abort!" }
        unless( defined $params->[0] );
    
    $data->{hex} = $node->_string2hex( $params->[0] );
    $data->{sha3} = $node->web3_sha3( $data->{hex} );
    
    return { 'rc' => 200 };
}

sub block {
    my ($cgi, $data, $node, $params) = @_;
    
    $data->{block_number} = $node->eth_blockNumber();
    
    return { 'rc' => 200 };
}

sub accounts {
    my ($cgi, $data, $node, $params) = @_;
    
    $data->{eth_accounts} = $node->eth_accounts();
    
    return { 'rc' => 200 };
}

sub coinbase {
    my ($cgi, $data, $node, $params) = @_;
    
    $data->{eth_coinbase} = $node->eth_coinbase();
    
    return { 'rc' => 200 };
}

sub balance {
    my ($cgi, $data, $node, $params) = @_;
    
    eval{ $params->{address} = $node->eth_coinbase(); 1; } or do { 
          $params->{address} = '0x0000000000000000000000000000000000000000';
    };
    return API::methods::eth::address::balance($cgi, $data, $node, $params);
}

sub info {
    my ($cgi, $data, $node, $params) = @_;
    
    $data->{client_version} = $node->web3_clientVersion();
    $data->{net_version}    = $node->net_version();
    $data->{net_peerCount}  = $node->net_peerCount();
    $data->{net_listening}  = \($node->net_listening() || 0);
    $data->{syncing}        = $node->eth_protocolVersion();
    $data->{eth_syncing}    = $node->eth_syncing() ? \1 : \0;
    coinbase($cgi, $data, $node, $params);
    accounts($cgi, $data, $node, $params);
    block($cgi, $data, $node, $params);
    balance($cgi, $data, $node, $params);
    
    return { 'rc' => 200 };
}


1;
