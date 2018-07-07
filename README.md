## api_ethereum ( API on: ethereum.spreadblock.local:88 / 10.10.0.8:88 )

### Service URLs


* API: http://10.10.0.8:88/
* API-Documentation: http://10.10.0.8:88/readme
* Simple frontend: http://10.10.0.8:88/eth


### api.service systemd definition:

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
