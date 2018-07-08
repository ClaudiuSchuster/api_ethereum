package API::html::readme;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our readme modules
use html::readme::print;

sub print { 
    my $cgi = shift;
    
    API::html::readme::print::ReadmeClass('introduction',$cgi,' - ethereum.spreadblock.local',[]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth',
            returnObject => ['data:eth', 'object{}', 'yes', "Contains ETH Data, view <a href='#eth'>method:eth</a> for description"]
        },
        {
            method          => "eth",
            title           => "Get ETH data",
            note            => "What a cool Note!",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -X POST -d '{"method":"eth"}'
            ~,
            returnDataTable => [ 'returnObject' ],
        },
        {
            method          => "eth.method",
            title           => "Do eth.method",
            note            => "What a cool Note!",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -X POST -d '{"method":"eth.method"}'
            ~,
            returnDataTable => [ 'returnObject' ],
        }
    ]);
    
    
    API::html::readme::print::ReadmeClass('endReadme',$cgi);
}


1;
