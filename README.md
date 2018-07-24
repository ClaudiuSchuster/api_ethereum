## api_ethereum ( API on: ethereum.spreadblock.local:88 / 10.10.0.8:88 )

### Service URLs
* JSON-API: http://10.10.0.8:88/
* API-Documentation: http://10.10.0.8:88/readme

### Test-Contract:
 Distribution: https://rinkeby.etherscan.io/address/0xcb682d89265ab8c7ffa882f0ceb799109bc2a8b0 \
 Mining: https://rinkeby.etherscan.io/address/0x1c5b5e9e527b41f055a88695e8c0349caec9b5a6

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
