const {
  parentPort
} = require('worker_threads');
while (true) {
  for (let num = 1; num < 10000000; num++) {
    let isPrime = true;
    if (num > 1) {
      for (let i = 2; i < num; i++) {
        if (num % i == 0) {
          isPrime = false;
          break;
        }
      }
    }
    if (isPrime) {
      parentPort.postMessage(num);
    }
  }
}