package API::html::readme;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our readme modules
use html::readme::print;

sub print { 
    my $cgi = shift;
    
    API::html::readme::print::ReadmeClass('introduction',$cgi,' - ethereum.spreadblock.local',['eth.contract']);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.contract',
        },
        {
            method          => "eth.contract.deploy",
            title           => "Deploy a contract",
            note            => "",
            parameterTable  => [
                ['params:contract',     'string',    'true',  '',    "Name of 'contract' to deploy inside contracts/ folder (Same as filename/contractname without ending .sol)"],
                ['params:constructor',  'object{}',  'false', '{ }', qq~'Constructor' init parameters. e.g.: {"initString":"+ Constructor Init String +","initValue":102}~],
            ],
            requestExample  => qq~
// Generic example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"HelloWorld"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"myToken","constructor":{"_totalSupply":2000}}}'

// Deploy IceMine Smart Contract:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"IceMine","constructor":{"_cap":2000,"_wallet":"0x0acc13d0c5be1c8e8ae47c1f0363757ebef3a5d1","_owner":"0x0"}}}'
            ~,
            returnDataTable => [
                ['data:address',        'string',   'yes', "Contract address"],
                ['data:tx',             'string',   'yes', "Deployment transaction hash"],
                ['data:tx_cost_wei',    'integer',  'yes', "tx cost in Wei"],
                ['data:tx_cost_eth',    'float',    'yes', "tx cost in ETH"],
                ['data:gas_used',       'integer',  'yes', "gas amount used"],
                ['data:gas_price_wei',  'integer',  'yes', "price per gas amount"],
            ],
        },
        {
            method          => "eth.contract.sendTransaction",
            title           => "Send a transaction to a contract",
            note            => "",
            parameterTable  => [
                ['params:contract',     'string',    'true',  '',    "Name of 'contract' to interact with, 'contract'.abi must be found in contracts/ folder"],
                ['params:function',     'string',    'true',  '',    "Contract function to execute"],
                ['params:function_params',  'object{}',  'false', '{ }', qq~Contract function parameters. e.g.: {"_beneficiary":"0x0","_value":102}~],
            ],
            requestExample  => qq~
// Generic example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.sendTransaction","params":{"contract":"IceMine","function":"withdrawOf","function_params":{"_beneficiary":"0xe1f41867532c5c5f63179c9ec7819d8d3bf772d8"}}}'
            ~,
            returnDataTable => [
                ['data:status',                     'integer',  'yes', "tx status, 1 for success"],
                ['data:tx',                         'string',   'yes', "tx hash"],
                ['data:block_hash',                 'string',   'yes', "block hash"],
                ['data:block_number',               'integer',  'yes', "block number"],
                ['data:from',                       'string',   'yes', "from address"],
                ['data:to',                         'string',   'yes', "to address"],
                ['data:gas_used',                   'integer',  'yes', "gas used by tx"],
                ['data:cumulative_gas_used',        'integer',  'yes', "cumulative gas used by tx"],
                ['data:gas_price_wei',              'integer',  'yes', "gas price in Wei"],
                ['data:tx_cost_wei',                'integer',  'yes', "transaction price in Wei"],
                ['data:tx_cost_eth',                'float',    'yes', "transaction price in ETH"],
                ['data:tx_execution_time',          'integer',  'yes', "seconds till tx got mined (96 iterations á 5sec)"],
            ],
        },
        {
            method          => "eth.contract.IceMine.deploy",
            title           => "Deploy 'IceMine' contract",
            note            => "",
            parameterTable  => [
                ['params:constructor',  'object{}', 'false', '{ *from IceMine.pm* }', qq~'Constructor' parameters will be read from IceMine.pm (if not set). e.g.: {"initString":"Init String","initValue":102}~],
            ],
            requestExample  => qq~
// Deploy constract 'IceMine' with constructor from IceMine.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.deploy"}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.deploy'>eth.contract.deploy</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.IceMine.read",
            title           => "Read 'IceMine' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'IceMine'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.read"}'
            ~,
            returnDataTable => [
                ['data:address',                        'string',   'yes', "Contract address"],
                ['data:owner',                          'string',   'yes', "Contract owner address"],
                ['data:name',                           'string',   'yes', "EIP-20 name"],
                ['data:symbol',                         'string',   'yes', "EIP-20 symbol"],
                ['data:decimals',                       'integer',  'yes', "EIP-20 decimals"],
                ['data:totalSupply_ici',                'string',   'yes', "EIP-20 totalSupply"],
                ['data:totalSupply_ice',                'float',    'yes', "totalSupply(Ici) in ICE"],
                ['data:memberCount',                    'integer',  'yes', "Count of all IceMine members inclusive the team"],
                ['data:memberIndex',                    'array[]',  'yes', "array[] with 'string' of all member addresses"],
                ['data:crowdsalePercentOfTotalSupply',  'integer',  'yes', "Percent of totalSupply which will be available for Crowdsale"],
                ['data:withdrawer',                     'string',   'yes', "Address of allowed executor for automatic processed member whitdrawals"],
                ['data:depositor',                      'string',   'yes', "Address of allowed depositor of mining profits"],
                ['data:crowdsaleWallet',                'string',   'yes', "Address where crowdsale funds are collected"],
                ['data:percentMultiplier',              'string',   'yes', "Percent-value percentMultiplier to avoid floats. (10**21)"],
                ['data:crowdsaleRemainingWei_wei',      'string',   'yes', "Remeining Wei to buy in crowdsale"],
                ['data:crowdsaleRemainingWei_eth',      'float',    'yes', "Remeining ETH to buy in crowdsale"],
                ['data:crowdsaleSupply_ici',            'string',   'yes', "Remaining amount of totalSupply (Ici) which will be available for Crowdsale"],
                ['data:crowdsaleSupply_ice',            'float',    'yes', "Remaining amount of totalSupply in ICE which will be available for Crowdsale"],
                ['data:crowdsaleRemainingToken_ici',    'string',   'yes', "Remaining Ici for purchase in crowdsale"],
                ['data:crowdsaleRemainingToken_ice',    'float',    'yes', "Remaining ICE for purchase in crowdsale"],
                ['data:crowdsaleRaised_wei',            'string',   'yes', "Amount of wei raised in crowdsale in Wei"],
                ['data:crowdsaleRaised_eth',            'float',    'yes', "Amount of wei raised in crowdsale in ETH"],
                ['data:crowdsaleCap_wei',               'string',   'yes', "Wei after crowdsale is finished"],
                ['data:crowdsaleCap_eth',               'float',    'yes', "ETH after crowdsale is finished"],
                ['data:crowdsaleCalcToken_1wei',        'integer',  'yes', "Ici (10**-18 ICE) amount in crowdsale for 1 Wei"],
                ['data:crowdsaleInitialized',           'bool',     'yes', "true after owner initialized the contract"],
                ['data:crowdsaleOpen',                  'bool',     'yes', "true if crowdsale is open for investors"],
                ['data:crowdsaleFinished',              'bool',     'yes', "true after crowdsaleCap was reached"],
            ],
        },
        {
            method          => "eth.contract.IceMine.member",
            title           => "Read member-info from 'IceMine' contract",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',    'true',  '',   "'address' of member"],
            ],
            requestExample  => qq~
