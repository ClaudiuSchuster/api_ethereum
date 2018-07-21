package API::methods::eth::block;

use strict; use warnings; use utf8; use feature ':5.10';
use Math::BigInt;


my $check_basics = sub {
    my $params = shift;
    
    return { 'rc' => 400, 'msg' => "No 'params' array[] for block_number / block_hash submitted. Abort!" }
        unless( defined $params && ref($params) eq 'ARRAY' );
    return { 'rc' => 400, 'msg' => "Insufficient arguments submitted. Abort!" }
        unless( $params->[0] );
        
    return { 'rc' => 200 };
};

my $get_block = sub {
    my ($data, $node, $raw_block, $FullTxOrHashOrNothing) = @_;
    
    # $data->{raw_block}       = $raw_block;
    $data->{block_hash}            = $raw_block->{hash};
    $data->{block_number}          = hex($raw_block->{number});
    $data->{gas_used}         = hex($raw_block->{gasUsed});
    $data->{gas_limit}        = hex($raw_block->{gasLimit});
    $data->{miner}           = $raw_block->{miner};
    $data->{parent_hash}      = $raw_block->{parentHash};
    $data->{size}            = hex($raw_block->{size});
    $data->{timestamp}       = hex($raw_block->{timestamp});
    $data->{difficulty}      = hex($raw_block->{difficulty});
    $data->{difficulty_total} = hex($raw_block->{totalDifficulty});
    
    
    if($FullTxOrHashOrNothing) {
        $data->{transactions} = [];
        for ( @{$raw_block->{transactions}} ) {
            my $tx = {};
            $tx->{tx_hash}      = $_->{hash};
            $tx->{tx_index}     = $_->{transactionIndex};
            $tx->{data}         = $_->{input}; # hex input
            $tx->{gas_provided} = hex($_->{gas});
            $tx->{to}           = $_->{to};
            $tx->{from}         = $_->{from};
            my $value           = Math::BigInt->new( $_->{value} );
            $tx->{value_wei}    = $value->bstr().'';
            $tx->{value_eth}    = $node->wei2ether($value)->numify();
            $tx->{block_hash}   = $_->{blockHash};
            $tx->{block_number} = hex($_->{blockNumber});
            
            push(@{$data->{transactions}}, $tx) unless($FullTxOrHashOrNothing == 2);
        }
    } else {
        $data->{transactions} = $raw_block->{transactions};
    }    
    
    return { 'rc' => 200 };
};

sub byNumber {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    my $raw_block = $node->eth_getBlockByNumber($params->[0], $params->[1]);
    
    return $get_block->($data, $node, $raw_block, $params->[1])
}

sub byHash {
    my ($cgi, $data, $node, $params) = @_;
    
    my $checks = $check_basics->($params);
    return $checks unless( defined $checks->{rc} && $checks->{rc} == 200 );
    
    my $raw_block = $node->eth_getBlockByHash($params->[0], $params->[1]);
    
    return $get_block->($data, $node, $raw_block, $params->[1])
}


1;
