#!/usr/bin/nodejs

var http = require('http');

var Web3 = require('web3');
var web3 = new Web3();

eventDecoder = http.createServer( function(req, res) {
        var data = '';
        req.on('data', function (postdata) {
            data += postdata;
        });
        req.on('end', function () {
            // console.log("____data_in: " + data);
            try {
                var log = JSON.parse(data);
                var result = web3.eth.abi.decodeLog(log.abi, log.data, log.topics);
                data = JSON.stringify(result);
                // console.log("____result: " + data);
                res.writeHead(200, {'Content-Type': 'application/json'});
                res.end(data);
            } catch(err) {
                res.writeHead(400, {'Content-Type': 'application/json'});
                // console.log("____error: " + err.message);
                res.end('["____error: ' + err.message + '"]');
            }
        });

});

var args = process.argv.slice(2);

port = args[0];
host = '0.0.0.0';
eventDecoder.listen(port, host);
console.log('eventDecoder listening at http://' + host + ':' + port);







// #!/usr/bin/nodejs

// var args = process.argv.slice(2);

// const InputDataDecoder = require('ethereum-input-data-decoder');
// const decoder = new InputDataDecoder('./contracts/' + args[0] + '.abi');
// const result = decoder.decodeData(args[1]);


// process.stdout.write( JSON.stringify(result, null, 4) );