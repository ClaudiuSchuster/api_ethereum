#!/usr/bin/nodejs

var args = process.argv.slice(2);

const InputDataDecoder = require('ethereum-input-data-decoder');
const decoder = new InputDataDecoder('./contracts/' + args[0] + '.abi');
const result = decoder.decodeData(args[1]);


process.stdout.write( JSON.stringify(result, null, 4) );