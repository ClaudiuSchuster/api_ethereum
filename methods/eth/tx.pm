package API::methods::eth::tx;

use strict; use warnings; use utf8; use feature ':5.10';
use Math::BigInt;


our $add_tx_receipt = sub {
    my ($data, $node, $resultR, $resultT) = @_;
    
    $data->{status}                 = hex($resultR->{status});
    $data->{tx_hash}                = $resultR->{transactionHash};
    $data->{tx_index}               = hex($resultR->{transactionIndex});
    $data->{block_hash}             = $resultR->{blockHash};
    $data->{block_number}           = hex($resultR->{blockNumber});
    $data->{from}                   = $resultR->{from};
    $data->{to}                     = $resultR->{to};
    $data->{gas_used}               = hex($resultR->{gasUsed});
    $data->{cumulative_gas_used}    = hex($resultR->{cumulativeGasUsed});
    $data->{gas_price_wei}          = $node->eth_gasPrice()->numify();
    $data->{tx_cost_wei}            = $data->{gas_price_wei} * $data->{cumulative_gas_used};
    
    $data->{gas_provided}           = hex($resultT->{gas});
    $data->{data}                   = $resultT->{input}; # hex input
    my $value                       = Math::BigInt->new( $resultT->{value} );
    $data->{value_wei}              = $value->bstr().'';
    $data->{value_eth}              = $node->wei2ether($value)->numify();
};

sub gasprice {
    my ($cgi, $data, $node, $params) = @_;
    
    $data->{gas_price_wei} = $node->eth_gasPrice()->numify();
    
    return { 'rc' => 200 };
}

sub receipt {
    my ($cgi, $data, $node, $params) = @_;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params && ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'tx' hash needed. Abort!" }
        unless( $params->{tx} );
    
    my $resultR = $node->eth_getTransactionReceipt( $params->{tx} );
    my $resultT = $node->eth_getTransactionByHash(  $params->{tx} );
    $add_tx_receipt->($data, $node, $resultR->{result}, $resultT);
    
    return { 'rc' => 200 };
}


1;
