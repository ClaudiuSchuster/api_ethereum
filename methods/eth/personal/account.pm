package API::methods::eth::personal::account;

use strict; use warnings; use utf8; use feature ':5.10';


sub address {
    return $API::node eq 'rinkeby' ? "0xRinkebyAddr"
         : $API::node ne 'infura'  ? "0xMainnetAddr"
         : "";
}
sub password {
    return $API::node eq 'rinkeby' ? "RinkebyPassword"
         : $API::node ne 'infura'  ? "MainnetPassword"
         : "";
}
sub krakenAddress {
    return $API::node !~ /infura|rinkeby/ ? "0xD6a033F1C688752bb8508c1e48e5cCf0d42b5fdC" : 0;
}


sub defaultApiEndpoint {
    return 'http://127.0.0.1:8545/';
}
sub rinkebyApiEndpoint {
    return 'http://rinkeby.node.local:8545/';
}
sub infuraApiEndpoint {
    return $API::node eq 'rinkeby' ? "https://rinkeby.infura.io/v3/API-KEY"
                                   : "https://mainnet.infura.io/v3/API-KEY";
}


sub contracts {
    return {              # contracts-address, creation-block, crowdsale-finished-block or 0 for eth.node.block
        SmartMining => 
            $API::node ? ['0x02eaedebcf8a9cbe589da3aea60fec1716b225b6', 2949383, 0]
                       : ['0x0000000000000000000000000000000000000000', 0, 0],
        SmartMining_Mining => 
            $API::node ? ['0x281403f48b63e0757c54e3de529647cb082c9dec', 2949402, 0]
                       : ['0x0000000000000000000000000000000000000000', 0, 0],
        SmartMining_Team => 
            $API::node ? ['0x0000000000000000000000000000000000000000', 0, 0]
                       : ['0x0000000000000000000000000000000000000000', 0, 0],
    };
}


1;
