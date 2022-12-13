import http from 'k6/http';
import { sleep } from 'k6';
import { check } from 'k6';
export const options = {
  vus: 10,
  duration: '30s',
};
export default function () {
  const res = http.get('https://ratings-robot-shop.itzroks-270003bu3k-rt8vw8-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/api/fetch/UHJ');
  check(res, {
    'verify homepage text': (r) =>
    r.body.includes('avg_rating'),
  });
  sleep(1);
}
