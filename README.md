## api_ethereum ( API on: ethereum.spreadblock.local:88 / 10.10.0.8:88 )

### Service URLs
* JSON-API: http://10.10.0.8:88/
* API-Documentation: http://10.10.0.8:88/readme

### Test-Contract:
 IceMine: https://rinkeby.etherscan.io/address/0xb5Ec6824E872A756Bb1e9Df8c6621F31723CEa52#code \
 IceMine_Team:  \
 IceMine_Mining: https://rinkeby.etherscan.io/address/0xabBD3f423CaF2571116750c21a981532Ee1D7065#code

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
