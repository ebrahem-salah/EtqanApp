const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.mp4': 'video/mp4',
  '.json': 'application/json; charset=utf-8',
  '.ttf': 'font/ttf'
};

function requestHandler(req, res) {
  let reqPath = req.url.split('?')[0];
  if (reqPath === '/' || reqPath === '') reqPath = '/preview.html';
  const filePath = path.join(__dirname, decodeURIComponent(reqPath));

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      res.writeHead(404, {'Content-Type': 'text/plain; charset=utf-8'});
      res.end('404 Not Found: ' + reqPath);
      return;
    }
    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME[ext] || 'application/octet-stream';
    res.writeHead(200, {
      'Content-Type': contentType,
      'Access-Control-Allow-Origin': '*'
    });
    fs.createReadStream(filePath).pipe(res);
  });
}

// 1. Primary Server on port 8080 (Dual-stack IPv4/IPv6)
const server = http.createServer(requestHandler);
server.listen(PORT, () => {
  console.log(`Etqan Mobile Server running on port ${PORT}!`);
  console.log(`Local (PC):    http://localhost:${PORT}/preview.html`);
  console.log(`Local (IP):    http://127.0.0.1:${PORT}/preview.html`);
  console.log(`Mobile Phone:  http://192.168.1.78:${PORT}/preview.html`);
});

// 2. Also listen on port 80 if available for direct 'http://localhost' access without port
try {
  const server80 = http.createServer(requestHandler);
  server80.listen(80, () => {
    console.log(`Direct access active: http://localhost/ (port 80)`);
  });
  server80.on('error', (err) => {
    // Port 80 not available or needs elevation, ignore
  });
} catch (e) {}
