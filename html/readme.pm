package API::html::readme;

use strict; use warnings; use utf8; use feature ':5.10';

## Load our readme modules
use html::readme::print;

sub print { 
    my $cgi = shift;
    
    API::html::readme::print::ReadmeClass('introduction',$cgi,' - api_ethereum',['eth.contract','eth.tx','eth.block','eth.address','eth.node','eth.contract.SmartMining','eth.contract.SmartMining_Mining','eth.contract.SmartMining_Team','eth.contract.CMR_Mining']);
    
    
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
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"HelloWorld"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"myToken","constructor":{"_totalSupply":2000}}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.deploy","params":{"contract":"myToken","constructor":{"_cap":2000,"_wallet":"0x0acc13d0c5be1c8e8ae47c1f0363757ebef3a5d1","_owner":"0x0"}}}'
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
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.transaction","params":{"contract":"SmartMining","function":"withdrawOf","function_params":{"_beneficiary":"0xe1f41867532c5c5f63179c9ec7819d8d3bf772d8"}}}'
            ~,
            returnDataTable => [
                ['data:tx_execution_time',          'integer',  'yes', "seconds till tx got mined (96 iterations á 5sec)"],
                ['data:*',                          '*',        'yes', "Additional return-data from helper method <a href='#eth.tx.receipt'>eth.tx.receipt</a>."],
            ],
        },
        {
            method          => "eth.contract.logs",
            title           => "Get logs from an 'contract'",
            note            => "'topic' is the type definition of an event function, e.g. Solidity: <code>event Transfer(address indexed from, address indexed to, uint256 value);</code> will be 'topic': <code>Transfer(address,address,uint256)</code> ",
            parameterTable  => [
                ['params:contract', 'string',   'true', '',                     "'contract' to get logs from. Address must be configured in accounts.pm and 'contract'.abi must be found in contracts/ folder."],
                ['params:topic',    'string',   'false','',                     "Event 'topic'[0] to filter for 'Event-function definition string' which will be converted to Keccak-256 'topic'[0]. </br><em>If not set the two additional parameter 'data' and 'topics' with the original ABI encoded data of this event will be returned.</em>"],
                ['params:topics',   'array[]',  'false','[]',                   "Filter topics, \"contract\" <em>(will be auto converted to contract address)</em>, pure ETH-addresses in any capitalization, or 32Byte-DATA raw topics to filter for.</br><em>Order dependend! Each topic can also be an Array[] of addresses, or DATA with 'or' options.</em>"],
                ['params:fromBlock','integer',  'false','contract-creation',    "Starting block for fetching logs from Node."],
                ['params:toBlock',  'integer',  'false','latest',               "Ending block for fetching logs from Node."],
                ['params:showtx',   'integer',  'false','2',                    "If 0 only tx_hash of the event, if 1 the full tx-details of the event, or 2 an empty transactions-array[] will be returned."],
                ['params:showraw',  'bool',     'false','false',                "Show also the raw-data for an event, which can be used later in the 'topics'-filter. <em>(Topic[0] is excluded if 'params:topic'!)</em>"],
            ],
            requestExample  => qq~
// Get all event logs from SmartMining contract, returns ABI-encoded event data:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining"}}'

// Get all 'Transfer' event logs from SmartMining contract, returns decoded human readable 'event_data' parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","topic":"Transfer(address,address,uint256)"}}'

// Get (decoded) 'Transfer' event logs from SmartMining contract, filter for to-address '0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5' ('contract' will be replaced with contracts address 32Byte-DATA):
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","topic":"Transfer(address,address,uint256)","topics":["contract","0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5"]}}'

// Get (decoded) 'Transfer' event logs from SmartMining contract, filter for to-address '0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5' OR '0x21c3ec39329b5EE1394E890842f679E93FE648bf':
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","topic":"Transfer(address,address,uint256)","topics":["contract",["0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5","0x21c3ec39329b5EE1394E890842f679E93FE648bf"]]}}'

// 'contract' used as one of two recipients example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","topic":"Transfer(address,address,uint256)","topics":["0x0",["contract","0x21c3ec39329b5EE1394E890842f679E93FE648bf"]]}}'

// Get finishing event (block and so on also...) from SmartMining crowdsale:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","topic":"CrowdsaleFinished(bool)"}}'

// Get raw event data additional to the decoded DATA for the Transfer events:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","topic":"Transfer(address,address,uint256)","showraw":true}}'

// showtx example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","topic":"Transfer(address,address,uint256)","showtx":1}}'

// showtx and showraw can be used anytime:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.logs","params":{"contract":"SmartMining","showtx":1,"showraw":true}}'
            ~,
            returnDataTable => [
                ['data:log_count',          'integer',  'yes',                                      "Log count of requested logs."],
                ['data:logs',               'array[]',  'yes',                                      "Array[] of all logs which matches the filter (given arguments)."],
                ['data:logs:*',             'object{}', 'no',                                       "Object{} of log details."],
                ['data:logs:*:log_index',   'integer',  'yes',                                      "Index of log entry."],
                ['data:logs:*:tx_hash',     'string',   'yes',                                      "Transaction hash"],
                ['data:logs:*:tx_index',    'integer',  'yes',                                      "Transaction index position in the block"],
                ['data:logs:*:removed',     'bool',     'yes',                                      "Removed state of log entry."],
                ['data:logs:*:event_name',  'string',   'if "params:topic"',                        "The 'name' of this event function, e.g. 'Transfer'. Not returned if 'topic' not set."],
                ['data:logs:*:event_data',  'object{}', 'if "params:topic"',                        "Object{} of event log data. Not returned if 'topic' not set."],
                ['data:logs:*:event_data:*','string',   'yes',                                      "Diverse return arguments from event log. One time named as in event-function, one time as order dependend name, e.g. '0', '1', '2',..."],
                ['data:logs:*:data',        'string',   'if !"params:topic" || "params:showraw"',   "Raw, ABI encoded data. Only returned if 'topic' not set."],
                ['data:logs:*:topics',      'array[]',  'if !"params:topic" || "params:showraw"',   "Raw, ABI encoded data-topics. Only returned if 'topic' not set."],
                ['data:logs:*:transactions','array[]',  'if "params:showtx"',                       "The transaction details for this log-entry from helper method <a href='#eth.block.byHash'>eth.block.byHash</a>"],
                ['data:logs:*:transactions:*','*',      'yes',                                       "See helper method <a href='#eth.block.byHash'>eth.block.byHash</a> 'transactions' return parameter for return-data."],
                ['data:logs:*:*',           '*',        'yes',                                      "Additional return-data from helper method <a href='#eth.block.byHash'>eth.block.byHash</a> for each event log entry."],
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
                ['data:tx_hash',                    'string',   'yes', "transaction hash"],
                ['data:tx_index',                   'integer',  'yes', "transaction index position in the block"],
                ['data:block_hash',                 'string',   'yes', "block hash"],
                ['data:block_number',               'integer',  'yes', "block number"],
                ['data:from',                       'string',   'yes', "from address"],
                ['data:to',                         'string',   'yes', "to address"],
                ['data:gas_used',                   'integer',  'yes', "gas used by tx"],
                ['data:gas_provided',               'integer',  'yes', "gas provided by sender"],
                ['data:cumulative_gas_used',        'integer',  'yes', "cumulative gas used by tx"],
                ['data:gas_price_wei',              'integer',  'yes', "gas price in Wei"],
                ['data:tx_cost_wei',                'string',   'yes', "transaction price in Wei"],
                ['data:tx_cost_eth',                'float',    'yes', "transaction price in ETH"],
                ['data:data',                       'string',   'yes', "the HEX-DATA send along with the transaction."],
                ['data:value_wei',                  'string',   'yes', "value transferred in Wei."],
                ['data:value_eth',                  'float',    'yes', "value transferred in ETH."],
                ['data:*',                          '*',        'yes', "Additional return-data from helper method <a href='#eth.block.byHash'>eth.block.byHash</a> with 'param: 2.' == 2."],
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
        {
            method          => "eth.tx.estimateGas",
            title           => "Get estimated gas for transaction with specified params",
            note            => "",
            parameterTable  => [
                ['params:to',       'string',    'false',  '',   "Recipient address of the transaction."],
                ['params:value',    'string',    'false',  '',   "Wei amount sent with this transaction."],
                ['params:data',     'string',    'false',  '',   "Hash of the method signature and ABI encoded parameters."],
                ['params:from',     'string',    'false',  '',   "The address the transaction is sent from."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.tx.estimateGas","params":{"to":"0xcb682d89265ab8c7ffa882f0ceb799109bc2a8b0","value":"8000000000000000000"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.tx.estimateGas","params":{"to":"0xabBD3f423CaF2571116750c21a981532Ee1D7065","value":"8000000000000000000"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.tx.estimateGas","params":{"to":"0xFa52274DD61E1643d2205169732f29114BC240b3","value":"8000000000000000000"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.tx.estimateGas","params":{"to":"0x7a96bb1261cbad172d81747792010381f9b3c37c","value":"8000000000000000000"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.tx.estimateGas","params":{"to":"0xe1863c4fb745c2b56e4ef0accb0a28dc8dfaeeae","value":"8000000000000000000"}}'
            ~,
            returnDataTable => [
                ['data:gas_estimated',              'integer',  'yes', "gas_estimated of given parameters."],
            ],
        },
    ]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.block',
        },
        {
            method          => "eth.block.byNumber",
            title           => "Get information about a block by 'number'",
            note            => "",
            parameterTable  => [
                ['params: 1.',          'integer',  'true', '',   "Block number"],
                ['params: 2.',          'integer',  'false', '0', "If 1 it returns the full transaction objects, if 0 only the hashes of the transactions, if 2 it will return an empty transactions-array[]."],
                ['params: 3.',          'string',   'false', '',  "Add only transactions for given 'tx_hash' in transactions-array[]."],
                ['params: 4.',          'string',   'false', '',  "Add only transactions for given to-'address' in transactions-array[]."],
                ['params: 5.',          'string',   'false', '',  "Add only transactions for given from-'address' in transactions-array[]."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[100011]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[100011, 2]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[100011, 1]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[100011, 1, "0x792432118435bd58ddd478c80dc5657785204dd876d6e095ec08e2c6c4eb2e7e"]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[100011, 1, "", "0xee097ff2d75523c83b4b1320479900c33bf22cc0"]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[100011, 1, "", "", "0x007f7f58d3eb5b7510a301ecc749fc1fcddbe14d"]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byNumber","params":[100011, 1, "", "0xb1abce2918e21ddb93aa452731a12672a3d9f75a", "0x007f7f58d3eb5b7510a301ecc749fc1fcddbe14d"]}'
            ~,
            returnDataTable => [
                ['data:*',                          '*',        'yes', "See method <a href='#eth.block.byHash'>eth.block.byHash</a> for return data."],
            ],
        },
        {
            method          => "eth.block.byHash",
            title           => "Get information about a block by 'hash'",
            note            => "",
            parameterTable  => [
                ['params: 1.',          'string',   'true', '',   "Block hash"],
                ['params: 2.',          'integer',  'false', '0', "If 1 it returns the full transaction objects, if 0 only the hashes of the transactions, if 2 it will return an empty transactions-array[]."],
                ['params: 3.',          'string',   'false', '',  "Add only transactions for given 'tx_hash' in transactions-array[]."],
                ['params: 4.',          'string',   'false', '',  "Add only transactions for given to-'address' in transactions-array[]."],
                ['params: 5.',          'string',   'false', '',  "Add only transactions for given from-'address' in transactions-array[]."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc"]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc", 2]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc", 1]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc", 1, "0xffd5cdfbb995c76b93d174eb969b0106cc0d76277d56686560cd3ea90fdff00b"]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc", 1, "", "0x1be1ddeb54ab974660bf5d726afb6032ffaad7d2"]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc", 1, "", "", "0x1be1ddeb54ab974660bf5d726afb6032ffaad7d2"]}'

curl http://$ENV{HTTP_HOST} -d '{"method":"eth.block.byHash","params":["0x67e9a179a9b4e088cc14c63ffb6dc4bf20a9287a0700aaa7ca97de3dda1f08dc", 1, "", "0xb1abce2918e21ddb93aa452731a12672a3d9f75a", "0x1be1ddeb54ab974660bf5d726afb6032ffaad7d2"]}'
            ~,
            returnDataTable => [
                ['data:block_hash',         'string',   'yes',                      "Block hash"],
                ['data:block_number',       'integer',  'yes',                      "Block number"],
                ['data:gas_used',           'integer',  'yes',                      "Gas used in block"],
                ['data:gas_limit',          'integer',  'yes',                      "Gas limit of block"],
                ['data:miner',              'string',   'yes',                      "Addres of block miner"],
                ['data:parent_hash',        'string',   'yes',                      "Parent block_hash"],
                ['data:size',               'integer',  'yes',                      "Size of block"],
                ['data:timestamp',          'integer',  'yes',                      "Timestamp of block"],
                ['data:difficulty',         'string',   'yes',                      "Difficulty of block"],
                ['data:difficulty_uncles',  'string',   'yes',                      "Difficulty (sum) of all uncles in this block"],
                ['data:difficulty_total',   'string',   'yes',                      "TotalDifficulty"],
                ['data:transactions',       'array[]',  'yes',                      "Array[] with all transactions of block."],
                ['data:transactions:*',     'object{}', 'yes, if "params: 2." != 0|2', "If 'params: 2.' == 0, a 'string' for each tx_hash in this block will be returned."],
                ['data:transactions:*',     'object{}', 'yes, if "params: 2." == 1',     "If 'params: 2.' == 1, a object{} for each transaction in this block will be returned."],
                ['data:transactions:*:tx_hash',             'string',   'yes, if "params: 2." == 1', "Transaction hash"],
                ['data:transactions:*:tx_index',            'integer',  'yes, if "params: 2." == 1', "Transaction index position in the block"],
                ['data:transactions:*:from',                'string',   'yes, if "params: 2." == 1', "From address"],
                ['data:transactions:*:to',                  'string',   'yes, if "params: 2." == 1', "To address"],
                ['data:transactions:*:gas_used',            'integer',  'yes, if "params: 2." == 1', "Gas used by tx"],
                ['data:transactions:*:gas_provided',        'integer',  'yes, if "params: 2." == 1', "Gas provided by sender"],
                ['data:transactions:*:cumulative_gas_used', 'integer',  'yes, if "params: 2." == 1', "Cumulative gas used by tx"],
                ['data:transactions:*:gas_price_wei',       'integer',  'yes, if "params: 2." == 1', "Gas price in Wei"],
                ['data:transactions:*:tx_cost_wei',         'integer',  'yes, if "params: 2." == 1', "Transaction price in Wei"],
                # ['data:transactions:*:data',                'string',   'yes, if "params: 2." == 1', "The HEX-DATA send along with the transaction."],
                ['data:transactions:*:value_wei',           'integer',  'yes, if "params: 2." == 1', "Value transferred in Wei."],
                ['data:transactions:*:value_eth',           'float',    'yes, if "params: 2." == 1', "Value transferred in ETH."],
                ['data:transactions:*:receipt:*',           '*',        'yes', "Additional return-data from helper method <a href='#eth.tx.receipt'>eth.tx.receipt</a>."],
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
                ['params:address',      'string',    'true',  '',       "'address' to get balance for."],
                ['params:block',        'string',    'false', 'latest', "'block'-number to get balance for address."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.address.balance","params":{"address":"0xb2930b35844a230f00e51431acae96fe543a0347"}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.address.balance","params":{"address":"0xb2930b35844a230f00e51431acae96fe543a0347","block":6411147}}'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.address.balance","params":{"address":"0xb2930b35844a230f00e51431acae96fe543a0347","block":6411148}}'
            ~,
            returnDataTable => [
                ['data:block_number',       'integer',  'yes', "Block number"],
                ['data:timestamp',          'integer',  'yes', "Timestamp of block"],
                ['data:balance_wei',        'string',   'yes', "balance in Wei"],
                ['data:balance_eth',        'float',    'yes', "balance in ETH"],
            ],
        },
        # {
            # method          => "eth.address.valueInputs",
            # title           => "Get all value inputs from an address.",
            # note            => "<span style='color:darkred;'>To loop over a lot of blocks can be a realy time consuming process and you cannot stop it anymore!</br>Filter your request to specific blocks or don't use this generic function!</span>",
            # parameterTable  => [
                # ['params:address',      'string',   'true', '',         "'address' to get valueInputs for."],
                # ['params:fromBlock',    'integer',  'true', '',         "Starting block_number to look over"],
                # ['params:toBlock',      'integer',  'false','latest',   "Last block_number to look over"],
                # ['params:from',         'string',   'false','',         "Filter for 'from' address of value sender."],
                # ['params:showreceipt',  'bool',     'false','false',    "Returns also the transactions receipt."],
                # ['params:showempty',    'bool',     'false','false',    "Returns also transactions without value."],
                # ['params:showfailed',   'bool',     'false','false',    "Returns also the failed transactions. (They will not be added to total ETH calculation, but to 'tx_count'.)"],
            # ],
            # requestExample  => qq~
# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.address.valueInputs","params":{"address":"0xadb7ff320fbdf1eb61ee05f6edf89783a466f3bf","from":"0x65890c49a1628452fc9d50b720759fa7ed4ed8b5","fromBlock":2659122,"toBlock":2659241}}'

# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.valueInputs","params":{"showreceipt":true,"showempty":true,"showfailed":true,"address":"0xadb7ff320fbdf1eb61ee05f6edf89783a466f3bf","from":"0x65890c49a1628452fc9d50b720759fa7ed4ed8b5"}}'
            # ~,
            # returnDataTable => [
                # ['data:total_wei',                  'string',   'yes',  "Total value inputs for request in Wei"],
                # ['data:total_eth',                  'float',    'yes',  "Total value inputs for request in ETH"],
                # ['data:tx_count',                   'integer',  'yes',  "Transaction count of requested value inputs"],
                # ['data:transactions',               'array[]',  'yes',  "Array[] of all transactions with value on this address which matches the filter."],
                # ['data:transactions:*',             'object{}', 'no',   "Object{} of transaction details."],
                # ['data:transactions:*:tx_hash',     'string',   'yes',  "Transaction hash"],
                # ['data:transactions:*:tx_index',    'integer',  'yes',  "Transaction index position in the block"],
                # ['data:transactions:*:from',        'string',   'yes',  "From address"],
                # ['data:transactions:*:gas_provided','integer',  'yes',  "Gas provided by sender"],
                # ['data:transactions:*:block_hash',  'string',   'yes',  "Block hash"],
                # ['data:transactions:*:block_number','integer',  'yes',  "Block number"],
                # ['data:transactions:*:timestamp',   'integer',  'yes',  "Timestamp of block"],
                # ['data:transactions:*:value_wei',   'integer',  'yes',  "Value transferred in Wei."],
                # ['data:transactions:*:value_eth',   'float',    'yes',  "Value transferred in ETH."],
                # ['data:transactions:*:receipt',     'object{}', 'yes',  "Value transferred in ETH."],
                # ['data:transactions:*:receipt:*',   '*', 'if \'params:showreceipt\'',  "Additional return-data from helper method <a href='#eth.tx.receipt'>eth.tx.receipt</a>."],
            # ],
        # },
    ]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.node',
        },
        {
            method          => "eth.node.sha3",
            title           => "Get Keccak-256 (not the standardized SHA3-256) of given data",
            note            => "",
            parameterTable  => [
                ['params: 1.',  'string',  'true', '',   "Some data..."],
            ],
            requestExample  => qq~
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.node.sha3","params":["Hey!"]}'
            ~,
            returnDataTable => [
                ['data:hex',    'string',   'yes', "Given data as hex string."],
                ['data:sha3',   'string',   'yes', "Given data as Keccak-256."],
             ],
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
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.contract.SmartMining',
        },
        {
            method          => "eth.contract.SmartMining.deploy",
            title           => "Deploy 'SmartMining' contract",
            note            => "",
            parameterTable  => [
                ['params:constructor',  'object{}', 'false',    '{ *from SmartMining.pm* }', qq~'Constructor' parameters will be read from SmartMining.pm (if not set). e.g.: {"initString":"Init String","initValue":102}~],
            ],
            requestExample  => qq~
// Deploy constract 'SmartMining' with constructor from SmartMining.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.deploy"}'
            ~,
            returnDataTable => [
                ['data:*',              '*',        'yes',  "See generic method <a href='#eth.contract.deploy'>eth.contract.deploy</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.SmartMining.approve",
            title           => "Approve member in 'SmartMining' contract",
            note            => "If <code>gas_estimated</code> of address is >23300 the whitelisting of this address will abort. and <code>data:*:error</code> will be returned.",
            parameterTable  => [
                ['params:members',                  'array[]',  'false',    '', "Array[] which contains all member object{}'s to approve. [ {...}, {...}, {...} ]"],
                ['params:members:*',                'object{}', 'false',    '', qq~Member object{} to approve, e.g.: {"address":"0x6589...d8B5","ethMinPurchase":0,"privateSale":1}~],
                ['params:members:*:address',        'string',   'false',    '', "'address' of member."],
                ['params:members:*:ethMinPurchase', 'string',   'false',    '', "'ethMinPurchase' of member."],
                ['params:members:*:privateSale',    'integer',  'false',    '', "'privateSale' state of member, 0 or 1."],
            ],
            requestExample  => qq~
// Approve member(s) and set their ethMinPurchase from given parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.approve","params":{"members":[{"address":"0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5","ethMinPurchase":0,"privateSale":1}]}}'

// Whitelisted crowdsale members and their ethMinPurchase will be read from SmartMining.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.approve"}'
            ~,
            returnDataTable => [
                ['data:*',                      'object{}', 'no',   "member-'address' named object{} for each whitelisted crowdsale member."],
                ['data:*:ethMinPurchase',       'integer',  'yes',  "'ethMinPurchase' of this whitelisted crowdsale member."],
                ['data:*:privateSale',          'integer',  'yes',  "'privateSale' state of this whitelisted crowdsale member, 0 or 1."],
                ['data:*:gas_estimated',        'integer',  'yes',  "gas_estimated of member-address."],
                ['data:*:error',                'integer',  'no',   "Whitelisting of member will be aborted with 'error'-reason if <code>'gas_estimated' > 23300</code>."],
                ['data:*:*',                    '*',        'yes, if not \'error\'',  "Each member object{} will contain additional return-data from generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a>."],
            ],
        },
        {
            method          => "eth.contract.SmartMining.setOwner",
            title           => "Set new owner of 'SmartMining' contract",
            note            => "",
            parameterTable  => [
                ['params:newOwner',      'string',    'false',  '',   "'address' of newOwner"],
            ],
            requestExample  => qq~
// Set new owner to 'newOwner' parameter.
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.setOwner","params":{"newOwner":"0xB7a96A6170A02e6d1FAf7D28A7821766afbc5ee3"}}'

// Set new owner to newOwner from SmartMining.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.setOwner"}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.SmartMining.withdraw",
            title           => "Initiate a withdrawal for a 'SmartMining' contract member",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',    'true',  '',   "'address' of member"],
            ],
            requestExample  => qq~
// Withdraw unpaid amount of member 0xe1f4.....72d8, returns a rc == 400 error if member has no unpaid_wei.
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.withdraw","params":{"address":"0xe1f41867532c5c5f63179c9ec7819d8d3bf772d8"}}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.transaction'>eth.contract.transaction</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.SmartMining.read",
            title           => "Read 'SmartMining' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'SmartMining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.read"}'
            ~,
            returnDataTable => [
                ['data:address',                        'string',   'yes', "Contract address"],
                ['data:block_number',                   'integer',  'yes', "Block number of contract creation block."],
                ['data:owner',                          'string',   'yes', "Contract owner address"],
                ['data:name',                           'string',   'yes', "EIP-20 name"],
                ['data:symbol',                         'string',   'yes', "EIP-20 symbol"],
                ['data:decimals',                       'integer',  'yes', "EIP-20 decimals"],
                ['data:totalSupply_coini',                'string',   'yes', "EIP-20 totalSupply"],
                ['data:totalSupply_coins',                'float',    'yes', "totalSupply(Ici) in ICE"],
                ['data:memberCount',                    'integer',  'yes', "Count of all SmartMining members inclusive the team"],
                ['data:memberIndex',                    'array[]',  'yes', "array[] with 'string' of all member addresses"],
                ['data:crowdsalePercentOfTotalSupply',  'integer',  'yes', "Percent of totalSupply which will be available for Crowdsale"],
                ['data:withdrawer',                     'string',   'yes', "Address of allowed executor for automatic processed member whitdrawals"],
                ['data:depositor',                      'string',   'yes', "Address of allowed depositor of mining profits"],
                ['data:balance_wei',                    'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',                    'float',    'yes', "Balance of contract in ETH"],
                ['data:crowdsaleWallet',                'string',   'yes', "Address where crowdsale funds are collected"],
                ['data:crowdsaleRemainingWei_wei',      'string',   'yes', "Remeining Wei to buy in crowdsale"],
                ['data:crowdsaleRemainingWei_eth',      'float',    'yes', "Remeining ETH to buy in crowdsale"],
                ['data:crowdsaleRemainingToken_coini',    'string',   'yes', "Remaining Ici for purchase in crowdsale"],
                ['data:crowdsaleRemainingToken_coins',    'float',    'yes', "Remaining ICE for purchase in crowdsale"],
                ['data:crowdsaleRaised_wei',            'string',   'yes', "Amount of wei raised in crowdsale in Wei"],
                ['data:crowdsaleRaised_eth',            'float',    'yes', "Amount of wei raised in crowdsale in ETH"],
                ['data:crowdsaleCap_wei',               'string',   'yes', "Wei after crowdsale is finished"],
                ['data:crowdsaleCap_eth',               'float',    'yes', "ETH after crowdsale is finished"],
                ['data:crowdsaleCalcToken_1wei',        'integer',  'yes', "Ici (10**-18 ICE) amount in crowdsale for 1 Wei"],
                ['data:crowdsaleOpen',                  'bool',     'yes', "true if crowdsale is open for investors"],
                ['data:crowdsaleFinished',              'bool',     'yes', "true after crowdsaleCap was reached"],
            ],
        },
        {
            method          => "eth.contract.SmartMining.balance",
            title           => "Get 'SmartMining' contract balance",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'SmartMining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.balance"}'
            ~,
            returnDataTable => [
                ['data:balance_wei',        'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',        'float',    'yes', "Balance of contract in ETH"],
            ],
        },
        {
            method          => "eth.contract.SmartMining.member",
            title           => "Read member-info from 'SmartMining' contract",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',    'true',  '',   "'address' of member"],
            ],
            requestExample  => qq~
// use contract 'SmartMining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.member","params":{"address":"0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5"}}'
            ~,
            returnDataTable => [
                ['data:crowdsaleIsMember',          'bool',     'yes', "true if address is member of Contract"],
                ['data:unpaid_wei',                 'string',   'yes', "Unpaid Wei amount"],
                ['data:unpaid_eth',                 'float',    'yes', "Unpaid ETH amount"],
                ['data:balance_coini',                'string',   'yes', "Ici balance"],
                ['data:balance_coins',                'float',    'yes', "ICE balance"],
            ],
        },
        {
            method          => "eth.contract.SmartMining.memberIndex",
            title           => "Read all member addresses from 'SmartMining' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// use contract 'SmartMining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.memberIndex"}'
            ~,
            returnDataTable => [
                ['data:memberIndex',        'array[]',   'yes',     "array[] with 'string' of all member addresses"],
            ],
        },
        {
            method          => "eth.contract.SmartMining.logs",
            title           => "Get logs from 'SmartMining' contract",
            note            => "'topic' is the type definition of an event function, e.g. Solidity: <code>event Transfer(address indexed from, address indexed to, uint256 value);</code> will be 'topic': <code>Transfer(address,address,uint256)</code> 
                <p><u>Available 'topics' in SmartMining contract:</u>
                </br> <code>SetOwner(address)</code>
                </br> <code>SetDepositor(address)</code>
                </br> <code>SetWithdrawer(address)</code>
                </br> <code>SetTeamContract(address)</code>
                </br> <code>Approve(address,uint256,bool)</code>
                </br> <code>Participate(address,uint256,uint256)</code>
                </br> <code>Transfer(address,address,uint256)</code>
                </br> <code>ForwardCrowdsaleFunds(address,uint256)</code>
                </br> <code>CrowdsaleStarted(bool)</code>
                </br> <code>CrowdsaleFinished(bool)</code>
                </br> <code>Withdraw(address,uint256)</code>
                </br> <code>Deposit(address,uint256)</code>
                </p>
            ",
            parameterTable  => [
                ['params:topic',    'string',   'false','',                 "Event 'topic'[0] to filter for 'Event-function definition string' which will be converted to Keccak-256 'topic'[0]. </br><em>If not set the two additional parameter 'data' and 'topics' with the original ABI encoded data of this event will be returned.</em>"],
                ['params:topics',   'array[]',  'false','[]',               "Filter topics, \"contract\" <em>(will be auto converted to contract address)</em>, pure ETH-addresses in any capitalization, or 32Byte-DATA raw topics to filter for.</br><em>Order dependend! Each topic can also be an Array[] of addresses, or DATA with 'or' options.</em>"],
                ['params:fromBlock','integer',  'false','contract-creation',"Starting block for fetching logs from Node."],
                ['params:toBlock',  'integer',  'false','latest',           "Ending block for fetching logs from Node."],
                ['params:showtx',   'integer',  'false','2',                "If 0 only tx_hash of the event, if 1 the full tx-details of the event, or 2 an empty transactions-array[] will be returned."],
                ['params:showraw',  'bool',     'false','false',            "Show also the raw-data for an event, which can be used later in the 'topics'-filter. <em>(Topic[0] is excluded if 'params:topic'!)</em>"],
            ],
            requestExample  => qq~
// Get all event logs from SmartMining contract, returns ABI-encoded event data:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs"}'

// Get 'Transfer' event logs from SmartMining contract, returns decoded human readable 'event_data' parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"topic":"Transfer(address,address,uint256)"}}'

// Get (decoded) 'Transfer' event logs from SmartMining contract, filter for to-address '0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5' ("contract" will be replaced with contract address):
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"topic":"Transfer(address,address,uint256)","topics":["contract","0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5"]}}'