// use contract 'IceMine'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.member","params":{"address":"0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5"}}'
            ~,
            returnDataTable => [
                ['data:crowdsaleIsMember',          'bool',     'yes', "true if address is member of Contract"],
                ['data:unpaid_wei',                 'string',   'yes', "Unpaid Wei amount"],
                ['data:unpaid_eth',                 'float',    'yes', "Unpaid ETH amount"],
                ['data:balance_ici',                'string',   'yes', "Ici balance"],
                ['data:balance_ice',                'float',    'yes', "ICE balance"],
                ['data:percentTotal',               'string',   'yes', "percentTotal as in contract (use 'percentMultiplier')"],
                ['data:percentTotal_float',         'float',    'yes', "percentTotal as float representative"],
                ['data:crowdsalePercent',           'string',   'yes', "crowdsalePercent as in contract (use 'percentMultiplier')"],
                ['data:crowdsalePercent_float',     'float',    'yes', "crowdsalePercent as float representative"],
                ['data:crowdsaleInvestment_wei',    'string',   'yes', "Invested Wei into crowdsale"],
                ['data:crowdsaleInvestment_eth',    'float',    'yes', "Invested ETH into crowdsale"],
            ],
        },
        {
            method          => "eth.contract.IceMine.memberIndex",
            title           => "Read all member addresses from 'IceMine' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// use contract 'IceMine'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.memberIndex"}'
            ~,
            returnDataTable => [
                ['data:memberIndex',        'array[]',   'yes',     "array[] with 'string' of all member addresses"],
            ],
        },
        {
            method          => "eth.contract.IceMine.withdraw",
            title           => "Initiate a withdrawal for a 'IceMine' contract member",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',    'true',  '',   "'address' of member"],
            ],
            requestExample  => qq~
// Withdraw unpaid amount of member 0xe1f4.....72d8, returns a rc == 400 error if member has no unpaid_wei.
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.withdraw","params":{"address":"0xe1f41867532c5c5f63179c9ec7819d8d3bf772d8"}}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.sendTransaction'>eth.contract.sendTransaction</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.IceMine.crowdsaleCalcTokenAmount",
            title           => "Calc Ici for Wei in 'IceMine' contract crowdsale",
            note            => "",
            parameterTable  => [
                ['params:weiAmount',      'string (or integer)',    'true',  '',   "'weiAmount' to calculate"],
            ],
            requestExample  => qq~
// use contract 'IceMine'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.crowdsaleCalcTokenAmount","params":{"weiAmount":"800000000000"}}'
            ~,
            returnDataTable => [
                ['data:tokenAmount_ici',                'string',   'yes', "Ici amount"],
                ['data:tokenAmount_ice',                'float',    'yes', "ICE amount"],
            ],
        },
        
        
    ]);
    
    # API::html::readme::print::ReadmeClass([
        # {
            # readmeClass  => 'eth.address',
            # returnObject => ['data', 'object{}', 'yes', "object{} contains the requested data"],
        # }
    # ]);
    
    # API::html::readme::print::ReadmeClass([
        # {
            # readmeClass  => 'eth.tx',
            # returnObject => ['data', 'object{}', 'yes', "object{} contains the requested data"],
        # }
    # ]);
    
    API::html::readme::print::ReadmeClass('endReadme',$cgi);
}


1;
