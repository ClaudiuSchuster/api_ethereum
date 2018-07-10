package API::methods::eth;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our Ethereum module ( Net::Ethereum 0.30 https://metacpan.org/pod/Net::Ethereum )
use modules::Ethereum;
## Load some more from our modules...
use methods::eth::personal::account;

use Data::Dumper; ### DELETE after DEV

sub run {
    my $cgi = shift;
    my $json = shift;
    ####################  Initialize some stuff...  #########################
    $json->{meta}{method} = $json->{meta}{postdata}{method} if($json->{meta}{postdata}{method} eq 'eth');
    my $params = $json->{meta}{postdata}{params} || undef;
    my $eth = {};
    #################  Initialize our Ethereum Node  ########################
    my $node = API::modules::Ethereum->new('http://127.0.0.1:854'.($API::dev?6:5).'/');
    $node->set_debug_mode(1);
    $node->set_show_progress(1);
    
    #########################################################################  eth
    if( $json->{meta}{postdata}{method} eq "eth" ) {
        $json->{meta}{method} = $json->{meta}{postdata}{method};
        
        my $mathBigIntOBject = $node->eth_getBalance( API::methods::eth::personal::account::address, 'latest' );
        # $json->{meta}{msg} = Dumper(  );
        # $json->{meta}{msg} = $node->wei2ether( $mathBigIntOBject )->bstr(); # ->numify()
        $json->{meta}{msg} = $mathBigIntOBject->bstr();
        # $json->{meta}{msg} = $node->web3_clientVersion();
    }    
    #########################################################################  eth.contract.deploy
    elsif( $json->{meta}{postdata}{method} eq "eth.contract.deploy" ) {
        $json->{meta}{method} = $json->{meta}{postdata}{method};
        if ( ref($params) eq 'HASH' ) {
            unless( $params->{name} ) {
                $json->{meta}{rc}  = 400;
                $json->{meta}{msg} = "Insufficient arguments submitted: 'name' of contract to deploy is needed!";
            } else {
                if( -e 'contracts/'.$params->{name}.'.sol' ) {
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
                        $json->{meta}{rc}  = 500;
                        $json->{meta}{msg} = 'error.eth.contract.deploy: '.$@;
                    };
                    if( $json->{meta}{rc} == 200 ) {
                        my $address     = $contract_status->{contractAddress};
                        my $txhash      = $contract_status->{transactionHash};
                        my $gas_used    = hex($contract_status->{gasUsed});
                        my $gas_price   = $node->eth_gasPrice();
                        my $tx_cost_wei = $gas_used * $gas_price;
                        my $tx_cost_eth = $node->wei2ether($tx_cost_wei);
                        $eth->{contract}{deploy}{address}       = $address;
                        $eth->{contract}{deploy}{tx}            = $txhash;
                        $eth->{contract}{deploy}{tx_cost_wei}   = $tx_cost_wei->numify();
                        $eth->{contract}{deploy}{tx_cost_eth}   = $tx_cost_eth->numify();
                        $eth->{contract}{deploy}{gas_price_wei} = $gas_price->numify();
                        $eth->{contract}{deploy}{gas_used}      = $gas_used;
                    }
                } else {
                    $json->{meta}{rc}  = 400;
                    $json->{meta}{msg} = "Contract 'contracts/$params->{name}.sol' not found. Abort!";
                }
            }
        } else {
            $json->{meta}{rc}  = 400;
            $json->{meta}{msg} = "No 'params' object{} for method-parameter submitted. Abort!";
        }
    }
    
    #########################################################################
    
    return {
       data => $eth,
    };
}


1;