// Get (decoded) 'Transfer' event logs from SmartMining contract, filter for to-address '0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5' OR '0x21c3ec39329b5EE1394E890842f679E93FE648bf ("contract" will be replaced with contract address):
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"topic":"Transfer(address,address,uint256)","topics":["contract",["0x65890c49a1628452fc9d50B720759fA7Ed4ed8B5","0x21c3ec39329b5EE1394E890842f679E93FE648bf"]]}}'

// 'contract' used as one of two recipients example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"topic":"Transfer(address,address,uint256)","topics":["0x0",["contract","0x21c3ec39329b5EE1394E890842f679E93FE648bf"]]}}'

// Get finishing event (block and so on also...) from SmartMining crowdsale:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"topic":"CrowdsaleFinished(bool)"}}'

// Get raw event data additional to the decoded DATA for the Transfer events:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"topic":"Transfer(address,address,uint256)","showraw":true}}'

// showtx example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"topic":"Transfer(address,address,uint256)","showtx":1}}'

// showtx and showraw can be used anytime:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.logs","params":{"showtx":1,"showraw":true}}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.logs'>eth.contract.logs</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.SmartMining.crowdsaleCalcTokenAmount",
            title           => "Calc Ici for Wei in 'SmartMining' contract crowdsale",
            note            => "",
            parameterTable  => [
                ['params:weiAmount',      'string (or integer)',    'true',  '',   "'weiAmount' to calculate"],
            ],
            requestExample  => qq~
