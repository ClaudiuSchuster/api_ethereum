package API::methods::eth::contract;

use strict; use warnings; use utf8; use feature ':5.10';


sub deploy {
    my $cgi=shift; my $json=shift; my $data=shift; my $node=shift;
    
    my $params = $json->{meta}{postdata}{params} || undef;
    unless( ref($params) eq 'HASH' ) {
        return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" };
    } else {
        unless( $params->{name} ) {
            return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'name' of contract to deploy is needed. Abort!" };
        }
        if( defined $params->{constructor} && ref($params->{constructor}) ne 'HASH' ) {
            return { 'rc' => 400, 'msg' => "Argument 'constructor' must be an object-{}. Abort!" };
        }
    }

    unless( -e 'contracts/'.$params->{name}.'.sol' ) {
        return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{name}.sol' not found. Abort!" };
    }

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
}

sub test {
    my $cgi=shift; my $json=shift; my $data=shift; my $node=shift;
    my $mathBigIntOBject = $node->eth_getBalance( API::methods::eth::personal::account::address, 'latest' );
    # $json->{meta}{msg} = Dumper(  );
    # $json->{meta}{msg} = $node->wei2ether( $mathBigIntOBject )->bstr(); # ->numify()
    $json->{meta}{msg} = $mathBigIntOBject->bstr();
    # $json->{meta}{msg} = $node->web3_clientVersion();
}


1;