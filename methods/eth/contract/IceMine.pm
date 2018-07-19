package API::methods::eth::contract::IceMine;

use strict; use warnings; use utf8; use feature ':5.10';
use Data::Dumper;

sub deploy {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{constructor} = {
        _cap => 10,
        _wallet => '0x0acc13d0c5be1c8e8ae47c1f0363757ebef3a5d1',
        _owner => '0xB7a96A6170A02e6d1FAf7D28A7821766afbc5ee3',
    } unless( $params->{constructor} );
    
    return API::methods::eth::contract::deploy($cgi, $data, $node, $params);
}

sub memberIndex {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{memberIndex} = [];
    my $memberCount                         = $node->contract_method_call('memberCount')->numify();
    for ( 0..($memberCount-1) ) {
        push @{$data->{memberIndex}},         $node->contract_method_call('memberIndex', { '' => $_ });
    }

    return { 'rc' => 200 };
}

sub member {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' of _beneficiary needed. Abort!" }
        unless( $params->{address} );
    
    my $balance                             = $node->contract_method_call('balanceOf',              { '_beneficiary' => $params->{address} });
    $data->{balance_ici}                    = $balance->bstr().'';
    $data->{balance_ice}                    = $node->wei2ether( $balance )->numify();
    my $percentTotal                        = $node->contract_method_call('percentTotalOf',         { '_beneficiary' => $params->{address} });
    $data->{percentTotal}                   = $percentTotal->bstr().'';
    $data->{percentTotal_float}             = $percentTotal->btdiv(10**21)->numify();
    my $crowdsalePercent                    = $node->contract_method_call('crowdsalePercentOf',     { '_beneficiary' => $params->{address} });
    $data->{crowdsalePercent}               = $crowdsalePercent->bstr().'';
    $data->{crowdsalePercent_float}         = $crowdsalePercent->btdiv(10**21)->numify();
    my $crowdsaleInvestment                 = $node->contract_method_call('crowdsaleInvestmentOf',  { '_beneficiary' => $params->{address} });
    $data->{crowdsaleInvestment_wei}        = $crowdsaleInvestment->bstr().'';
    $data->{crowdsaleInvestment_eth}        = $node->wei2ether( $crowdsaleInvestment )->numify();
    my $unpaid                              = $node->contract_method_call('unpaidOf',               { '_beneficiary' => $params->{address} });
    $data->{unpaid_wei}                     = $unpaid->bstr().'';
    $data->{unpaid_eth}                     = $node->wei2ether( $unpaid )->numify();
    $data->{crowdsaleIsMember}              = \($node->contract_method_call('crowdsaleIsMemberOf',  { '_beneficiary' => $params->{address} })->numify());

    return { 'rc' => 200 };
}

sub withdraw {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' of _beneficiary needed. Abort!" }
        unless( $params->{address} );
    
    $params->{contract} = $contract->{name};
    $params->{function} = 'withdrawOf';
    $params->{function_params} = {
        _beneficiary => $params->{address}
    };
    
    return API::methods::eth::contract::sendTransaction($cgi, $data, $node, $params);
}

sub read {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{address}                         = $contract->{address};
    $data->{name}                            = substr($node->contract_method_call('name'), 1);
    $data->{symbol}                          = substr($node->contract_method_call('symbol'), 1);
    $data->{decimals}                        = $node->contract_method_call('decimals')->numify();
    my $totalSupply                          = $node->contract_method_call('totalSupply');
    $data->{totalSupply_ici}                 = $totalSupply->bstr().'';
    $data->{totalSupply_ice}                 = $node->wei2ether( $totalSupply )->numify();
    $data->{percentMultiplier}               = $node->contract_method_call('totalSupply')->bstr().'';
    $data->{memberCount}                     = $node->contract_method_call('memberCount')->numify();
    $data->{crowdsaleOpen}                   = \($node->contract_method_call('crowdsaleOpen')->numify());
    $data->{crowdsaleFinished}               = \($node->contract_method_call('crowdsaleFinished')->numify());
    $data->{crowdsaleInitialized}            = \($node->contract_method_call('crowdsaleInitialized')->numify());
    $data->{crowdsalePercentOfTotalSupply}   = $node->contract_method_call('crowdsalePercentOfTotalSupply')->numify();
    my $crowdsaleSupply                      = $node->contract_method_call('crowdsaleSupply');
    $data->{crowdsaleSupply_ici}             = $crowdsaleSupply->bstr().'';
    $data->{crowdsaleSupply_ice}             = $node->wei2ether( $crowdsaleSupply )->numify();
    my $weiRaised                            = $node->contract_method_call('crowdsaleRaised');
    $data->{crowdsaleRaised_wei}             = $weiRaised->bstr().'';
    $data->{crowdsaleRaised_eth}             = $node->wei2ether( $weiRaised )->numify();
    my $crowdsaleCap                         = $node->contract_method_call('crowdsaleCap');
    $data->{crowdsaleCap_wei}                = $crowdsaleCap->bstr().'';
    $data->{crowdsaleCap_eth}                = $node->wei2ether( $crowdsaleCap )->numify();
    $data->{crowdsaleWallet}                 = $node->contract_method_call('crowdsaleWallet');
    $data->{owner}                           = $node->contract_method_call('owner');
    $data->{depositor}                       = $node->contract_method_call('depositor');
    $data->{withdrawer}                      = $node->contract_method_call('withdrawer');
    my $weiRemaining                         = $node->contract_method_call('crowdsaleRemainingWei');
    $data->{crowdsaleRemainingWei_wei}       = $weiRemaining->bstr().'';
    $data->{crowdsaleRemainingWei_eth}       = $node->wei2ether( $weiRemaining )->numify();
    my $crowdsaleRemainingToken              = $node->contract_method_call('crowdsaleRemainingToken');
    $data->{crowdsaleRemainingToken_ici}     = $crowdsaleRemainingToken->bstr().'';
    $data->{crowdsaleRemainingToken_ice}     = $node->wei2ether( $crowdsaleRemainingToken )->numify();
    $data->{crowdsaleCalcToken_1wei}         = $node->contract_method_call('crowdsaleCalcTokenAmount',{ '_weiAmount' => 1 })->numify();
    memberIndex($cgi, $data, $node, $params, $contract);

    return { 'rc' => 200 };
}

sub crowdsaleCalcTokenAmount {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'weiAmount' to calculate needed. Abort!" }
        unless( $params->{weiAmount} );
    
    my $crowdsaleCalcTokenAmount            = $node->contract_method_call('crowdsaleCalcTokenAmount',  { '_weiAmount' => $params->{weiAmount} });
    $data->{tokenAmount_ici}                = $crowdsaleCalcTokenAmount->bstr().'';
    $data->{tokenAmount_ice}                = $node->wei2ether( $crowdsaleCalcTokenAmount )->numify();

    return { 'rc' => 200 };
}




1;