// use contract 'SmartMining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining.crowdsaleCalcTokenAmount","params":{"weiAmount":"800000000000"}}'
            ~,
            returnDataTable => [
                ['data:tokenAmount_coini',                'string',   'yes', "Ici amount"],
                ['data:tokenAmount_coins',                'float',    'yes', "ICE amount"],
            ],
        },
    ]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.contract.SmartMining_Mining',
        },
        {
            method          => "eth.contract.SmartMining_Mining.deploy",
            title           => "Deploy 'SmartMining_Mining' contract",
            note            => "",
            parameterTable  => [
                ['params:constructor',  'object{}', 'false',    '{ *from SmartMining_Mining.pm* }', qq~'Constructor' parameters will be read from SmartMining_Mining.pm (if not set). e.g.: {"initString":"Init String","initValue":102}~],
            ],
            requestExample  => qq~
// Deploy constract 'SmartMining_Mining' with constructor from SmartMining_Mining.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.deploy"}'
            ~,
            returnDataTable => [
                ['data:*',              '*',        'yes',  "See generic method <a href='#eth.contract.deploy'>eth.contract.deploy</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.SmartMining_Mining.read",
            title           => "Read 'SmartMining_Mining' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'SmartMining_Mining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.read"}'
            ~,
            returnDataTable => [
                ['data:address',                'string',   'yes', "Contract address"],
                ['data:block_number',           'integer',  'yes', "Block number of contract creation block."],
                ['data:owner',                  'string',   'yes', "Contract owner address"],
                ['data:withdrawal_address',     'string',   'yes', "SmartMining controlled address which will trade received ETH against EUR for paying the operating costs"],
                ['data:distribution_contract',  'string',   'yes', "SmartMining 'crowdsale & profit distribution'-contract address"],
                ['data:oraclize_query',         'integer',  'yes', "Oraclize URL query e.g. json(https://api.kraken.com/0/public/Ticker?pair=ETHEUR).result.XETHZEUR.c.0"],
                ['data:balance_wei',            'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',            'float',    'yes', "Balance of contract in ETH"],
            ],
        },
        {
            method          => "eth.contract.SmartMining_Mining.balance",
            title           => "Get 'SmartMining_Mining' contract balance",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'SmartMining_Mining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.balance"}'
            ~,
            returnDataTable => [
                ['data:balance_wei',        'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',        'float',    'yes', "Balance of contract in ETH"],
            ],
        },
        {
            method          => "eth.contract.SmartMining_Mining.logs",
            title           => "Get logs from 'SmartMining_Mining' contract",
            note            => "'topic' is the type definition of an event function, e.g. Solidity: <code>event Transfer(address indexed from, address indexed to, uint256 value);</code> will be 'topic': <code>Transfer(address,address,uint256)</code> 
                <p><u>Available 'topics' in SmartMining_Mining contract:</u>
                </br> <code>SetOwner(address)</code>
                </br> <code>Set_DISTRIBUTION_CONTRACT(address)</code>
                </br> <code>Set_WITHDRAWAL_ADDRESS(address)</code>
                </br> <code>Set_ORACLIZE_QUERY(string)</code>
                </br> <code>Set_ORACLIZE_GAS_PRICE(uint256)</code>
                </br> <code>InitiateWithdraw(uint256,uint256,uint256,bytes32,uint256)</code>
                </br> <code>DeletePendingWithdraw(bytes32)</code>
                </br> <code>Deposit(address,uint256)</code>
                </br> <code>WipeToContract(address,uint256)</code>
                </br> <code>OraclizeCallback(bytes32,string,bytes)</code>
                </br> <code>WithdrawOperatingCost(address,uint256,uint256,uint256,bytes32)</code>
                </br> <code>WithdrawMiningProfit(address,uint256,bytes32)</code>
                </p>
            ",
            parameterTable  => [
                ['params:topic',    'string',   'false','',                 "Event 'topic'[0] to filter for 'Event-function definition string' which will be converted to Keccak-256 'topic'[0]. </br><em>If not set the two additional parameter 'data' and 'topics' with the original ABI encoded data of this event will be returned.</em>"],
                ['params:topics',   'array[]',  'false','[]',               "Filter topics, \"contract\" <em>(will be auto converted to contract address)</em>, pure ETH-addresses in any capitalization, or 32Byte-DATA raw topics to filter for.</br><em>Order dependend! Each topic can also be an Array[] of addresses, or DATA with 'or' options.</em>"],
                ['params:fromBlock','integer',  'false','contract-creation',"Starting block for fetching logs from Node."],
                ['params:toBlock',  'integer',  'false','latest',           "Ending block for fetching logs from Node."],
                ['params:showtx',   'integer',  'false','2',                "If 0 only tx_hash of the event, if 1 the full tx-details of the event, or 2 an empty transactions-array[] will be returned."],
                ['params:showraw',  'bool',     'false','false',            "Show also the raw-data for an event, which can be used later in the 'topics'-filter. <em>(Topic[0] is excluded if 'params:topic'!)</em>"],
            ],
            requestExample  => qq~
// Get all event logs from SmartMining_Mining contract, returns ABI-encoded event data:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.logs"}'

// Get 'Deposit' event logs from SmartMining_Mining contract, returns decoded human readable 'event_data' parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.logs","params":{"topic":"Deposit(address,uint256)"}}'

// Get raw event data additional to the decoded DATA for the Transfer events:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.logs","params":{"topic":"WithdrawOperatingCost(address,uint256,uint256,uint256,bytes32)","showraw":true}}'

// showtx example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.logs","params":{"topic":"WithdrawOperatingCost(address,uint256,uint256,uint256,bytes32)","showtx":1}}'

// showtx and showraw can be used anytime:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.logs","params":{"showtx":1,"showraw":true}}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.logs'>eth.contract.logs</a> for return data."],
            ],
        },
        # {
            # method          => "eth.contract.SmartMining_Mining.valueInputs",
            # title           => "Get all value inputs of 'SmartMining_Mining' contract.",
            # note            => "",
            # parameterTable  => [
                # ['params:from',         'string',   'false','',         "Filter for 'from' address of value sender."],
                # ['params:showreceipt',  'bool',     'false','false',    "Returns also the transactions receipt."],
                # ['params:showempty',    'bool',     'false','false',    "Returns also transactions without value."],
                # ['params:showfailed',   'bool',     'false','false',    "Returns also the failed transactions. (They will not be added to total ETH calculation, but to 'tx_count'.)"],
            # ],
            # requestExample  => qq~
