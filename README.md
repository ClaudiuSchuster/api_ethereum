## api_ethereum ( API on: ethereum.spreadblock.local:88 / 10.10.0.8:88 )

### Service URLs


* API: http://10.10.0.8:88/
* API-Documentation: http://10.10.0.8:88/readme
* Simple frontend: http://10.10.0.8:88/eth


### api.service Systemd Definition:

    [Unit]
    Description=api.pl
    After=syslog.target network.target remote-fs.target nss-lookup.target
     
    [Service]
    WorkingDirectory=/ethereum/api
     
    ExecStart=/bin/sh -c "/ethereum/api/api.pl 88 >> /ethereum/api/log.log 2>&1"
     
    Type=simple
    Restart=on-failure
     
     
    [Install]
    WantedBy=multi-user.target


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


### Rinkeby Authenticated Faucet:
 - https://www.rinkeby.io/#faucet
 - https://twitter.com/ClaudiuSchuster/status/1015429498765041665
 
