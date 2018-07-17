package API::html::readme;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our readme modules
use html::readme::print;

sub print { 
    my $cgi = shift;
    
    API::html::readme::print::ReadmeClass('introduction',$cgi,' - ethereum.spreadblock.local',['eth.contract','eth.address','eth.tx']);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.contract',
            returnObject => ['data', 'object{}', 'yes', "object-{} contains the requested data"],
        },
        {
            method          => "eth.contract.*.deploy",
            title           => "Deploy a contract (specific)",
            note            => "",
            parameterTable  => [
                ['params:contract',     'string',    'false',  '',    "Name of 'contract' to deploy inside contracts/ folder (Same as filename/contractname without ending .sol)"],
                ['params:constructor',  'object-{}', 'false', '{ }', qq~'constructor' init parameters. e.g.: {"initString":"+ Constructor Init String +","initValue":102}~],
            ],
            requestExample  => qq~
// Deploy constract 'IceMine' with constructor from IceMine.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.deploy"}'
            ~,
            returnDataTable => [ 'returnObject',
                ['data:address',        'string',   'yes', "Contract address"],
                ['data:tx',             'string',   'yes', "Deployment transaction hash"],
                ['data:tx_cost_wei',    'string',   'yes', "tx cost in Wei"],
                ['data:tx_cost_eth',    'float',    'yes', "tx cost in ETH"],
                ['data:gas_used',       'integer',  'yes', "gas amount used"],
                ['data:gas_price_wei',  'integer',  'yes', "price per gas amount"],
            ],
        },
        {
            method          => "eth.contract.deploy",
            title           => "Deploy a contract (generic)",
            note            => "",
            parameterTable  => [
                ['params:contract',     'string',    'true',  '',    "Name of 'contract' to deploy inside contracts/ folder (Same as filename/contractname without ending .sol)"],
                ['params:constructor',  'object-{}', 'false', '{ }', qq~'constructor' init parameters. e.g.: {"initString":"+ Constructor Init String +","initValue":102}~],
            ],
            requestExample  => qq~
// Generic example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"HelloWorld"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"myToken","constructor":{"_totalSupply":2000}}}'

// Deploy IceMine Smart Contract:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"IceMine","constructor":{"_cap":2000,"_wallet":"0x0acc13d0c5be1c8e8ae47c1f0363757ebef3a5d1","_owner":"0x0"}}}'
            ~,
            returnDataTable => [ 'returnObject',
                ['data:*',        '*',   '*', "view specific method <a href='#eth.contract.*.deploy'>method:eth.contract.*.deploy</a> for returndata"],
            ],
        },
        {
            method          => "eth.contract.*.read",
            title           => "Read Contract (specific)",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'IceMine'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.read"}'
            ~,
            returnDataTable => [ 'returnObject',
                ['data:address',                        'string',   'yes', "Contract address"],
                ['data:owner',                          'string',   'yes', "Contract owner address"],
                ['data:name',                           'string',   'yes', "EIP-20 name"],
                ['data:symbol',                         'string',   'yes', "EIP-20 symbol"],
                ['data:decimals',                       'integer',  'yes', "EIP-20 decimals"],
                ['data:totalSupply',                    'string',   'yes', "EIP-20 totalSupply"],
                ['data:totalSupply_Ice',                'float',    'yes', "totalSupply(Ici) in ICE"],
                ['data:memberCount',                    'integer',  'yes', "Count of all IceMine members inclusive the team"],
                ['data:crowdsalePercentOfTotalSupply',  'integer',  'yes', "Percent of totalSupply which will be available for Crowdsale"],
                ['data:withdrawer',                     'string',   'yes', "Address of allowed executor for automatic processed member whitdrawals"],
                ['data:depositor',                      'string',   'yes', "Address of allowed depositor of mining profits"],
                ['data:crowdsaleWallet',                'string',   'yes', "Address where crowdsale funds are collected"],
                ['data:percentMultiplier',              'string',   'yes', "Percent of totalSupply which will be available for Crowdsale"],
                ['data:crowdsaleRemainingWei',          'string',   'yes', "Remeining Wei to buy in crowdsale"],
                ['data:crowdsaleRemainingWei_Eth',      'float',    'yes', "Remeining ETH to buy in crowdsale"],
                ['data:crowdsaleSupply',                'string',   'yes', "Remaining amount of totalSupply (Ici) which will be available for Crowdsale"],
                ['data:crowdsaleSupply_Ice',            'float',    'yes', "Remaining amount of totalSupply in ICE which will be available for Crowdsale"],
                ['data:crowdsaleRemainingToken',        'string',   'yes', "Remaining Ici for purchase in crowdsale"],
                ['data:crowdsaleRemainingToken_Ice',    'float',    'yes', "Remaining ICE for purchase in crowdsale"],
                ['data:crowdsaleRaised_Wei',            'string',   'yes', "Amount of wei raised in crowdsale in Wei"],
                ['data:crowdsaleRaised_Eth',            'float',    'yes', "Amount of wei raised in crowdsale in ETH"],
                ['data:crowdsaleCap',                   'string',   'yes', "Wei after crowdsale is finished"],
                ['data:crowdsaleCap_Eth',               'float',    'yes', "ETH after crowdsale is finished"],
                ['data:crowdsaleCalcToken_1wei',        'integer',  'yes', "Ici (10**-18 ICE) amount in crowdsale for 1 Wei"],
                ['data:crowdsaleInitialized',           'bool',     'yes', "true after owner initialized the contract"],
                ['data:crowdsaleOpen',                  'bool',     'yes', "true if crowdsale is open for investors"],
                ['data:crowdsaleFinished',              'bool',     'yes', "true after crowdsaleCap was reached"],
            ],
        },
        {
            method          => "eth.contract.read",
            title           => "Read Contract (generic)",
            note            => "",
            parameterTable  => [
                ['params:contract',     'string',    'true',  '',    "Name of 'contract'"],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.read","params":{"contract":"IceMine"}}'
            ~,
            returnDataTable => [ 'returnObject',
                ['data:*',        '*',   '*', "view specific method <a href='#eth.contract.*.read'>method:eth.contract.*.read</a> for returndata"],
            ],
        },
        {
            method          => "eth.contract.*.member",
            title           => "Read Member-Info from Contract (specific)",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',    'true',  '',   "'address' of member"],
            ],
            requestExample  => qq~
// use contract 'IceMine'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.member","params":{"address":"0x21c3ec39329b5EE1394E890842f679E93FE648bf"}}'
            ~,
            returnDataTable => [ 'returnObject',
                ['data:crowdsaleIsMember',          'bool',     'yes', "true if address is member of Contract"],
                ['data:unpaid',                     'string',   'yes', "Unpaid Wei amount"],
                ['data:unpaid_Eth',                 'float',    'yes', "Unpaid ETH amount"],
                ['data:balance',                    'string',   'yes', "Ici balance"],
                ['data:balance_Ice',                'float',    'yes', "ICE balance"],
                ['data:percentTotal',               'string',   'yes', "percentTotal as in contract (use 'percentMultiplier')"],
                ['data:percentTotal_float',         'float',    'yes', "percentTotal as float representative"],
                ['data:crowdsalePercent',           'string',   'yes', "crowdsalePercent as in contract (use 'percentMultiplier')"],
                ['data:crowdsalePercent_float',     'float',    'yes', "crowdsalePercent as float representative"],
                ['data:crowdsaleInvestment',        'string',   'yes', "Invested Wei into crowdsale"],
                ['data:crowdsaleInvestment_Eth',    'float',    'yes', "Invested ETH into crowdsale"],
            ],
        },
        
        
        
        # {
            # method          => "eth.contract.*.TEMPLATE",
            # title           => "TEMPLATE (specific)",
            # note            => "",
            # parameterTable  => [
                # ['params:TEMPLATE',      'string',    'true',  '',   "'TEMPLATE' of member"],
            # ],
            # requestExample  => qq~
