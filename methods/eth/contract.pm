package API::methods::eth::contract;

use strict; use warnings; use utf8; use feature ':5.10';


my $check_basics = sub {
    my $params    = shift;
    my $simpleCheck = shift;
    my $contracts = API::methods::eth::personal::account::contracts;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params && ref($params) eq 'HASH' );
        
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: Name of 'contract' is needed. Abort!" }
        unless( $params->{contract} );

    unless( defined $simpleCheck ) {
        return { 'rc' => 400, 'msg' => "Contract '$params->{contract}' not found in methods/eth/personal/account.pm. Abort!" }
            unless( defined $contracts->{$params->{contract}}[0] );
            
        $params->{address} = $contracts->{$params->{contract}}[0] unless( defined $params->{address} );
            
        return { 'rc' => 400, 'msg' => "Contract ABI 'contracts/$params->{contract}.abi' not found. Abort!" }
            unless( -e 'contracts/'.$params->{contract}.'.abi' );
    }
    return { 'rc' => 200 };
};

my $set_contract_abi = sub {
    my $node = shift;
    my $params = shift;
    
    my $contracts = API::methods::eth::personal::account::contracts;
    $node->set_contract_abi( $node->_read_file('contracts/'.$params->{contract}.'.abi') );
    $node->set_contract_id( $contracts->{$params->{contract}}[0] );
};

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


sub deploy {    
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params, 'simpleCheck');
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    return { 'rc' => 400, 'msg' => "Argument 'constructor' must be an object-{}. Abort!" }
        if( defined $params->{constructor} && ref($params->{constructor}) ne 'HASH' );
    return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{contract}.sol' not found. Abort!" }
        unless( -e 'contracts/'.$params->{contract}.'.sol' );
    
    my $startTime = time();
    my $result;
    eval {
        $result = $node->compile_and_deploy_contract(
            $params->{contract},
            $params->{constructor} || {}, # Constructor Init Parameters
            API::methods::eth::personal::account::address,
            API::methods::eth::personal::account::password
        ); 1; 
    } or do {
        return { 'rc' => 500, 'msg' => "error.eth.contract.deploy: ".$@ };
    };
    
    API::methods::eth::block::byHash( $cgi, $data, $node, [$result->{blockHash}, 2] );
    $API::methods::eth::tx::add_tx_receipt->($data, $node, $result);
    $data->{address} = $result->{contractAddress};
    $data->{tx_execution_time} = time() - $startTime;
    
    return { 'rc' => 200 };
}

