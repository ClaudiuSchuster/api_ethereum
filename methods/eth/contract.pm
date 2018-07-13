package API::methods::eth::contract;

use strict; use warnings; use utf8; use feature ':5.10';
use Data::Dumper;

sub info {
    my $cgi=shift; my $data=shift; my $node=shift; my $params=shift;
    my $contracts = API::methods::eth::personal::account::contracts;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'name' of contract is needed. Abort!" }
        unless( $params->{name} );
    return { 'rc' => 400, 'msg' => "Contract '$params->{name}' not found in account.pm. Abort!" }
        unless( defined $contracts->{$params->{name}} );
    return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{name}.abi' not found. Abort!" }
        unless( -e 'contracts/'.$params->{name}.'.abi' );

    $node->set_contract_abi( $node->_read_file('contracts/'.$params->{name}.'.abi') );
    $node->set_contract_id($contracts->{$params->{name}});
    
    $data->{address}         = $contracts->{$params->{name}};
    $data->{name}            = substr($node->contract_method_call('name'), 1);
    $data->{symbol}          = substr($node->contract_method_call('symbol'), 1);
    $data->{wallet}          = $node->contract_method_call('crowdsaleWallet');
    $data->{cap}             = $node->contract_method_call('crowdsaleCap')->bstr();
    $data->{decimals}        = $node->contract_method_call('decimals')->numify();
    $data->{totalSupply}     = $node->contract_method_call('totalSupply')->bstr();
    my $weiRaised            = $node->contract_method_call('crowdsaleRaised');
    $data->{raised_wei}      = $weiRaised->bstr();
    $data->{raised_eth}      = $node->wei2ether( $weiRaised )->numify();
    my $weiRemaining         = $node->contract_method_call('remainingWei');
    $data->{remaining_wei}   = $weiRemaining->bstr();
    $data->{remaining_eth}   = $node->wei2ether( $weiRemaining )->numify();
    $data->{remaining_token} = $node->contract_method_call('remainingTokens')->bstr();
    $data->{cap_reached}     = $node->contract_method_call('capReached')->numify();
    $data->{ico_percent}     = $node->contract_method_call('crowdsalePercent')->numify();
    
    return { 'rc' => 200 };
}

sub address {
    my $cgi=shift; my $data=shift; my $node=shift; my $params=shift;
    my $contracts = API::methods::eth::personal::account::contracts;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'name' of contract and 'address' of account in contract needed. Abort!" }
        unless( $params->{name} && $params->{address} );
    return { 'rc' => 400, 'msg' => "Contract '$params->{name}' not found in account.pm. Abort!" }
        unless( defined $contracts->{$params->{name}} );
    return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{name}.abi' not found. Abort!" }
        unless( -e 'contracts/'.$params->{name}.'.abi' );

    $node->set_contract_abi( $node->_read_file('contracts/'.$params->{name}.'.abi') );
    $node->set_contract_id($contracts->{$params->{name}});
    
    $data->{balance_token}    = $node->contract_method_call('balanceOf',{ '' => $params->{address} })->bstr();
    $data->{investment_wei} = $node->contract_method_call('investmentOf',{ '' => $params->{address} })->bstr();

    return { 'rc' => 200 };
}

sub deploy {
    my $cgi=shift; my $data=shift; my $node=shift; my $params=shift;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'name' of contract to deploy is needed. Abort!" }
        unless( $params->{name} );
    return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{name}.sol' not found. Abort!" }
        unless( -e 'contracts/'.$params->{name}.'.sol' );
    return { 'rc' => 400, 'msg' => "Argument 'constructor' must be an object-{}. Abort!" }
        if( defined $params->{constructor} && ref($params->{constructor}) ne 'HASH' );

    my $contract_status;
    eval {
        $contract_status = $node->compile_and_deploy_contract(
            $params->{name},
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
    $data->{tx_cost_wei}   = $data->{gas_used} * $data->{gas_price_wei};
    $data->{tx_cost_eth}   = $node->wei2ether( $data->{tx_cost_wei} )->numify();
    
    return { 'rc' => 200 };
}


1;