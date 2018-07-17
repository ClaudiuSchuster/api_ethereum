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


my $deploy = sub {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params, 1);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    return { 'rc' => 400, 'msg' => "Argument 'constructor' must be an object-{}. Abort!" }
        if( defined $params->{constructor} && ref($params->{constructor}) ne 'HASH' );
    return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{contract}.sol' not found. Abort!" }
        unless( -e 'contracts/'.$params->{contract}.'.sol' );
    
    my $contract_status;
    eval {
        $contract_status = $node->compile_and_deploy_contract(
            $params->{contract},
            $params->{constructor} || {}, # Constructor Init Parameters
            API::methods::eth::personal::account::address,
            API::methods::eth::personal::account::password
        ); 1; 
    } or do {
        return { 'rc' => 500, 'msg' => "error.eth.contract.deploy: ".$@ };
    };
    $data->{address}       = $contract_status->{contractAddress};
    $data->{tx}            = $contract_status->{transactionHash};
    $data->{gas_used}      = hex($contract_status->{gasUsed});
    $data->{gas_price_wei} = $node->eth_gasPrice()->numify();
    $data->{tx_cost_wei}   = $data->{gas_used} * $data->{gas_price_wei}->bstr();;
    $data->{tx_cost_eth}   = $node->wei2ether( $data->{tx_cost_wei} )->numify();
    
    return { 'rc' => 200 };
};

sub deploy {    
    return $deploy->(@_);
}

sub run {
    my ($cgi, $data, $node, $reqFunc, $reqFunc_run_ref, $contractName, $params) = @_;
    
    $params->{contract} = $contractName;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    my $contracts = API::methods::eth::personal::account::contracts;
    $node->set_contract_abi( $node->_read_file('contracts/'.$contractName.'.abi') );
    $node->set_contract_id( $contracts->{$contractName} );
    
    return $reqFunc_run_ref->(
        $cgi,
        $data,
        $node,
        $params,
        {
            address => $contracts->{$contractName} || '',
            name => $contractName,
            deploy_run_ref => $deploy,
        }
    );
}


1;