# // Without filter for a specific sender of the value
# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.valueInputs"}'

# // With filter for a specific sender of the value
# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.valueInputs","params":{"from":"0x65890c49a1628452fc9d50b720759fa7ed4ed8b5"}}'

# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Mining.valueInputs","params":{"showreceipt":true,"showempty":true,"showfailed":true,"from":"0x65890c49a1628452fc9d50b720759fa7ed4ed8b5"}}'
            # ~,
            # returnDataTable => [
                # ['data:*',        '*',   'yes', "See generic method <a href='#eth.address.valueInputs'>eth.address.valueInputs</a> for return data."],
            # ],
        # },
    ]);
    
    
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.contract.SmartMining_Team',
        },
        {
            method          => "eth.contract.SmartMining_Team.deploy",
            title           => "Deploy 'SmartMining_Team' contract",
            note            => "",
            parameterTable  => [
                ['params:constructor',  'object{}', 'false',    '{ *from SmartMining_Team.pm* }', qq~'Constructor' parameters will be read from SmartMining_Team.pm (if not set). e.g.: {"initString":"Init String","initValue":102}~],
            ],
            requestExample  => qq~
// Deploy constract 'SmartMining_Team' with constructor from SmartMining_Team.pm
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.deploy"}'
            ~,
            returnDataTable => [
                ['data:*',              '*',        'yes',  "See generic method <a href='#eth.contract.deploy'>eth.contract.deploy</a> for return data."],
            ],
        },
        {
            method          => "eth.contract.SmartMining_Team.read",
            title           => "Read 'SmartMining_Team' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'SmartMining_Team'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.read"}'
            ~,
            returnDataTable => [
                ['data:address',                'string',   'yes', "Contract address"],
                ['data:block_number',           'integer',  'yes', "Block number of contract creation block."],
                ['data:owner',                  'string',   'yes', "Contract owner address"],
            ],
        },
        {
            method          => "eth.contract.SmartMining_Team.balance",
            title           => "Get 'SmartMining_Team' contract balance",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Balance from contract 'SmartMining_Team'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.balance"}'
            ~,
            returnDataTable => [
                ['data:balance_wei',        'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',        'float',    'yes', "Balance of contract in ETH"],
            ],
        },
        {
            method          => "eth.contract.SmartMining_Team.logs",
            title           => "Get logs from 'SmartMining_Team' contract",
            note            => "'topic' is the type definition of an event function, e.g. Solidity: <code>event Transfer(address indexed from, address indexed to, uint256 value);</code> will be 'topic': <code>Transfer(address,address,uint256)</code> 
                <p><u>Available 'topics' in SmartMining_Team contract:</u>
                </p>
            ",
            parameterTable  => [
                ['params:topic',    'string',   'false','',                 "Event 'topic'[0] to filter for 'Event-function definition string' which will be converted to Keccak-256 'topic'[0]. </br><em>If not set the two additional parameter 'data' and 'topics' with the original ABI encoded data of this event will be returned.</em>"],
                ['params:topics',   'array[]',  'false','[]',               "Filter topics, \"contract\" <em>(will be auto converted to contract address)</em>, pure ETH-addresses in any capitalization, or 32Byte-DATA raw topics to filter for.</br><em>Order dependend! Each topic can also be an Array[] of addresses, or DATA with 'or' options.</em>"],
                ['params:fromBlock','integer',  'false','contract-creation',"Starting block for fetching logs from Node."],
                ['params:toBlock',  'integer',  'false','latest',           "Ending block for fetching logs from Node."],
                ['params:showtx',   'integer',  'false','2',                "If 0 only tx_hash of the event, if 1 the full tx-details of the event, or 2 an empty transactions-array[] will be returned."],
                ['params:showraw',  'bool',     'false','false',            "Show also the raw-data for an event, which can be used later in the 'topics'-filter. <em>(Topic[0] is excluded if 'params:topic'!)</em>"],
            ],
            requestExample  => qq~
// Get all event logs from SmartMining_Team contract, returns ABI-encoded event data:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.logs"}'

// Get 'Deposit' event logs from SmartMining_Team contract, returns decoded human readable 'event_data' parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.logs","params":{"topic":""}}'

// Get raw event data additional to the decoded DATA for the Transfer events:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.logs","params":{"topic":"","showraw":true}}'

// showtx example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.logs","params":{"topic":"","showtx":1}}'

// showtx and showraw can be used anytime:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.logs","params":{"showtx":1,"showraw":true}}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.logs'>eth.contract.logs</a> for return data."],
            ],
        },
        # {
            # method          => "eth.contract.SmartMining_Team.valueInputs",
            # title           => "Get all value inputs of 'SmartMining_Team' contract.",
            # note            => "",
            # parameterTable  => [
                # ['params:from',         'string',   'false','',         "Filter for 'from' address of value sender."],
                # ['params:showreceipt',  'bool',     'false','false',    "Returns also the transactions receipt."],
                # ['params:showempty',    'bool',     'false','false',    "Returns also transactions without value."],
                # ['params:showfailed',   'bool',     'false','false',    "Returns also the failed transactions. (They will not be added to total ETH calculation, but to 'tx_count'.)"],
            # ],
            # requestExample  => qq~
