const http = require('http');
const https = require('https');
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
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, Accept, X-Requested-With'
    });
    res.end();
    return;
  }

  // Live Backend Proxy Route: /api/v1/* -> https://www.etqan.site/api/v1/*
  if (req.url.startsWith('/api/v1/')) {
    const backendPath = req.url;
    const targetUrl = 'https://www.etqan.site' + backendPath;

    const proxyHeaders = {
      'Accept': req.headers['accept'] || 'application/json',
      'Content-Type': req.headers['content-type'] || 'application/json',
      'User-Agent': 'EtqanMobileApp/2.0'
    };
    if (req.headers['authorization']) {
      proxyHeaders['Authorization'] = req.headers['authorization'];
    }

    const proxyReq = https.request(targetUrl, {
      method: req.method,
      headers: proxyHeaders
    }, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, {
        'Content-Type': proxyRes.headers['content-type'] || 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      });
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (err) => {
      console.warn('Proxy error for', targetUrl, ':', err.message);
      // Fallback to local real data dump if available
      const cleanName = backendPath.replace('/api/v1/', '').split('?')[0].split('/')[0];
      const fallbackFile = path.join(__dirname, 'assets', 'data', cleanName + '.json');
      if (fs.existsSync(fallbackFile)) {
        res.writeHead(200, {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*'
        });
        fs.createReadStream(fallbackFile).pipe(res);
      } else {
        res.writeHead(502, {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*'
        });
        res.end(JSON.stringify({ error: 'Backend unreachable', details: err.message }));
      }
    });

    req.pipe(proxyReq);
    return;
  }

  // Static File Serving
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
  console.log(`Etqan Mobile Server with Live Backend Proxy running on port ${PORT}!`);
  console.log(`Local (PC):    http://localhost:${PORT}/preview.html`);
  console.log(`Local (IP):    http://127.0.0.1:${PORT}/preview.html`);
  console.log(`API Proxy:     http://localhost:${PORT}/api/v1/videos`);
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
