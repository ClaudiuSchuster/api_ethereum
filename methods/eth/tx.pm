package API::methods::eth::tx;

use strict; use warnings; use utf8; use feature ':5.10';
use Math::BigInt;


our $add_tx_receipt = sub {
    my ($data, $node, $Rresult, $Tresult) = @_;
    
    $data->{status}                 = hex($Rresult->{status});
    $data->{tx_hash}                = $Rresult->{transactionHash};
    $data->{tx_index}               = hex($Rresult->{transactionIndex});
    $data->{block_hash}             = $Rresult->{blockHash};
    $data->{block_number}           = hex($Rresult->{blockNumber});
    $data->{from}                   = $Rresult->{from};
    $data->{to}                     = $Rresult->{to};
    $data->{gas_used}               = hex($Rresult->{gasUsed});
    $data->{cumulative_gas_used}    = hex($Rresult->{cumulativeGasUsed});
    $data->{gas_price_wei}          = $node->eth_gasPrice()->numify();
    $data->{tx_cost_wei}            = $data->{gas_price_wei} * $data->{cumulative_gas_used};
    
    $data->{data}                   = $Tresult->{input}; # hex input
    my $value                       = Math::BigInt->new( $Tresult->{value} );
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
    
    my $Rresult = $node->eth_getTransactionReceipt( $params->{tx} )->{result};
    my $Tresult = $node->eth_getTransactionByHash(  $params->{tx} );
    API::methods::eth::block::byHash( $cgi, $data, $node, [$Rresult->{blockHash}, 2] );
    $add_tx_receipt->($data, $node, $Rresult, $Tresult);
    
    return { 'rc' => 200 };
}


1;
