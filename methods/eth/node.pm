package API::methods::eth::node;

use strict; use warnings; use utf8; use feature ':5.10';


my $personal_unlockAccount = sub {
    my $node = shift;
    
    eval {
        $node->personal_unlockAccount(
            API::methods::eth::personal::account::address, 
            API::methods::eth::personal::account::password,
            60
        );
    } or do {
        return { 'rc' => 500, 'msg' => "error.personal_unlockAccount: ".$@ };
    };
    
    return { 'rc' => 200 };
};

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
    
    $data->{eth_coinbase} = API::methods::eth::personal::account::address || '0x0000000000000000000000000000000000000000';
    
    return { 'rc' => 200 };
}

sub balance {
    my ($cgi, $data, $node, $params) = @_;
    
    $params->{address} = API::methods::eth::personal::account::address || '0x0000000000000000000000000000000000000000';
    
    return API::methods::eth::address::balance($cgi, $data, $node, $params);
}

sub exchange {
    my ($cgi, $data, $node, $params) = @_;
    my $iterations = 96; # 96 iteration (min. 5 sec each) = Try min. 8 Minutes to verify the tx (wait for mined block)
    my $txGas = 21000;
    my $minAmount = 0.1;  # 0.1 ETH to send at least
    my $remainingFunds = Math::BigInt->new('0x16345785D8A0000'); #0.1 ETH to remain on address
    my $remainingFunds_eth = $node->wei2ether( $remainingFunds )->numify();
    
    my $startTime = time();
    my $result = $personal_unlockAccount->($node);
    return $result unless( defined $result->{rc} && $result->{rc} == 200 );
    
    my $gasPrice = $node->eth_gasPrice();
    my $balance_wei = $node->eth_getBalance(API::methods::eth::personal::account::address, 'latest');
    my $balance_eth = $node->wei2ether( $balance_wei )->numify();
    my $txCost = $gasPrice * $txGas;
    my $txCost_eth = $node->wei2ether( $txCost )->numify();
    my $value = $balance_wei->bsub($txCost)->bsub($remainingFunds);
    
    return { rc => 500, msg => "Not enaugh funds ($balance_eth ETH), must send|hold at least $minAmount|$remainingFunds_eth ETH. (tx-cost will be $txCost_eth ETH)" } unless( $node->wei2ether( $value )->numify() >= $minAmount );
    return { rc => 500, msg => "No target exchange-adddress in accounts.pm" } unless( API::methods::eth::personal::account::krakenAddress );
    # return { rc => 800, msg => "from:".API::methods::eth::personal::account::address." to:".API::methods::eth::personal::account::krakenAddress." gas:".sprintf('0x%x', $txGas)." gasPrice:".$gasPrice->as_hex()." value:".$value->as_hex() };

    my $tx;
    eval {
        $tx = $node->eth_sendTransaction({
            from     => API::methods::eth::personal::account::address,
            to       => API::methods::eth::personal::account::krakenAddress,
            gas      => sprintf('0x%x', $txGas),
            gasPrice => $gasPrice->as_hex(),
            value    => $value->as_hex()
        });
     
        $result = $node->wait_for_transaction($tx, $iterations, $node->get_show_progress());
        return { 'rc' => 500, 'msg' =>  "Could not verify transaction after $iterations iterations." } unless( defined $result );
        1; 
    } or do {
        return { 'rc' => 500, 'msg' => "error.node.exchange: ".$@ };
    };
    
    API::methods::eth::block::byHash( $cgi, $data, $node, [$result->{blockHash}, 1, $tx] );
    $API::methods::eth::tx::add_tx_receipt->($data, $node, $result);
    $data->{tx_execution_time} = time() - $startTime;
    
    return { rc => 200 };
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
