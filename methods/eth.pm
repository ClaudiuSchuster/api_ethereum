package API::methods::eth;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our Ethereum module ( Net::Ethereum 0.30 https://metacpan.org/pod/Net::Ethereum )
use modules::Ethereum;
## Load some more from our modules...
use methods::eth::personal::account;
use methods::eth::contract;


sub run {
    my $cgi = shift;
    my $json = shift;
    my $eth = {};
    
    
    ### Check if subclass and requested function exists before initialize node and execute it.
    my ($reqPackage,$reqSubclass,$reqFunc) = ( $json->{meta}{postdata}{method} =~ /(\w+)\.(\w+)\.(\w+)/ );
    my ($subclass) = grep { $json->{meta}{postdata}{method} =~ /^\w+\.($_)(\.\w+)?$/ }  map /methods\/eth\/(\w+)\.pm/, keys %INC;
    if( defined $subclass ) {
        my $subclass_func = $1 if( $json->{meta}{postdata}{method} =~ /^eth\.contract\.(\w+)/ );
        my @subs;
        {
            no strict 'refs';
            my $class = 'API::methods::'.$reqPackage.'::'.$subclass.'::';
            @subs = keys %$class;
        }
        if( grep { $_ eq $subclass_func } @subs ) {
            $json->{meta}{method} = $json->{meta}{postdata}{method};
            
            ### Initialize Ethereum Node
            my $node = API::modules::Ethereum->new('http://127.0.0.1:854'.($API::dev?6:5).'/');
            $node->set_debug_mode(1);
            $node->set_show_progress(1);
            
            {
                no strict 'refs';
                my $method_run_ref = \&{"API::methods::eth::${subclass}::${subclass_func}"};
                my $method_run_result = $method_run_ref->($cgi,$json,$eth,$node);
                if( ref($method_run_result) eq 'HASH' ) {
                    $json->{meta}{rc}  = $method_run_result->{rc};
                    $json->{meta}{msg} = $method_run_result->{msg};
                }
            }
            
        } else {
            $json->{meta}{rc}  = 400;
            $json->{meta}{msg} = "Requested function '".($reqFunc || '')."' does not exist in package '$reqPackage.$subclass'. Abort!";
        }
    } else {
            $json->{meta}{rc}  = 400;
            $json->{meta}{msg} = "Requested class '".($reqSubclass || '')."' does not exist in package '".($reqPackage || '')."'. Abort!";
    }
    
    ###
    return {
       data => $eth,
    };
}


1;
