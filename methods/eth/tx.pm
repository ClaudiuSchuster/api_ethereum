package API::methods::eth::tx;

use strict; use warnings; use utf8; use feature ':5.10';


our $add_tx_receipt = sub {
    my ($data, $node, $result) = @_;
    
    $data->{status}                 = hex($result->{status});
    $data->{tx}                     = $result->{transactionHash};
    $data->{txIndex}                = hex($result->{transactionIndex});
    $data->{block_hash}             = $result->{blockHash};
    $data->{block_number}           = hex($result->{blockNumber});
    $data->{from}                   = $result->{from};
    $data->{to}                     = $result->{to};
    $data->{gas_used}               = hex($result->{gasUsed});
    $data->{cumulative_gas_used}    = hex($result->{cumulativeGasUsed});
    $data->{gas_price_wei}          = $node->eth_gasPrice()->numify();
    $data->{tx_cost_wei}            = $data->{gas_price_wei} * $data->{cumulative_gas_used};
    $data->{tx_cost_eth}            = $node->wei2ether($data->{tx_cost_wei})->numify();
};

sub receipt {
    my ($cgi, $data, $node, $params) = @_;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params && ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'tx' hash needed. Abort!" }
        unless( $params->{tx} );
    
    my $result = $node->eth_getTransactionReceipt( $params->{tx} );
    $add_tx_receipt->($data, $node, $result->{result});
    
    return { 'rc' => 200 };
}


1;
