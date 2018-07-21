#!/usr/bin/nodejs

const InputDataDecoder = require('ethereum-input-data-decoder');
const decoder = new InputDataDecoder(`./contracts/IceMine.abi`);
const data = `0x383e0a810000000000000000000000002d6650fb71d71bc62848b24c2b427e83fd9a512a0000000000000000000000000000000000000000000000000000000000000000`;

const result = decoder.decodeData(data);

console.log(result);