# // use contract 'IceMine'
# curl http://$ENV{HTTP_HOST} -d 
            # ~,
            # returnDataTable => [ 'returnObject',
                # ['data:TEMPLATE', 'string', 'yes', ""],
            # ],
        # },
        # {
            # method          => "eth.contract.TEMPLATE",
            # title           => "TEMPLATE (generic)",
            # note            => "",
            # parameterTable  => [
                # ['params:contract',   'string',    'true',  '',   "Name of 'contract'"],
                # ['params:TEMPLATE',      'string',    'true',  '',   "'TEMPLATE' of member"],
            # ],
            # requestExample  => qq~
# curl http://$ENV{HTTP_HOST} -d 
            # ~,
            # returnDataTable => [ 'returnObject',
                # ['data:*',        '*',   '*', "view specific method <a href='#eth.contract.*.TEMPLATE'>method:eth.contract.*.TEMPLATE</a> for returndata"],
            # ],
        # }
        
    ]);
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.address',
            returnObject => ['data', 'object{}', 'yes', "object-{} contains the requested data"],
        }
    ]);
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.tx',
            returnObject => ['data', 'object{}', 'yes', "object-{} contains the requested data"],
        }
    ]);
    
    API::html::readme::print::ReadmeClass('endReadme',$cgi);
}


1;
