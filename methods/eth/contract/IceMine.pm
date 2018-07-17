package API::methods::eth::contract::IceMine;

use strict; use warnings; use utf8; use feature ':5.10';


sub read {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{address}                         = $contract->{address};
    $data->{name}                            = substr($node->contract_method_call('name'), 1);
    $data->{symbol}                          = substr($node->contract_method_call('symbol'), 1);
    $data->{decimals}                        = $node->contract_method_call('decimals')->numify();
    my $totalSupply                          = $node->contract_method_call('totalSupply');
    $data->{totalSupply}                     = $totalSupply->bstr().'';
    $data->{percentMultiplier}               = $node->contract_method_call('totalSupply')->bstr().'';
    $data->{totalSupply_Ice}                 = $node->wei2ether( $totalSupply )->numify();
    $data->{memberCount}                     = $node->contract_method_call('memberCount')->numify();
    for (0..($data->{memberCount}-1) ) {
        push @{$data->{memberIndex}}, $node->contract_method_call('memberIndex', { '' => $_ });
    }
    $data->{crowdsaleOpen}                   = \($node->contract_method_call('crowdsaleOpen')->numify());
    $data->{crowdsaleFinished}               = \($node->contract_method_call('crowdsaleFinished')->numify());
    $data->{crowdsaleInitialized}            = \($node->contract_method_call('crowdsaleInitialized')->numify());
    $data->{crowdsalePercentOfTotalSupply}   = $node->contract_method_call('crowdsalePercentOfTotalSupply')->numify();
    my $crowdsaleSupply                      = $node->contract_method_call('crowdsaleSupply');
    $data->{crowdsaleSupply}                 = $crowdsaleSupply->bstr().'';
    $data->{crowdsaleSupply_Ice}             = $node->wei2ether( $crowdsaleSupply )->numify();
    my $weiRaised                            = $node->contract_method_call('crowdsaleRaised');
    $data->{crowdsaleRaised_Wei}             = $weiRaised->bstr().'';
    $data->{crowdsaleRaised_Eth}             = $node->wei2ether( $weiRaised )->numify();
    my $crowdsaleCap                         = $node->contract_method_call('crowdsaleCap');
    $data->{crowdsaleCap}                    = $crowdsaleCap->bstr().'';
    $data->{crowdsaleCap_Eth}                = $node->wei2ether( $crowdsaleCap )->numify();
    $data->{crowdsaleWallet}                 = $node->contract_method_call('crowdsaleWallet');
    $data->{owner}                           = $node->contract_method_call('owner');
    $data->{depositor}                       = $node->contract_method_call('depositor');
    $data->{withdrawer}                      = $node->contract_method_call('withdrawer');
    my $weiRemaining                         = $node->contract_method_call('crowdsaleRemainingWei');
    $data->{crowdsaleRemainingWei}           = $weiRemaining->bstr().'';
    $data->{crowdsaleRemainingWei_Eth}       = $node->wei2ether( $weiRemaining )->numify();
    my $crowdsaleRemainingToken              = $node->contract_method_call('crowdsaleRemainingToken');
    $data->{crowdsaleRemainingToken}         = $crowdsaleRemainingToken->bstr().'';
    $data->{crowdsaleRemainingToken_Ice}     = $node->wei2ether( $crowdsaleRemainingToken )->numify();
    $data->{crowdsaleCalcToken_1wei}         = $node->contract_method_call('crowdsaleCalcTokenAmount',{ '_weiAmount' => 1*10**18 })->numify();

    return { 'rc' => 200 };
}

sub member {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' of _beneficiary needed. Abort!" }
        unless( $params->{address} );
    
    my $balance                     = $node->contract_method_call('balanceOf',              { '_beneficiary' => $params->{address} });
    $data->{balance}                = $balance->bstr().'';
    $data->{balance_Ice}            = $node->wei2ether( $balance )->numify();
    my $percentTotal                = $node->contract_method_call('percentTotalOf',         { '_beneficiary' => $params->{address} });
    $data->{percentTotal}           = $percentTotal->bstr().'';
    $data->{percentTotal_Float}     = $percentTotal->btdiv(10**21)->numify();
    my $crowdsalePercent            = $node->contract_method_call('crowdsalePercentOf',     { '_beneficiary' => $params->{address} });
    $data->{crowdsalePercent}       = $crowdsalePercent->bstr().'';
    $data->{crowdsalePercent_Float} = $crowdsalePercent->btdiv(10**21)->numify();
    my $crowdsaleInvestment         = $node->contract_method_call('crowdsaleInvestmentOf',  { '_beneficiary' => $params->{address} });
    $data->{crowdsaleInvestment}    = $crowdsaleInvestment->bstr().'';
    $data->{crowdsaleInvestment_Eth}= $node->wei2ether( $crowdsaleInvestment )->numify();
    my $unpaid                      = $node->contract_method_call('unpaidOf',               { '_beneficiary' => $params->{address} });
    $data->{unpaid}                 = $unpaid->bstr().'';
    $data->{unpaid_Eth}             = $node->wei2ether( $unpaid )->numify();
    $data->{crowdsaleIsMember}      = \($node->contract_method_call('crowdsaleIsMemberOf',  { '_beneficiary' => $params->{address} })->numify());

    return { 'rc' => 200 };
}

sub deploy {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{contract} = 'IceMine' unless( $params->{contract} );
    $params->{constructor} = {
        _cap => 2,
        _wallet => '0x0acc13d0c5be1c8e8ae47c1f0363757ebef3a5d1',
        _owner => '0x0',
    } unless( $params->{constructor} );
    
    return $contract->{deploy_run_ref}->($cgi, $data, $node, $params);
}


1;