sub logs {
    my ($cgi, $data, $node, $params) = @_;
    my $contracts = API::methods::eth::personal::account::contracts;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    $params->{fromBlock} = $contracts->{$params->{contract}}[1] unless( defined $params->{fromBlock} );
    
    my $startTime = time();
    $set_contract_abi->($node, $params);
    
    my $raw_topics = [];
    push @{$raw_topics}, $node->web3_sha3( $node->_string2hex($params->{topic}) ) if( defined $params->{topic} && $params->{topic} !~ /^0x/ );
    if( ref($params->{topics}) eq 'ARRAY' ) {
        for my $basetopic ( @{$params->{topics}} ) {
            if( ref($basetopic) eq 'ARRAY' ) {
                my @inner_raw_topics;
                for my $innerTopic ( @$basetopic ) {
                    $innerTopic = $params->{address} if( $innerTopic eq 'contract' );
                    push @inner_raw_topics, ( length($innerTopic) == 66 ? $innerTopic : '0x'.lc(sprintf('%064s', substr($innerTopic, 2))) );
                }
                push @{$raw_topics}, \@inner_raw_topics;
            } else {
                $basetopic = $params->{address} if( $basetopic eq 'contract' );
                push @{$raw_topics}, ( length($basetopic) == 66 ? $basetopic : '0x'.lc(sprintf('%064s', substr($basetopic, 2))) );
            }
        }
    }
    $params->{raw_topics} = $raw_topics;
    my $raw_logs = $node->eth_getLogs($params->{address}, $params->{fromBlock}, $raw_topics, $params->{toBlock});
    
    my @logs;
    for my $raw_log ( @$raw_logs ) {
        my $log = {};
        $log->{tx_hash} = $raw_log->{transactionHash};
        $log->{tx_index} = hex($raw_log->{transactionIndex});
        $log->{log_index} = hex($raw_log->{logIndex});
        $log->{removed} = $raw_log->{removed};
        if( defined $params->{showraw} || !defined $params->{topic} ) {
            $log->{data} = $raw_log->{data}; # DATA - contains one or more 32 Bytes non-indexed arguments of the log. 
            $log->{topics} = $raw_log->{topics}; # Array of DATA - Array of 0 to 4 32 Bytes DATA of indexed log arguments.  (In solidity: The first topic is the hash of the signature of the event   (e.g. Deposit(address,bytes32,uint256)), except you declared the event with the anonymous specifier.)
        }
        
        if( defined $params->{topic} && $params->{topic} =~ /^(\w+)/ ) {
            $log->{event_name} = $1;
            my $event = {};
            $event->{abi} = $node->_get_event_abi($log->{event_name})->{inputs};
            $event->{data} = $raw_log->{data};
            $event->{topics} = $raw_log->{topics};
            splice(@{$event->{topics}},0,1);
            my $event_data = API::helpers::decode_log($event);
            $log->{event_data}{$_} = $event_data->{$_} for( keys %$event_data );
        }
        API::methods::eth::block::byHash( $cgi, $log, $node, [
            $raw_log->{blockHash}, 
            (defined $params->{showtx}?$params->{showtx}:2), 
            $log->{tx_hash},
            undef,
            $params->{contract}
        ] );
        
        push @logs, $log;
    }
    $data->{logs} = \@logs;
    $data->{log_count} = scalar @logs;
    
    return { 'rc' => 200 };
}

sub transaction {
    my ($cgi, $data, $node, $params) = @_;
    my $iterations = 96; # 96 iteration (min. 5 sec each) = Try min. 8 Minutes to verify the tx (wait for mined block)
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'function' needed. Abort!" }
        unless( $params->{function} );
    
    my $startTime = time();
    $set_contract_abi->($node, $params);
    
    my $result = $personal_unlockAccount->($node);
    return $result unless( defined $result->{rc} && $result->{rc} == 200 );
    
    eval {
        my $tr = $node->sendTransaction(
            API::methods::eth::personal::account::address,
            $node->get_contract_id(), $params->{function},
            $params->{function_params} || {},
            $node->contract_method_call_estimate_gas($params->{function}, $params->{function_params})
        );
     
        $result = $node->wait_for_transaction($tr, $iterations, $node->get_show_progress());
        return { 'rc' => 500, 'msg' =>  "Could not verify transaction after $iterations iterations." } unless( defined $result );
        1; 
    } or do {
        return { 'rc' => 500, 'msg' => "error.eth.contract.transaction: ".$@ };
    };
    
    API::methods::eth::block::byHash( $cgi, $data, $node, [$result->{blockHash}, 2] );
    $API::methods::eth::tx::add_tx_receipt->($data, $node, $result);
    $data->{tx_execution_time} = time() - $startTime;
    
    return { 'rc' => 200 };
}


sub run {
    my ($cgi, $data, $node, $reqFunc, $reqFunc_run_ref, $contractName, $params) = @_;
    my $contracts = API::methods::eth::personal::account::contracts;
    
    $params->{contract} = $contractName;
    
    my $checks = $check_basics->( $params, ($reqFunc eq 'deploy' ? 'simpleCheck' : 0) );
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    $set_contract_abi->($node, $params) unless( $reqFunc eq 'deploy' );
    
    return $reqFunc_run_ref->(
        $cgi,
        $data,
        $node,
        $params,
        {
            address => $contracts->{$contractName}[0] || '',
            block_number => $contracts->{$contractName}[1] || '',
            crowdsaleFinished_block_number => $contracts->{$contractName}[2] || '',
            name => $contractName,
        }
    );
}


1;