package API::methods::eth::contract;

use strict; use warnings; use utf8; use feature ':5.10';


sub deploy {
    my $cgi=shift; my $json=shift; my $data=shift; my $node=shift;
    
    my $params = $json->{meta}{postdata}{params} || undef;
    unless( ref($params) eq 'HASH' ) {
        return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" };
    } else {
        unless( $params->{name} ) {
            return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'name' of contract to deploy is needed!" };
        }
    }

    unless( -e 'contracts/'.$params->{name}.'.sol' ) {
        return { 'rc' => 400, 'msg' => "Contract 'contracts/$params->{name}.sol' not found. Abort!" };
    }

    my $contract_status;
    eval {
        $contract_status = $node->compile_and_deploy_contract(
            $params->{name},
            {   # Constructor Params
                initString => '+ IceMine.io - The One And Only +',
                initValue  => 102,
            },
            API::methods::eth::personal::account::address,
            API::methods::eth::personal::account::password
        ); 1; 
    } or do {
        return { 'rc' => 500, 'msg' => "error.eth.contract.deploy: ".$@ };
    };
    my $address     = $contract_status->{contractAddress};
    my $txhash      = $contract_status->{transactionHash};
    my $gas_used    = hex($contract_status->{gasUsed});
    my $gas_price   = $node->eth_gasPrice();
    my $tx_cost_wei = $gas_used * $gas_price;
    my $tx_cost_eth = $node->wei2ether($tx_cost_wei);
    $data->{address}       = $address;
    $data->{tx}            = $txhash;
    $data->{tx_cost_wei}   = $tx_cost_wei->numify();
    $data->{tx_cost_eth}   = $tx_cost_eth->numify();
    $data->{gas_price_wei} = $gas_price->numify();
    $data->{gas_used}      = $gas_used;
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