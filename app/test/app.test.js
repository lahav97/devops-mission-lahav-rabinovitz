const { test, before, after } = require('node:test');
const assert = require('node:assert');
const { once } = require('node:events');

// Must be set before the app is loaded
process.env.APP_VERSION = 'test-version';
const app = require('../src/app');

let server;
let baseUrl;

before(async () => {
  server = app.listen(0); // random free port
  await once(server, 'listening');
  baseUrl = `http://localhost:${server.address().port}`;
});

after(() => server.close());

test('GET / returns an HTML page with the version', async () => {
  const res = await fetch(`${baseUrl}/`);
  assert.strictEqual(res.status, 200);
  assert.match(res.headers.get('content-type'), /text\/html/);
  assert.match(await res.text(), /test-version/);
});

test('GET /healthz returns 200', async () => {
  const res = await fetch(`${baseUrl}/healthz`);
  assert.strictEqual(res.status, 200);
});