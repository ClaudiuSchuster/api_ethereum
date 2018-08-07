package API::methods::eth::contract::IceMine_Team;

use strict; use warnings; use utf8; use feature ':5.10';


sub deploy {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{constructor} = {
        _owner => '0xB7a96A6170A02e6d1FAf7D28A7821766afbc5ee3',
    } unless( $params->{constructor} );
    
    return API::methods::eth::contract::deploy($cgi, $data, $node, $params);
}

sub logs {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{address} = $contract->{address};
    $params->{fromBlock} = $contract->{block_number};
    
    return API::methods::eth::contract::logs($cgi, $data, $node, $params);
}

sub balance {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{address} = $contract->{address};
    return API::methods::eth::address::balance($cgi, $data, $node, $params);
}

sub valueInputs {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $params->{address} = $contract->{address};
    $params->{fromBlock} = $contract->{block_number};
    
    return API::methods::eth::address::valueInputs($cgi, $data, $node, $params);
}

sub read {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{address}               = $contract->{address};
    $data->{block_number}          = $contract->{block_number};
    $data->{owner}                 = $node->contract_method_call('owner');
    balance($cgi, $data, $node, $params, $contract);
    
    return { 'rc' => 200 };
}

# TEAM
# { address => '0xE1F41867532c5c5F63179c9Ec7819d8D3BF772d8', share => 12 },
# { address => '0x587f82E14ccc1176525233ec7166d2f5d19B9A17', share => 9 },
# { address => '0x79691D048AD362Fc59dEB87c6f459393Bd63B791', share => 8 },
# { address => '0xbed0bccb8398577C6920625c693602D2abaF50C6', share => 11 },


1;
