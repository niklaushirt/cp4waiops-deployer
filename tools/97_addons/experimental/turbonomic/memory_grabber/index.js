let express = require('express');
let app = express();
let latestPrime;
let primesFound;

let primes = [];

const { Worker } = require('worker_threads');

const worker = new Worker('./memory_grabber.js');
worker.on('message', (msg) => { 
  latestPrime = msg.latestPrime; 
  primesFound= msg.primesFound; 
});

app.get('/latest', (req,res) => {
  console.log({ latestPrime: latestPrime});
  res.json({ latestPrime: latestPrime});
});


let server = app.listen(process.env.PORT || 8080, function () {
  let host = server.address().address;
  let port = server.address().port;
  console.log('Listening at http://%s:%s', host, port);
});


function state() {
  console.log({latestPrime: latestPrime, primesFound: primesFound, memoryUsed: process.memoryUsage()});
}

setInterval(state, 2500);