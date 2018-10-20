package API::methods::eth::contract::CMR_Mining;

use strict; use warnings; use utf8; use feature ':5.10';

use Math::BigInt;

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

sub memberIndex {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{memberIndex} = [];
    my $memberCount = $node->contract_method_call('memberCount')->numify();
    for ( 0..($memberCount-1) ) {
        push @{$data->{memberIndex}}, $node->contract_method_call('memberIndex', { '' => $_ });
    }

    return { 'rc' => 200 };
}

sub member {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' of _beneficiary needed. Abort!" }
        unless( $params->{address} );
    
    $data->{share}      = $node->contract_method_call('shareOf',    { '_member' => $params->{address} })->numify();
    my $unpaid          = $node->contract_method_call('unpaidOf',   { '_member' => $params->{address} });
    $data->{unpaid_wei} = $unpaid->bstr().'';
    $data->{unpaid_eth} = $node->wei2ether( $unpaid )->numify();
    
    
    my $logData = {};
    logs($cgi, $logData, $node, { contract => $params->{contract}, topic => 'Withdraw(address,uint256)', topics => [ $params->{address} ] }, $contract);
    
    $data->{withdrawalCount} = $logData->{log_count};
    my $withdrawed = Math::BigInt->new();
    for ( @{$logData->{logs}} ) {
        $withdrawed->badd( $_->{event_data}{value} );  
    }
    $data->{withdrawed_wei} = $withdrawed->bstr().'';
    $data->{withdrawed_eth} = $node->wei2ether( $withdrawed )->numify();
    
    my $total = $withdrawed->badd( $unpaid );
    $data->{total_wei} = $total->bstr().'';
    $data->{total_eth} = $node->wei2ether( $total )->numify();

    return { 'rc' => 200 };
}

sub read {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{address}               = $contract->{address};
    $data->{contract_block_number} = $contract->{block_number};
    $data->{current_block_number}  = $node->eth_blockNumber();
    $data->{memberCount}           = $node->contract_method_call('memberCount')->numify();
    memberIndex($cgi, $data, $node, $params, $contract);
    balance($cgi, $data, $node, $params, $contract);
    
    my $block = {};
    my $return = API::methods::eth::block::byNumber($cgi, $block, $node, [$data->{current_block_number}, 2]);
    return $return unless( $return->{rc} == 200 );
    $data->{timestamp} = $block->{timestamp};
    
    for ( @{$data->{memberIndex}} ) {
        $data->{members}{$_} = {};
        member($cgi, $data->{members}{$_}, $node, { contract => $params->{contract}, address => $_ }, $contract);
    }
    
    my $logData = {};
    logs($cgi, $logData, $node, { contract => $params->{contract}, topic => 'Deposit(address,uint256)' }, $contract);
    
    $data->{depositCount} = $logData->{log_count};
    my $deposited = Math::BigInt->new();
    for ( @{$logData->{logs}} ) {
        $deposited->badd( $_->{event_data}{value} );  
    }
    $data->{deposited_wei} = $deposited->bstr().'';
    $data->{deposited_eth} = $node->wei2ether( $deposited )->numify();
    
    return { 'rc' => 200 };
}

# Members:
# (0xd2Ce719a0d00f4f8751297aD61B0E936970282E1, 50)
# (0xE517CB63e4dD36533C26b1ffF5deB893E63c3afA, 25)
# (0x430e1dd1ab2E68F201B53056EF25B9e116979D9b, 25)


1;
