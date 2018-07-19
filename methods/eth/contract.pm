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
            unless( defined $contracts->{$params->{contract}} );
            
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
    $node->set_contract_id( $contracts->{$params->{contract}} );
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
    
    $API::methods::eth::tx::add_tx_receipt->($data, $node, $result);
    $data->{address} = $result->{contractAddress};
    $data->{tx_execution_time} = time() - $startTime;
    
    return { 'rc' => 200 };
}

sub transaction {
    my ($cgi, $data, $node, $params) = @_;
    my $iterations = 96; # 96 iteration (min. 5 sec each) = Try min. 8 Minutes to verify the tx (wait for mined block)
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'contract', 'function' and 'function_params' needed. Abort!" }
        unless( $params->{function} && $params->{contract} );
    
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
    
    $API::methods::eth::tx::add_tx_receipt->($data, $node, $result);
    $data->{tx_execution_time} = time() - $startTime;
    
    return { 'rc' => 200 };
}


sub run {
    my ($cgi, $data, $node, $reqFunc, $reqFunc_run_ref, $contractName, $params) = @_;
    my $contracts = API::methods::eth::personal::account::contracts;
    
    $params->{contract} = $contractName;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    $set_contract_abi->($node, $params);
    
    return $reqFunc_run_ref->(
        $cgi,
        $data,
        $node,
        $params,
        {
            address => $contracts->{$contractName} || '',
            name => $contractName,
        }
    );
}


1;