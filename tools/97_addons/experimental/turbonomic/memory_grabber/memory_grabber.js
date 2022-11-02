const {
  parentPort
} = require('worker_threads');

let prime = [];

while (true) {
  for (let num = 1; num < 1000000000; num++) {
    let isPrime = true;
    if (num > 1) {
      for (let i = 1; i < prime.length; i++) {
        if (prime[i] > Math.sqrt(num)) {
          break;
        }
        if (num % prime[i] == 0) {
          isPrime = false;
          break;
        }
      }
    }
    if (isPrime) {
      prime.push(num);
      parentPort.postMessage({
        latestPrime: num,
        primesFound: prime.length
      });
    }
  }
}