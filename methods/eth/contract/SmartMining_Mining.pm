package API::methods::eth::contract::SmartMining_Mining;

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

sub read {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    $data->{address}               = $contract->{address};
    $data->{block_number}          = $contract->{block_number};
    $data->{owner}                 = $node->contract_method_call('owner');
    $data->{withdrawal_address}    = $node->contract_method_call('WITHDRAWAL_ADDRESS');
    $data->{distribution_contract} = $node->contract_method_call('DISTRIBUTION_CONTRACT');
    $data->{oraclize_query}        = $node->contract_method_call('ORACLIZE_QUERY');
    balance($cgi, $data, $node, $params, $contract);
    
    return { 'rc' => 200 };
}

# sub valueInputs {
    # my ($cgi, $data, $node, $params, $contract) = @_;
    
    # $params->{address} = $contract->{address};
    # $params->{fromBlock} = $contract->{block_number};
    
    # return API::methods::eth::address::valueInputs($cgi, $data, $node, $params);
# }

# sub withdraw {
    # my ($cgi, $data, $node, $params, $contract) = @_;
    
    # return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' of _beneficiary needed. Abort!" }
        # unless( $params->{address} );
        
    # return { 'rc' => 400, 'msg' => "Member '$params->{address}' has no unpaid_wei. Abort!" }
        # unless( $node->contract_method_call('unpaidOf', { '_beneficiary' => $params->{address} })->bgt(0) );
    
    # $params->{function} = 'withdrawOf';
    # $params->{function_params} = {
        # _beneficiary => $params->{address}
    # };
    
    # return API::methods::eth::contract::transaction($cgi, $data, $node, $params);
# }


1;
