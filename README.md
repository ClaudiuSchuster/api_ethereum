## api_ethereum

### Service URLs
* JSON-API: http://<ip>:88/
* API-Documentation: http://<ip>:88/readme

### Ethereum Contract ABI Converter:
 - https://abi.sonnguyen.ws/
 
### Rinkeby Authenticated Faucet:
 - https://www.rinkeby.io/#faucet

### Perl Dependencies Installation Commands:
apt update && apt install cpan libio-socket-inet6-perl libssl-dev libz-dev \
cpan App::cpanminus \
cpanm HTTP::Server::Simple::CGI::PreFork File::Slurper HTTP::Request LWP::UserAgent LWP::Protocol::https Math::BigInt Math::BigFloat JSON
 
### Perl Dependencies:
 - HTTP::Server::Simple::CGI::PreFork   (requires IPv6 or libio-socket-inet6-perl and debian packages 'libssl-dev' & 'libz-dev')
 - File::Slurper
 - HTTP::Request
 - LWP::UserAgent
 - LWP::Protocol::https
 - Math::BigFloat
 - Math::BigInt
 - JSON
 - *______ below should be installed by previous automatically ______*
 - HTTP::Server::Simple
 - IO::Socket::INET6  (if libio-socket-inet6-perl is not installed / only IPv4 as example)
 - Net::Server
 - Net::Server::PreFork
 - Net::Server::Proto::SSLEAY
 - Net::Server::Single
 - Net::SSLeay
 - Socket6
 - *. . . and possibly others . . .*
