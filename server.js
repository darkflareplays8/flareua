const http = require("http");
const net = require("net");
const url = require("url");

const PORT = process.env.PORT || 8080;
const UA_HEADER = "x-flareua-agent";

function rewriteUA(headers, customUA) {
  const out = { ...headers };
  if (customUA) out["user-agent"] = customUA;
  delete out[UA_HEADER];
  delete out["proxy-connection"];
  delete out["proxy-authorization"];
  return out;
}

const server = http.createServer((req, res) => {
  if (req.url === "/flareua-health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", version: "2.0.0" }));
    return;
  }

  if (req.url === "/flareua-probe") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ proxied: true }));
    return;
  }

  const parsedUrl = url.parse(req.url);
  const customUA = req.headers[UA_HEADER];
  const outHeaders = rewriteUA(req.headers, customUA);

  const proxy = http.request({
    hostname: parsedUrl.hostname,
    port: parsedUrl.port || 80,
    path: parsedUrl.path,
    method: req.method,
    headers: outHeaders,
  }, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res, { end: true });
  });

  proxy.on("error", (err) => {
    res.writeHead(502);
    res.end("FlareUA error: " + err.message);
  });

  req.pipe(proxy, { end: true });
});

server.on("connect", (req, clientSocket, head) => {
  const [hostname, portStr] = req.url.split(":");
  const port = parseInt(portStr, 10) || 443;

  const serverSocket = net.connect(port, hostname, () => {
    clientSocket.write("HTTP/1.1 200 Connection Established\r\n\r\n");
    if (head && head.length > 0) serverSocket.write(head);
    serverSocket.pipe(clientSocket, { end: true });
    clientSocket.pipe(serverSocket, { end: true });
  });

  serverSocket.on("error", () => {
    clientSocket.write("HTTP/1.1 502 Bad Gateway\r\n\r\n");
    clientSocket.destroy();
  });

  clientSocket.on("error", () => serverSocket.destroy());
});

server.listen(PORT, () => {
  console.log(`FlareUA proxy listening on port ${PORT}`);
});
