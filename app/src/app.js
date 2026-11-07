const express = require('express');
const os = require('os');

// Change this to demo a rollout (Part 3)
const MESSAGE = 'Hello from the DevOps exercise! (v2)';

// Injected at build time / by Kubernetes; fallbacks for local runs
const VERSION = process.env.APP_VERSION || 'dev';
const POD_NAME = process.env.POD_NAME || os.hostname();

const app = express();

app.get('/', (req, res) => {
  res.type('html').send(`<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>DevOps Exercise</title></head>
<body>
  <h1>${MESSAGE}</h1>
  <p>Version: ${VERSION}</p>
  <p>Pod: ${POD_NAME}</p>
</body>
</html>`);
});

app.get('/healthz', (req, res) => {
  res.status(200).send('ok');
});

module.exports = app;