# // Without filter for a specific sender of the value
# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.valueInputs"}'

# // With filter for a specific sender of the value
# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.valueInputs","params":{"from":"0x65890c49a1628452fc9d50b720759fa7ed4ed8b5"}}'

# curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.SmartMining_Team.valueInputs","params":{"showreceipt":true,"showempty":true,"showfailed":true,"from":"0x65890c49a1628452fc9d50b720759fa7ed4ed8b5"}}'
            # ~,
            # returnDataTable => [
                # ['data:*',        '*',   'yes', "See generic method <a href='#eth.address.valueInputs'>eth.address.valueInputs</a> for return data."],
            # ],
        # },
    ]);
    
        
    API::html::readme::print::ReadmeClass([
        {
            readmeClass  => 'eth.contract.CMR_Mining',
        },
        {
            method          => "eth.contract.CMR_Mining.read",
            title           => "Read 'CMR_Mining' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'CMR_Mining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.read"}'
            ~,
            returnDataTable => [
                ['data:address',                'string',   'yes', "Contract address"],
                ['data:block_number',           'integer',  'yes', "Block number of contract creation block."],
                ['data:memberCount',            'integer',  'yes', "Count of all CMR_Mining members inclusive the team"],
                ['data:memberIndex',            'array[]',  'yes', "Array[] with 'string' of all member addresses"],
                ['data:balance_wei',            'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',            'float',    'yes', "Balance of contract in ETH"],
                ['data:depositCount',           'integer',  'yes', "Count of all deposits"],
                ['data:deposited_wei',          'string',   'yes', "Total deposit value in Wei"],
                ['data:deposited_eth',          'float',    'yes', "Total deposit value in ETH"],
                ['data:members',                'object{}', 'yes', "Object{} of all members infos"],
                ['data:members:*',              'object{}', 'yes', "Member-address named object{} of members infos"],
                ['data:members:*:*',            '*',        'yes', "See helper method <a href='#eth.contract.CMR_Mining.member'>eth.contract.CMR_Mining.member</a> return parameter for return-data."],
            ],
        },
        {
            method          => "eth.contract.CMR_Mining.balance",
            title           => "Get 'CMR_Mining' contract balance",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// Read Info from contract 'CMR_Mining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.balance"}'
            ~,
            returnDataTable => [
                ['data:balance_wei',        'string',   'yes', "Balance of contract in Wei"],
                ['data:balance_eth',        'float',    'yes', "Balance of contract in ETH"],
            ],
        },
        {
            method          => "eth.contract.CMR_Mining.member",
            title           => "Read member-info from 'CMR_Mining' contract",
            note            => "",
            parameterTable  => [
                ['params:address',      'string',    'true',  '',   "'address' of member"],
            ],
            requestExample  => qq~
// use contract 'CMR_Mining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.member","params":{"address":"0xd2Ce719a0d00f4f8751297aD61B0E936970282E1"}}'
            ~,
            returnDataTable => [
                ['data:unpaid_wei',         'string',   'yes', "Unpaid Wei amount"],
                ['data:unpaid_eth',         'float',    'yes', "Unpaid ETH amount"],
                ['data:withdrawed_wei',     'string',   'yes', "Withdrawed Wei amount"],
                ['data:withdrawed_eth',     'float',    'yes', "Withdrawed ETH amount"],
                ['data:total_wei',          'string',   'yes', "Total Wei amount (unpaid + withdrawed)"],
                ['data:total_eth',          'float',    'yes', "Total ETH amount (unpaid + withdrawed)"],
                ['data:withdrawalCount',    'integer',  'yes', "Count of member withdrawals"],
                ['data:share',              'integer',  'yes', "Percent of mining profits"],
            ],
        },
        {
            method          => "eth.contract.CMR_Mining.memberIndex",
            title           => "Read all member addresses from 'CMR_Mining' contract",
            note            => "",
            parameterTable  => [],
            requestExample  => qq~
// use contract 'CMR_Mining'
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.memberIndex"}'
            ~,
            returnDataTable => [
                ['data:memberIndex',        'array[]',   'yes',     "array[] with 'string' of all member addresses"],
            ],
        },
        {
            method          => "eth.contract.CMR_Mining.logs",
            title           => "Get logs from 'CMR_Mining' contract",
            note            => "'topic' is the type definition of an event function, e.g. Solidity: <code>event Transfer(address indexed from, address indexed to, uint256 value);</code> will be 'topic': <code>Transfer(address,address,uint256)</code> 
                <p><u>Available 'topics' in CMR_Mining contract:</u>
    event AddMember;
    event Withdraw;
    event Deposit;
                </br> <code>AddMember(address,uint256)</code>
                </br> <code>Withdraw(address,uint256)</code>
                </br> <code>Deposit(address,uint256)</code>
                </p>
            ",
            parameterTable  => [
                ['params:topic',    'string',   'false','',                 "Event 'topic'[0] to filter for 'Event-function definition string' which will be converted to Keccak-256 'topic'[0]. </br><em>If not set the two additional parameter 'data' and 'topics' with the original ABI encoded data of this event will be returned.</em>"],
                ['params:topics',   'array[]',  'false','[]',               "Filter topics, \"contract\" <em>(will be auto converted to contract address)</em>, pure ETH-addresses in any capitalization, or 32Byte-DATA raw topics to filter for.</br><em>Order dependend! Each topic can also be an Array[] of addresses, or DATA with 'or' options.</em>"],
                ['params:fromBlock','integer',  'false','contract-creation',"Starting block for fetching logs from Node."],
                ['params:toBlock',  'integer',  'false','latest',           "Ending block for fetching logs from Node."],
                ['params:showtx',   'integer',  'false','2',                "If 0 only tx_hash of the event, if 1 the full tx-details of the event, or 2 an empty transactions-array[] will be returned."],
                ['params:showraw',  'bool',     'false','false',            "Show also the raw-data for an event, which can be used later in the 'topics'-filter. <em>(Topic[0] is excluded if 'params:topic'!)</em>"],
            ],
            requestExample  => qq~
// Get all event logs from CMR_Mining contract, returns ABI-encoded event data:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs"}'

// Get 'AddMember' event logs from CMR_Mining contract, returns decoded human readable 'event_data' parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"AddMember(address,uint256)"}}'

// Get 'Deposit' event logs from CMR_Mining contract, returns decoded human readable 'event_data' parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"Deposit(address,uint256)"}}'

// Get 'Withdraw' event logs from CMR_Mining contract, returns decoded human readable 'event_data' parameter:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"Withdraw(address,uint256)"}}'

// Get (decoded) 'Withdraw' event logs from CMR_Mining contract, filter for to-address '0xE517CB63e4dD36533C26b1ffF5deB893E63c3afA':
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"Withdraw(address,uint256)","topics":["0xE517CB63e4dD36533C26b1ffF5deB893E63c3afA"]}}'

// Get (decoded) 'Withdraw' event logs from CMR_Mining contract, filter for to-address '0xE517CB63e4dD36533C26b1ffF5deB893E63c3afA' OR '0x430e1dd1ab2E68F201B53056EF25B9e116979D9b:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"Withdraw(address,uint256)","topics":[["0xE517CB63e4dD36533C26b1ffF5deB893E63c3afA","0x430e1dd1ab2E68F201B53056EF25B9e116979D9b"]]}}'


// Get raw event data additional to the decoded DATA for the Transfer events:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"Deposit(address,uint256)","showraw":true}}'

// showtx example:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"Deposit(address,uint256)","showtx":1}}'

// showtx and showraw can be used anytime:
curl http://$ENV{HTTP_HOST} -d '{"method":"eth.contract.CMR_Mining.logs","params":{"topic":"Deposit(address,uint256)","showtx":1,"showraw":true}}'
            ~,
            returnDataTable => [
                ['data:*',        '*',   'yes', "See generic method <a href='#eth.contract.logs'>eth.contract.logs</a> for return data."],
            ],
        },
    ]);
 
 
    API::html::readme::print::ReadmeClass('endReadme',$cgi);
}


1;
