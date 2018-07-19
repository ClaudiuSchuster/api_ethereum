package API::methods::eth::node;

use strict; use warnings; use utf8; use feature ':5.10';


sub block {
    my ($cgi, $data, $node, $params) = @_;
    
    $data->{block_number} = $node->eth_blockNumber();
    
    return { 'rc' => 200 };
}

sub balance {
    my ($cgi, $data, $node, $params) = @_;
    
    my $balance_wei         = $node->eth_getBalance($node->eth_coinbase(), "latest");
    $data->{balance_wei}    = $balance_wei->bstr();
    $data->{balance_eth}    = $node->wei2ether( $balance_wei )->numify();
    
    return { 'rc' => 200 };
}

sub info {
    my ($cgi, $data, $node, $params) = @_;
    
    $data->{client_version} = $node->web3_clientVersion();
    $data->{eth_coinbase}   = $node->eth_coinbase();
    $data->{net_version}    = $node->net_version();
    $data->{net_peerCount}  = $node->net_peerCount();
    $data->{net_listening}  = \($node->net_listening() || 0);
    $data->{syncing}        = $node->eth_protocolVersion();
    $data->{eth_syncing}    = $node->eth_syncing() ? \1 : \0;
    $data->{eth_accounts}   = $node->eth_accounts();
    block($cgi, $data, $node, $params);
    balance($cgi, $data, $node, $params);
    
    return { 'rc' => 200 };
}


1;
