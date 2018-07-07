package API::methods::eth;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our Ethereum module ( Net::Ethereum 0.30 https://metacpan.org/pod/Net::Ethereum )
use modules::Ethereum;

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
    
    ########################  eth.method         ##########################
    if( $json->{meta}{postdata}{method} eq "eth" ) {
        $json->{meta}{method} = $json->{meta}{postdata}{method};
        
        my $mathBigIntOBject = $node->eth_getBalance('0x21c3ec39329b5ee1394e890842f679e93fe648bf', "latest");
        # $json->{meta}{msg} = Dumper(  );
        # $json->{meta}{msg} = $node->wei2ether( $mathBigIntOBject )->bstr(); # ->numify()
        $json->{meta}{msg} = $mathBigIntOBject->bstr();
        # $json->{meta}{msg} = $node->web3_clientVersion();
    }    
    ########################  eth.method         ##########################
    if( $json->{meta}{postdata}{method} eq "eth.method" ) {
        $json->{meta}{method} = $json->{meta}{postdata}{method};
        if ( ref($params) eq 'HASH' ) {
            # method 
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
