package API::methods::eth;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our Ethereum module ( Net::Ethereum 0.30 https://metacpan.org/pod/Net::Ethereum )
use modules::Ethereum;
## Load some more from our method modules...
use methods::eth::personal::account;
use methods::eth::contract;


sub run {
    my $cgi = shift;
    my $json = shift;

    ### Check if subclass and requested function exists before initialize node and execute it.
    my ($reqPackage,$reqSubclass,$reqFunc) = ( $json->{meta}{postdata}{method} =~ /^(\w+)(?:\.(\w+))?(?:\.(\w+))?/ );
    my ($subclass) = grep { $json->{meta}{postdata}{method} =~ /^\w+\.($_)(?:\..*)?$/ }  map /methods\/$reqPackage\/(\w+)\.pm/, keys %INC;
    if( defined $subclass ) {
        my ($subclass_func) = ($json->{meta}{postdata}{method} =~ /^$reqPackage\.$subclass\.(\w+)/);
        my @subs;
        {
            no strict 'refs';
            my $class = 'API::methods::'.$reqPackage.'::'.$subclass.'::';
            @subs = keys %$class;
        }
        if( defined $subclass_func && grep { $_ eq $subclass_func } @subs ) {
            $json->{meta}{method} = $json->{meta}{postdata}{method};
            my $node;
            eval { # Initialize Ethereum Node
                $node = API::modules::Ethereum->new('http://127.0.0.1:854'.($API::dev?6:5).'/');
                $node->set_debug_mode( 1 );
                $node->set_show_progress( 1 );
                1; 
            } or do {
                return { 'rc' => 500, 'msg' => "error.initialize.eth.node: ".$@ };
            };
            {
                no strict 'refs';
                my $method_run_ref = \&{"API::methods::${reqPackage}::${subclass}::${subclass_func}"};
                return $method_run_ref->(
                    $cgi,
                    \%{$json->{data}{$reqPackage}{$subclass}{$subclass_func}},
                    $node,
                    $json->{meta}{postdata}{params} || undef
                );
            }
        } else {
            return {'rc'=>400,'msg'=>"Requested function '".($reqFunc || '')."' does not exist in package '$reqPackage.$subclass' (class.subclass.function). Abort!"};
        }
    } else {
            return {'rc'=>400,'msg'=>"Requested subclass '".($reqSubclass || '')."' does not exist in class '$reqPackage' (class.subclass.function). Abort!"};
    }
    
}


1;
