package API::methods::eth;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our Ethereum module (Net::Ethereum 0.30)
use modules::Ethereum;

use Data::Dumper; ### DELETE after DEV

sub run {
    my $cgi = shift;
    my $json = shift;
    
    my $node = API::modules::Ethereum->new('http://127.0.0.1:854'.($API::dev?6:5).'/');
    $node->set_debug_mode(0);
    $node->set_show_progress(1);
    
    $json->{meta}{method} = $cgi->param('method');
    # $json->{meta}{msg} = Dumper(  );
    $json->{meta}{msg} = $node->web3_clientVersion();
    
    #########################################################################
    
    return {
       # data => \%dhcpd,
    };
}


1;
