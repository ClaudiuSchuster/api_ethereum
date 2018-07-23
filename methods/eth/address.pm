package API::methods::eth::address;

use strict; use warnings; use utf8; use feature ':5.10';


my $check_basics = sub {
    my $params = shift;
    
    return { 'rc' => 400, 'msg' => "No 'params' object{} for method-parameter submitted. Abort!" }
        unless( defined $params && ref($params) eq 'HASH' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'address' needed. Abort!" }
        unless( $params->{address} );
        
    return { 'rc' => 200 };
};

sub balance {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    my $balance_wei         = $node->eth_getBalance($params->{address}, "latest");
    $data->{balance_wei}    = $balance_wei->bstr().'';
    $data->{balance_eth}    = $node->wei2ether( $balance_wei )->numify();
    
    return { 'rc' => 200 };
}

sub valueInputs {
    my ($cgi, $data, $node, $params, $contract) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted: 'fromBlock' needed. Abort!" }
        unless( defined $params->{fromBlock} );
    unless( defined $params->{toBlock} ) {
        my $block = {}; # $block->{block_number} for current block
        API::methods::eth::node::block({}, $block, $node);
        $params->{toBlock} = $block->{block_number} 
    }
    
    my $totalInput = Math::BigInt->new( 0 );
    my @transactions;
    for ( $params->{fromBlock}..$params->{toBlock} ) {
        my $block = {};
        API::methods::eth::block::byNumber( $cgi, $block, $node, [$_, 1] );
        for my $tx ( @{$block->{transactions}} ) {
            if( defined $tx->{to} && $tx->{to} eq $params->{address} && ($tx->{value_wei} ne '0' || $params->{showempty} )
              && (!defined $params->{from} || defined $params->{from} && $params->{from} eq $tx->{from}) ) {
                my $receiptParams->{tx} = $tx->{tx_hash};
                my $receipt = {};
                API::methods::eth::tx::receipt($cgi, $receipt, $node,$receiptParams);
                $totalInput->badd($tx->{value_wei}) if( $receipt->{status} );
                push @transactions, {
                    receipt => $params->{showreceipt} ? $receipt : {},
                    from => $tx->{from},
                    value_wei => $tx->{value_wei},
                    value_eth => $tx->{value_eth},
                    gas_provided => $tx->{gas_provided},
                    tx_hash => $tx->{tx_hash},
                    tx_index => $tx->{tx_index},
                    block_hash => $block->{block_hash},
                    block_number => $block->{block_number},
                    timestamp => $block->{timestamp},
                } if( $params->{showfailed} || $receipt->{status} );
            }
        }
    }
    
    $data->{total_wei}    = $totalInput->bstr();
    $data->{total_eth}    = $node->wei2ether( $totalInput )->numify();
    $data->{tx_count}     = scalar @transactions;
    $data->{transactions} = \@transactions;
    
    return { 'rc' => 200 };
}


1;
