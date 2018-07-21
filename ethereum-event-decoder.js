#!/usr/bin/nodejs

var args = process.argv.slice(2);

var Web3 = require('web3');
var web3 = new Web3();

const log = JSON.parse(args[0]);
const result = web3.eth.abi.decodeLog(log.abi, log.data, log.topics)

JSON.stringify(result, null, 4)
process.stdout.write( JSON.stringify(result, null, 4) );