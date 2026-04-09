const http = require("http");
const net = require("net");
const url = require("url");

const PORT = process.env.PORT || 8080;
const UA_HEADER = "x-flareua-agent";
const PROXY_HOST = "flareua-production.up.railway.app";
const PROXY_PORT = 8080;
const PROFILE_IDENTIFIER = "com.flareua.profile";

function rewriteUA(headers, customUA) {
  const out = { ...headers };
  if (customUA) out["user-agent"] = customUA;
  delete out[UA_HEADER];
  delete out["proxy-connection"];
  delete out["proxy-authorization"];
  return out;
}

function getMobileConfig() {
  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.proxies.managed</string>
            <key>PayloadUUID</key>
            <string>B2C3D4E5-F6A7-8901-BCDE-F12345678901</string>
            <key>PayloadIdentifier</key>
            <string>com.flareua.proxy.managed</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>HTTPEnable</key>
            <integer>1</integer>
            <key>HTTPProxy</key>
            <string>${PROXY_HOST}</string>
            <key>HTTPPort</key>
            <integer>${PROXY_PORT}</integer>
            <key>HTTPSEnable</key>
            <integer>1</integer>
            <key>HTTPSProxy</key>
            <string>${PROXY_HOST}</string>
            <key>HTTPSPort</key>
            <integer>${PROXY_PORT}</integer>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>FlareUA Proxy</string>
    <key>PayloadIdentifier</key>
    <string>${PROFILE_IDENTIFIER}</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>C3D4E5F6-A7B8-9012-CDEF-123456789012</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadDescription</key>
    <string>Routes HTTP/HTTPS traffic through FlareUA for User-Agent rewriting.</string>
    <key>PayloadOrganization</key>
    <string>FlareUA</string>
</dict>
</plist>`;
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

  if (req.url === "/profile") {
    const config = getMobileConfig();
    res.writeHead(200, {
      "Content-Type": "application/x-apple-aspen-config",
      "Content-Disposition": 'attachment; filename="flareua.mobileconfig"',
    });
    res.end(config);
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
