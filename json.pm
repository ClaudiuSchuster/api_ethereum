package API::json;

use strict; use warnings; use utf8; use feature ':5.10';

use JSON;

### Load our api-method modules. Note: Modules must have a run() function!
use methods::eth;


### Create and print the JSON Object
sub print { 
    my $cgi = shift;
    
    ### Initialize JSON structure
    my $json = {
        meta => {
            rc => 200,
            msg => undef,
            method => undef,
            postdata => undef
        },
        data => {}
    };
    eval { $json->{meta}{postdata} = decode_json( $cgi->param('POSTDATA') || "{}" ); 1; } or do { 
        $json->{meta}{rc}  = 400;
        $json->{meta}{msg} = 'error.decode_json: '.$@;
    };
    
    ### Check if module for requested method is loaded, execute the method and fill the data{}-object
    if( $json->{meta}{postdata}{method} ) {
        my ($method) = grep { $json->{meta}{postdata}{method} =~ /^($_|$_(\.\w+)*)$/ }  map /methods\/(\w+)\.pm/, keys %INC;
        if( defined $method ) {
            {
                no strict 'refs';
                my $method_run_ref = \&{"API::methods::${method}::run"};
                my $method_run_result = $method_run_ref->($cgi,$json);
                $json->{'data'}{$method} = $method_run_result->{data};
            }
            $json->{'data'}{$method} = {} if( $json->{meta}{postdata}{nodata} );
        } else {
            my ($reqPackage) = ( $json->{meta}{postdata}{method} =~ /^(\w+)\.?.*/ );
            $json->{meta}{rc}  = 400;
            $json->{meta}{msg} = "Requested method class '".($reqPackage || '')."' (class.subclass.function) does not exist. Abort!";
        }
    }
    
    ### Print JSON object
    print $cgi->header('application/json'), JSON->new->pretty->encode($json);
}


1;
