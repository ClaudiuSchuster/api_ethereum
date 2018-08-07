package API::methods::eth::contract::IceMine;

use strict; use warnings; use utf8; use feature ':5.10';
use Math::BigInt;
use Math::BigFloat;

sub deploy {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{constructor} = {
        _crowdsaleCapEth => 10,
        _crowdsaleWallet => '0x0acc13d0c5be1c8e8ae47c1f0363757ebef3a5d1',
        _teamContract    => '0x58f94C8dD0E40258EE2BD766508964b941147bd8',
        _teamShare       => 40,
        _owner           => '0xB7a96A6170A02e6d1FAf7D28A7821766afbc5ee3'
    } unless( $params->{constructor} );
    
    return API::methods::eth::contract::deploy($cgi, $data, $node, $params);
}

sub logs {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{address} = $contract->{address};
    $params->{fromBlock} = $contract->{block_number};
    
    return API::methods::eth::contract::logs($cgi, $data, $node, $params);
}

sub valueInputs {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{address} = $contract->{address};
    $params->{fromBlock} = $contract->{block_number};
    
    return API::methods::eth::address::valueInputs($cgi, $data, $node, $params);
}

sub valueInputsCrowdsale {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{address} = $contract->{address};
    $params->{fromBlock} = $contract->{block_number};
    $params->{toBlock} = $contract->{crowdsaleFinished_block_number} if( $contract->{crowdsaleFinished_block_number} );
    
    return API::methods::eth::address::valueInputs($cgi, $data, $node, $params);
}

sub balance {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{address} = $contract->{address};
    return API::methods::eth::address::balance($cgi, $data, $node, $params);
}

sub memberIndex {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{memberIndex} = [];
    my $memberCount = $node->contract_method_call('memberCount')->numify();
    for ( 0..($memberCount-1) ) {
        push @{$data->{memberIndex}}, $node->contract_method_call('memberIndex', { '' => $_ });
    }

    return { 'rc' => 200 };
}

sub withdraw {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' of _beneficiary needed. Abort!" }
        unless( $params->{address} );
        
    return { 'rc' => 400, 'msg' => "Member '$params->{address}' has no unpaid_wei. Abort!" }
        unless( $node->contract_method_call('unpaidOf', { '_beneficiary' => $params->{address} })->bgt(0) );
    
    $params->{function} = 'withdrawOf';
    $params->{function_params} = {
        _beneficiary => $params->{address}
    };
    
    return API::methods::eth::contract::transaction($cgi, $data, $node, $params);
}

sub setOwner {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    my $newOwner = "0xB7a96A6170A02e6d1FAf7D28A7821766afbc5ee3";
    
    $params->{function} = 'setOwner';
    $params->{function_params} = {
        _newOwner => $params->{newOwner} || $newOwner
    };
    
    return API::methods::eth::contract::transaction($cgi, $data, $node, $params);
}

# TEAM
# { address => '0xE1F41867532c5c5F63179c9Ec7819d8D3BF772d8', share => 12 },
# { address => '0x587f82E14ccc1176525233ec7166d2f5d19B9A17', share => 9 },
# { address => '0x79691D048AD362Fc59dEB87c6f459393Bd63B791', share => 8 },
# { address => '0xbed0bccb8398577C6920625c693602D2abaF50C6', share => 11 },

sub approve {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    return { 'rc' => 400, 'msg' => "'members' parameter musst be an array[] of object{}'s. Abort!" }
        if( defined $params->{members} && ( ref($params->{members}) ne 'ARRAY' || ref($params->{members}[0]) ne 'HASH' ) );
        
    my $members =  $params->{members} || [
        ## PrivateSale
        { address => '0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5', ethMinPurchase => 1, privateSale => 1 },
        { address => '0x2D6650fB71D71bc62848b24c2b427e83fd9a512A', ethMinPurchase => 0, privateSale => 1 },
        ## PublicSale
        { address => '0x748fe7617Cc2Fa2C734F591beF9072862c674901', ethMinPurchase => 1, privateSale => 0 },
        { address => '0x5e8834D8536Bf15dea25e19D0a274457517fA7dB', ethMinPurchase => 0, privateSale => 0 },
        { address => '0xf03857DBF29B381C18538cf08b7E973620A1a354', ethMinPurchase => 0, privateSale => 0 },
    ];
    
    $params->{function} = 'approve';
    for ( @$members ) {
        my $data_tmp = {};
        $params->{function_params} = { _beneficiary => $_->{address}, _ethMinPurchase => $_->{ethMinPurchase} || 0, _privateSale => $_->{privateSale} || 0 };
        my $return = API::methods::eth::contract::transaction($cgi, $data_tmp, $node, $params);
        return $return unless( defined $return->{rc} && $return->{rc} == 200 );
        $data->{$_->{address}} = $data_tmp;
        $data->{$_->{address}}{'ethMinPurchase'} = $_->{ethMinPurchase};
        $data->{$_->{address}}{'privateSale'} = $_->{privateSale};
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
    my $unpaid                              = $node->contract_method_call('unpaidOf',               { '_beneficiary' => $params->{address} });
    $data->{unpaid_wei}                     = $unpaid->bstr().'';
    $data->{unpaid_eth}                     = $node->wei2ether( $unpaid )->numify();
    $data->{crowdsaleIsMember}              = \($node->contract_method_call('crowdsaleIsMemberOf',  { '_beneficiary' => $params->{address} })->numify());

    return { 'rc' => 200 };
}

sub read {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{address}                         = $contract->{address};
    $data->{block_number}                    = $contract->{block_number};
    $data->{name}                            = substr($node->contract_method_call('name'), 1);
    $data->{symbol}                          = substr($node->contract_method_call('symbol'), 1);
    $data->{decimals}                        = $node->contract_method_call('decimals')->numify();
    my $totalSupply                          = $node->contract_method_call('totalSupply');
    $data->{totalSupply_ici}                 = $totalSupply->bstr().'';
    $data->{totalSupply_ice}                 = $node->wei2ether( $totalSupply )->numify();
    $data->{memberCount}                     = $node->contract_method_call('memberCount')->numify();
    $data->{crowdsaleOpen}                   = \($node->contract_method_call('crowdsaleOpen')->numify());
    $data->{crowdsaleFinished}               = \($node->contract_method_call('crowdsaleFinished')->numify());
    $data->{crowdsalePercentOfTotalSupply}   = $node->contract_method_call('crowdsalePercentOfTotalSupply')->numify();
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
    balance($cgi, $data, $node, $params, $contract);
    
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