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
            returnObject => ['data:eth', 'object{}', 'yes', "Contains the requested ETH Data"], #, view <a href='#eth'>method:eth</a> for description
        },
        {
            method          => "eth.contract.deploy",
            title           => "Deploy a contract",
            note            => "",
            parameterTable  => [
                ['params:name',         'string',    'true',  '',    "'name' of contract to deploy inside contracts/ folder (Same as filename/contractname without ending .sol)"],
                ['params:constructor',  'object-{}', 'false', '{ }', qq~'constructor' init parameters. e.g.: {"initString":"+ Constructor Init String +","initValue":102}~],
            ],
            requestExample  => qq~
// Generic example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"name":"HelloWorld"}}'

// Deploying IceMine.io Smart Contract:
curl http://10.10.0.8:89 -d '{"method":"eth.contract.deploy","params":{"name":"IceMine","constructor":{"_cap":2000,"_supply":10000,"_percent":60,"_wallet":"0x0acc13d0c5be1c8e8ae47c1f0363757ebef3a5d1"}}}'

                                                                                                     (_cap=HardCapETH, _supply=totalSupply, _percent:%fromTotalSupplyForICO, _wallet:targetWalletICOfunds)
            ~,
            returnDataTable => [ 'returnObject',
                ['data:eth:contract:deploy:address',        'string',   'yes', ""],
                ['data:eth:contract:deploy:tx',             'string',   'yes', ""],
                ['data:eth:contract:deploy:gas_used',       'integer',  'yes', ""],
                ['data:eth:contract:deploy:gas_price_wei',  'integer',  'yes', ""],
                ['data:eth:contract:deploy:tx_cost_wei',    'integer',  'yes', ""],
                ['data:eth:contract:deploy:tx_cost_eth',    'float',    'yes', ""],
            ],
        }
    ]);
    
    
    API::html::readme::print::ReadmeClass('endReadme',$cgi);
}


1;
