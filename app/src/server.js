const app = require('./app');

const PORT = process.env.PORT || 8080;

const server = app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
});

// Kubernetes sends SIGTERM before stopping a pod:
// stop accepting new connections, finish in-flight requests, then exit
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down');
  server.close(() => process.exit(0));
});