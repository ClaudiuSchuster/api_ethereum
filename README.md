## api_ethereum ( API on: ethereum.spreadblock.local:88 / 10.10.0.8:88 )

### Service URLs
* JSON-API: http://10.10.0.8:88/
* API-Documentation: http://10.10.0.8:88/readme

### Test-Contract:
 IceMine: https://rinkeby.etherscan.io/address/0x4ddeb637a8f389b3201708a48bb23af48bb4eb4b#code \
 IceMine_Team:  \
 IceMine_Mining: https://rinkeby.etherscan.io/address/0x24a0ee63ead1e60c8f7b2cd8c61cf65d6198b8e2#code

### Ethereum Contract ABI Converter:
 - https://abi.sonnguyen.ws/
 
### Rinkeby Authenticated Faucet:
 - https://www.rinkeby.io/#faucet
 - https://twitter.com/ClaudiuSchuster/status/1015429498765041665


### Perl Dependencies:
 - HTTP-Server-Simple-CGI-PreFork   (requires IPv6 and debian packages 'libssl-dev' & 'libz-dev')
 - File::Slurper
 - HTTP::Request
 - LWP::UserAgent
 - Math::BigFloat
 - Math::BigInt
 - JSON
 - *______ below should be installed by previous automatically ______*
 - HTTP::Server::Simple
 - IO::Socket::INET6
 - Net::Server
 - Net::Server::PreFork
 - Net::Server::Proto::SSLEAY
 - Net::Server::Single
 - Net::SSLeay
 - Socket6
 - *. . . and possibly others . . .*
