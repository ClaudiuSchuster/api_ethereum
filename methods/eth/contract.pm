package API::methods::eth::contract;

use strict; use warnings; use utf8; use feature ':5.10';


my $set_contract = sub {
    my $node         = shift;
    my $params       = shift;
    my $contracts    = API::methods::eth::personal::account::contracts;
    
    $node->set_contract_abi( $node->_read_file('contracts/'.$params->{contract}.'.abi') );
    $node->set_contract_id( $contracts->{$params->{contract}} );
    
    return $contracts->{$params->{contract}}; # addressOf
};

my $check_basics = sub {
    my $params    = shift;
    my $contracts = API::methods::eth::personal::account::contracts;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params || ref($params) eq 'HASH' );
        
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: Name of 'contract' is needed. Abort!" }
        unless( $params->{contract} );
        
    return { 'rc' => 400, 'msg' => "Contract '$params->{contract}' not found in account.pm. Abort!" }
        unless( defined $contracts->{$params->{contract}} );
        
    return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{contract}.abi' not found. Abort!" }
        unless( -e 'contracts/'.$params->{contract}.'.abi' );
        
    return { 'rc' => 200 };
};

    # $data->{eth2tokenTest}                   = $node->contract_method_call('crowdsaleCalcToken',{ '_weiAmount' => 1*10**18 })->bstr();

sub info {
    my $cgi=shift; my $data=shift; my $node=shift; my $params=shift;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );

    my $contract = $set_contract->($node, $params);
    
    $data->{address}                         = $contract;
    $data->{name}                            = substr($node->contract_method_call('name'), 1);
    $data->{symbol}                          = substr($node->contract_method_call('symbol'), 1);
    $data->{decimals}                        = $node->contract_method_call('decimals')->numify();
    my $totalSupply                          = $node->contract_method_call('totalSupply');
    $data->{totalSupply}                     = $totalSupply->bstr();
    $data->{totalSupply_IceMine}             = $node->wei2ether( $totalSupply )->numify();
    $data->{memberCount}                     = $node->contract_method_call('memberCount')->numify();
    for (0..($data->{memberCount}-1) ) {
        push @{$data->{memberIndex}}, $node->contract_method_call('memberIndex', { '' => $_ });
    }
    $data->{crowdsaleOpen}                   = $node->contract_method_call('crowdsaleOpen')->numify();
    $data->{crowdsaleFinished}               = $node->contract_method_call('crowdsaleFinished')->numify();
    $data->{crowdsalePercent}                = $node->contract_method_call('crowdsalePercentOfTotalSupply')->numify();
    my $crowdsaleSupply                      = $node->contract_method_call('crowdsaleSupply');
    $data->{crowdsaleSupply}                 = $crowdsaleSupply->bstr();
    $data->{crowdsaleSupply_IceMine}         = $node->wei2ether( $crowdsaleSupply )->numify();
    my $weiRaised                            = $node->contract_method_call('crowdsaleRaised');
    $data->{crowdsaleRaised_Wei}             = $weiRaised->bstr();
    $data->{crowdsaleRaised_Eth}             = $node->wei2ether( $weiRaised )->numify();
    my $crowdsaleCap                         = $node->contract_method_call('crowdsaleCap');
    $data->{crowdsaleCap}                    = $crowdsaleCap->bstr();
    $data->{crowdsaleCap_Eth}                = $node->wei2ether( $crowdsaleCap )->numify();
    $data->{crowdsaleWallet}                 = $node->contract_method_call('crowdsaleWallet');
    my $weiRemaining                         = $node->contract_method_call('crowdsaleRemainingWei');
    $data->{crowdsaleRemainingWei}           = $weiRemaining->bstr();
    $data->{crowdsaleRemainingWei_Eth}       = $node->wei2ether( $weiRemaining )->numify();
    my $crowdsaleRemainingToken              = $node->contract_method_call('crowdsaleRemainingToken');
    $data->{crowdsaleRemainingToken}         = $crowdsaleRemainingToken->bstr();
    $data->{crowdsaleRemainingToken_IceMine} = $node->wei2ether( $crowdsaleRemainingToken )->numify();
    
    return { 'rc' => 200 };
}

sub member {
    my $cgi=shift; my $data=shift; my $node=shift; my $params=shift;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' of _beneficiary needed. Abort!" }
        unless( $params->{address} );
    
    my $contract = $set_contract->($node, $params);
    
    my $balance              = $node->contract_method_call('balanceOf',    { '_beneficiary' => $params->{address} });
    $data->{balance}         = $balance->bstr();
    $data->{balance_IceMine} = $node->wei2ether( $balance )->numify();
    my $percent              = $node->contract_method_call('percentOf',    { '_beneficiary' => $params->{address} });
    $data->{percent}         = $percent->bstr();
    # $data->{percent_percent} = $node->wei2ether( $percent )->numify();
    my $investment           = $node->contract_method_call('investmentOf', { '_beneficiary' => $params->{address} });
    $data->{investment}      = $investment->bstr();
    $data->{investment_Eth}  = $node->wei2ether( $investment )->numify();
    my $unpaid               = $node->contract_method_call('unpaidOf',     { '_beneficiary' => $params->{address} });
    $data->{unpaid}          = $unpaid->bstr();
    $data->{unpaid_Eth}      = $node->wei2ether( $unpaid )->numify();

    return { 'rc' => 200 };
}

sub deploy {
    my $cgi=shift; my $data=shift; my $node=shift; my $params=shift;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    return { 'rc' => 400, 'msg' => "Argument 'constructor' must be an object-{}. Abort!" }
        if( defined $params->{constructor} && ref($params->{constructor}) ne 'HASH' );
    
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
    $data->{tx_cost_wei}   = $data->{gas_used} * $data->{gas_price_wei};
    $data->{tx_cost_eth}   = $node->wei2ether( $data->{tx_cost_wei} )->numify();
    
    return { 'rc' => 200 };
}


1;