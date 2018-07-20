package API::html::readme;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our readme modules
use html::readme::print;

sub print { 
    my $cgi = shift;
    
    API::html::readme::print::ReadmeClass('introduction',$cgi,' - ethereum.spreadblock.local',['eth.contract','eth.tx','eth.address','eth.block','eth.node']);
    
    
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
                ['data:to',             'null',     'yes', "null"],
                ['data:*',              '*',        'yes', "Additional return-data from generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a>."],
            ],
        },
        {
            method          => "eth.contract.transaction",
            title           => "Send a transaction to a contract",
            note            => "",
            parameterTable  => [
                ['params:contract',     'string',    'true',  '',    "Name of 'contract' to interact with, 'contract'.abi must be found in contracts/ folder"],
                ['params:function',     'string',    'true',  '',    "Contract function to execute"],
                ['params:function_params',  'object{}',  'false', '{ }', qq~Contract function parameters. e.g.: {"_beneficiary":"0x0","_value":102}~],
            ],
            requestExample  => qq~
// Generic example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.transaction","params":{"contract":"IceMine","function":"withdrawOf","function_params":{"_beneficiary":"0xe1f41867532c5c5f63179c9ec7819d8d3bf772d8"}}}'
            ~,
            returnDataTable => [
                ['data:tx_execution_time',          'integer',  'yes', "seconds till tx got mined (96 iterations á 5sec)"],
                ['data:*',                          '*',        'yes', "Additional return-data from helper method <a href='#eth.tx.receipt'>eth.tx.receipt</a>."],
            ],
        },
        {
            method          => "eth.contract.IceMine.deploy",
            title           => "Deploy 'IceMine' contract",
            note            => "",
            parameterTable  => [
                ['params:constructor',  'object{}', 'false',    '{ *from IceMine.pm* }', qq~'Constructor' parameters will be read from IceMine.pm (if not set). e.g.: {"initString":"Init String","initValue":102}~],
            ],
            requestExample  => qq~
// Deploy constract 'IceMine' with constructor from IceMine.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.deploy"}'
            ~,
            returnDataTable => [
                ['data:*',              '*',        'yes',      "See generic method <a href='#eth.contract.deploy'>eth.contract.deploy</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.IceMine.approveTeam",
            title           => "Approve Team members in 'IceMine' contract",
            note            => "",
            parameterTable  => [
                ['params:members',                  'array[]',  'false',    '', "Array[] which contains all member object{}'s to approve. [ {...}, {...}, {...} ]"],
                ['params:members:*',                'object{}', 'false',    '', qq~Member object{} to approve, e.g.: {"address":"0x6589...d8B5","share":8}~],
                ['params:members:*:address',        'string',   'false',    '', "'address' of member."],
                ['params:members:*:share',          'string',   'false',    '', "Team-'share' of member."],
            ],
            requestExample  => qq~
// Approve Team member(s) and set their share from given parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.approveTeam","params":{"members":[{"address":"0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5","share":8}]}}'

// Team members and shares will be read from IceMine.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.approveTeam"}'
            ~,
            returnDataTable => [
                ['data:*',              'object{}',  'no',      "member-'address' named object{} for each team-member."],
                ['data:*:share',        'integer',   'yes',     "'share' of this team-member."],
                ['data:*:*',            '*',        'yes',      "Each member object{} will contain additional return-data from generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a>."],
            ],
        },
        {
            method          => "eth.contract.IceMine.approvePrivate",
            title           => "Approve private crowdsale members in 'IceMine' contract",
            note            => "",
            parameterTable  => [
                ['params:members',                  'array[]',  'false',    '', "Array[] which contains all member object{}'s to approve. [ {...}, {...}, {...} ]"],
                ['params:members:*',                'object{}', 'false',    '', qq~Member object{} to approve, e.g.: {"address":"0x6589...d8B5","ethMinPurchase":0}~],
                ['params:members:*:address',        'string',   'false',    '', "'address' of member."],
                ['params:members:*:ethMinPurchase', 'string',   'false',    '', "'ethMinPurchase' of member."],
            ],
            requestExample  => qq~
// ApprovePrivate member(s) and set their ethMinPurchase from given parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.approvePrivate","params":{"members":[{"address":"0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5","ethMinPurchase":0}]}}'

// Private crowdsale members and their ethMinPurchase will be read from IceMine.pm:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.approvePrivate"}'
            ~,
            returnDataTable => [
                ['data:*',                      'object{}', 'no',   "member-'address' named object{} for each private crowdsale member."],
                ['data:*:ethMinPurchase',       'integer',  'yes',  "'ethMinPurchase' of this private crowdsale ember."],
                ['data:*:*',                    '*',        'yes',  "Each member object{} will contain additional return-data from generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a>."],
            ],
        },
        {
            method          => "eth.contract.IceMine.approveWhitelist",
            title           => "Approve whitelisted crowdsale members in 'IceMine' contract",
            note            => "",
            parameterTable  => [
                ['params:members',                  'array[]',  'false',    '', "Array[] which contains all member object{}'s to approve. [ {...}, {...}, {...} ]"],
                ['params:members:*',                'object{}', 'false',    '', qq~Member object{} to approve, e.g.: {"address":"0x6589...d8B5","ethMinPurchase":0}~],
                ['params:members:*:address',        'string',   'false',    '', "'address' of member."],
                ['params:members:*:ethMinPurchase', 'string',   'false',    '', "'ethMinPurchase' of member."],
            ],
            requestExample  => qq~
// ApproveWhitelist member(s) and set their ethMinPurchase from given parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.approveWhitelist","params":{"members":[{"address":"0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5","ethMinPurchase":0}]}}'

// Whitelisted crowdsale members and their ethMinPurchase will be read from IceMine.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.approveWhitelist"}'
            ~,
            returnDataTable => [
                ['data:*',                      'object{}', 'no',   "member-'address' named object{} for each whitelisted crowdsale member."],
                ['data:*:ethMinPurchase',       'integer',  'yes',  "'ethMinPurchase' of this whitelisted crowdsale ember."],
                ['data:*:*',                    '*',        'yes',  "Each member object{} will contain additional return-data from generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a>."],
            ],
        },
        {
            method          => "eth.contract.IceMine.setOwner",
            title           => "Initiate a withdrawal for a 'IceMine' contract member",
            note            => "",
            parameterTable  => [
                ['params:newOwner',      'string',    'false',  '',   "'address' of newOwner"],
            ],
            requestExample  => qq~
// Set new owner to 'newOwner' parameter.
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.setOwner","params":{"newOwner":"0xB7a96A6170A02e6d1FAf7D28A7821766afbc5ee3"}}'

// Set new owner to newOwner from IceMine.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.setOwner"}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a> for return data."],
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
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a> for return data."],
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
                ['data:block_number',                   'integer',  'yes', "Block number of contract creation block."],
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
                ['data:balance_wei',                    'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',                    'float',    'yes', "Balance of contract in ETH"],
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
            method          => "eth.contract.IceMine.balance",
            title           => "Get 'IceMine' contract balance",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'IceMine'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.balance"}'
            ~,
            returnDataTable => [
                ['data:balance_wei',        'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',        'float',    'yes', "Balance of contract in ETH"],
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
            method          => "eth.contract.IceMine.logs (DEVELOP/NOTREADY)",
            title           => "Get logs from 'IceMine' contract",
            note            => "",
            parameterTable  => [
                ['params:topics',       'array[]',  'false','[]',   "Filter: Array of 32 Bytes DATA topics. Topics are order-dependent. </br>Each topic can also be an array of DATA with 'or' options"],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.IceMine.logs"}'
            ~,
            returnDataTable => [
                ['data:logs',   'array[]',   'yes', "Array of all logs on this address since fromBlock which matches the filter."],
                ['data:*',      'string',   'yes',   "(DEVELOP/NOTREADY)"],
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
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.tx',
        },
        {
            method          => "eth.tx.receipt",
            title           => "Get a transaction receipt from a tx-hash",
            note            => "",
            parameterTable  => [
                ['params:tx',      'string',    'true',  '',   "'tx'-hash to get receipt for."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.tx.receipt","params":{"tx":"0x2e64a509ac0ead1c372e63553d4651137320ea5a27ec2ae094347e5083b41005"}}'
            ~,
            returnDataTable => [
                ['data:status',                     'integer',  'yes', "transaction status, 1 for success"],
                ['data:tx',                         'string',   'yes', "transaction hash"],
                ['data:txIndex',                    'integer',  'yes', "transaction index position in the block"],
                ['data:block_hash',                 'string',   'yes', "block hash"],
                ['data:block_number',               'integer',  'yes', "block number"],
                ['data:from',                       'string',   'yes', "from address"],
                ['data:to',                         'string',   'yes', "to address"],
                ['data:gas_used',                   'integer',  'yes', "gas used by tx"],
                ['data:cumulative_gas_used',        'integer',  'yes', "cumulative gas used by tx"],
                ['data:gas_price_wei',              'integer',  'yes', "gas price in Wei"],
                ['data:tx_cost_wei',                'integer',  'yes', "transaction price in Wei"],
                ['data:tx_cost_eth',                'float',    'yes', "transaction price in ETH"],
            ],
        },
        {
            method          => "eth.tx.gasprice",
            title           => "Get current price per gas in Wei",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.tx.gasprice"}'
            ~,
            returnDataTable => [
                ['data:gas_price_wei',              'integer',  'yes', "Current gas price in Wei"],
            ],
        },
    ]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.address',
        },
        {
            method          => "eth.address.balance",
            title           => "Get the ETH balance of 'address'",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',    'true',  '',   "'address' to get balance for."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.address.balance","params":{"address":"0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5"}}'
            ~,
            returnDataTable => [
                ['data:balance_wei',                'string',   'yes', "balance in Wei"],
                ['data:balance_eth',                'float',    'yes', "balance in ETH"],
            ],
        },
        {
            method          => "eth.address.logs (DEVELOP/NOTREADY)",
            title           => "Get logs from an 'address'",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',   'true', '',   "'address' to get logs from."],
                ['params:fromBlock',    'integer',  'false','0',   "Starting block for fetching logs."],
                ['params:topics',       'array[]',  'false','[]',   "Filter: Array of 32 Bytes DATA topics. Topics are order-dependent. </br>Each topic can also be an array of DATA with 'or' options"],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.address.logs","params":{"address":"0x02206f9f8b50d59cac1265e9234be7dda06d20f5"}}'
            ~,
            returnDataTable => [
                ['data:logs',   'array[]',   'yes', "Array of all logs on this address since fromBlock which matches the filter."],
                ['data:*',      'string',   'yes',   "(DEVELOP/NOTREADY)"],
            ],
        },
    ]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.block',
        },
        {
            method          => "eth.block.byNumber (DEVELOP/NOTREADY)",
            title           => "Get information about a block by 'number'",
            note            => "",
            parameterTable  => [
                ['params: 1.',          'integer',  'true', '',   "Block number"],
                ['params: 2.',          'bool',     'false', '',  "If true it returns the full transaction objects, if false only the hashes of the transactions."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[2323323, 1]}'
            ~,
            returnDataTable => [
                ['data:*',                          '*',        'yes', "See method <a href='#eth.block.byHash'>eth.block.byHash</a> for return data."],
            ],
        },
        {
            method          => "eth.block.byHash (DEVELOP/NOTREADY)",
            title           => "Get information about a block by 'hash'",
            note            => "",
            parameterTable  => [
                ['params: 1.',          'integer',  'true', '',   "Block hash"],
                ['params: 2.',          'bool',     'false', '',  "If true it returns the full transaction objects, if false only the hashes of the transactions."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc", 1]}'
            ~,
            returnDataTable => [
                ['data:hash',   'string',   'yes',   "Block Hash"],
                ['data:*',      'string',   'yes',   "(DEVELOP/NOTREADY)"],
            ],
        },
    ]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.node',
        },
        {
            method          => "eth.node.block",
            title           => "Get the number of most recent block",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.node.block"}'
            ~,
            returnDataTable => [
                ['data:block_number',       'integer',   'yes', "Most recent block number from client."],
             ],
        },
        {
            method          => "eth.node.accounts",
            title           => "Get list of addresses owned by client",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.node.accounts"}'
            ~,
            returnDataTable => [
                ['data:eth_accounts',       'array[]',   'yes', "List strings of addresses owned by client."],
             ],
        },
        {
            method          => "eth.node.coinbase",
            title           => "Get the client coinbase address",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.node.coinbase"}'
            ~,
            returnDataTable => [
                ['data:eth_coinbase',       'string',   'yes', "Address of client coinbase."],
             ],
        },
        {
            method          => "eth.node.balance",
            title           => "Get the balance of coinbase address",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.node.balance"}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.address.balance'>eth.address.balance</a> for return data."],
            ],
        },
        {
            method          => "eth.node.info",
            title           => "Get current node informations",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.node.info"}'
            ~,
            returnDataTable => [
                ['data:client_version',     'string',   'yes', "Current client version."],
                ['data:eth_coinbase',       'string',   'yes', "Current coinbase address."],
                ['data:net_version',        'string',   'yes', "Current network id: ETH-Mainnet: 2,  RInkeby-Testnet: 4."],
                ['data:eth_protocolVersion','string',   'yes', "Current ethereum protocol version."],
                ['data:net_peerCount',      'integer',  'yes', "Number of peers currently connected to the client."],
                ['data:block_number',       'integer',  'yes', "Most recent block number from client."],
                ['data:balance_wei',        'string',   'yes', "Balance of Coinbase-address in Wei"],
                ['data:balance_eth',        'float',    'yes', "Balance of Coinbase-address in ETH"],
                ['data:eth_accounts',       'array[]',  'yes', "List strings of addresses owned by client."],
                ['data:net_listening',      'bool',     'yes', "'true' if client is actively listening for network connections."],
                ['data:eth_syncing',        'bool',     'yes', "'true' if client is still syncing the chain, or 'false' (we are synced)."],
            ],
        },
    ]);
    
    
    API::html::readme::print::ReadmeClass('endReadme',$cgi);
}


1;
