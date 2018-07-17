package API::methods::eth;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our Ethereum module ( Net::Ethereum 0.30 https://metacpan.org/pod/Net::Ethereum )
use modules::Ethereum;
## Load some more from our method modules...
use methods::eth::personal::account;
use methods::eth::tx;
use methods::eth::contract;
use methods::eth::contract::IceMine;
use methods::eth::contract::IceMine_Mining;


sub run {
    my $cgi = shift;
    my $json = shift;
    my $reqMethod = $json->{meta}{postdata}{method};

    ### Initialize Ethereum Node
    my $node;
    eval {
        $node = API::modules::Ethereum->new('http://127.0.0.1:8546/');
        $node->set_debug_mode( 1 );
        $node->set_show_progress( 1 );
        1; 
    } or do {
        return { 'rc' => 500, 'msg' => "error.initialize.eth.node: ".$@ };
    };
    
    ### Check if [subclass.function || subclass.subsubclass.function] exists before execute it.
    my ($reqPackage,$reqSubclass,$reqSubSub,$reqFunc) = ( $reqMethod =~ /^(\w+)(?:\.(\w+))?(?:\.(\w+))?(?:\.(\w+))?/ );
    my ($subclass) = grep { $reqMethod =~ /^\w+\.($_)(?:\..*)?$/ }  map /methods\/$reqPackage\/(\w+)\.pm/, keys %INC;
    if( defined $subclass ) {
        if(defined $reqFunc) {
            my ($subsubclass) = grep { $reqMethod =~ /^\w+\.\w+\.($_)(?:\..*)?$/ }  map /methods\/$reqPackage\/$subclass\/(\w+)\.pm/, keys %INC;
            if( defined $subsubclass ) {
                my @subs;
                {
                    no strict 'refs';
                    my $class = 'API::methods::'.$reqPackage.'::'.$subclass.'::'.$subsubclass.'::';
                    @subs = keys %$class;
                }
                if( grep { $_ eq $reqFunc } @subs ) {
                    $json->{meta}{method} = $reqMethod;
                    {
                        no strict 'refs';
                        my $reqFunc_run_ref = \&{"API::methods::${reqPackage}::${subclass}::${subsubclass}::${reqFunc}"};
                        my $method_run_ref = \&{"API::methods::${reqPackage}::${subclass}::run"};
                        return $method_run_ref->(
                            $cgi,
                            $json->{data},
                            $node,
                            $reqFunc,
                            $reqFunc_run_ref,
                            $subsubclass,
                            $json->{meta}{postdata}{params} || undef
                        );
                    }
                } else {
                    return {'rc'=>400,'msg'=>"Requested function '".($reqFunc || '')."' does not exist in package '$reqPackage.$subclass.$subsubclass' (class.subclass.[function|subsubclass.function]). Abort!"};
                }
            } else {
                return {'rc'=>400,'msg'=>"Requested function|subsubclass '".($reqSubSub || '')."' does not exist in package '$reqPackage.$subclass' (class.subclass.[function|subsubclass.function]). Abort!"};
            }
        } else {
            $reqFunc = $reqSubSub;
            my @subs;
            {
                no strict 'refs';
                my $class = 'API::methods::'.$reqPackage.'::'.$subclass.'::';
                @subs = keys %$class;
            }
            if( defined $reqFunc && grep { $_ eq $reqFunc } @subs ) {
                $json->{meta}{method} = $json->{meta}{postdata}{method};
                {
                    no strict 'refs';
                    my $method_run_ref = \&{"API::methods::${reqPackage}::${subclass}::${reqFunc}"};
                    return $method_run_ref->(
                        $cgi,
                        $json->{data},
                        $node,
                        $json->{meta}{postdata}{params} || undef
                    );
                }
            } else {
                return {'rc'=>400,'msg'=>"Requested function '".($reqFunc || '')."' does not exist in package '$reqPackage.$subclass' (class.subclass.[function|subsubclass.function]). Abort!"};
            }
        }
    } else {
            return {'rc'=>400,'msg'=>"Requested subclass '".($reqSubclass || '')."' does not exist in class '$reqPackage' (class.subclass.[function|subsubclass.function]). Abort!"};
    }
    
}


1;
