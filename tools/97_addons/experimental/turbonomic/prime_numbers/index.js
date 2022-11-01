let express = require('express');
let app = express();
let latestPrime;

const { Worker } = require('worker_threads');

const worker = new Worker('./prime_numbers.js');
worker.on('message', (msg) => latestPrime = msg);

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
  console.log({latestPrime:latestPrime});
}

setInterval(state, 2500);