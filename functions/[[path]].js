const flareHost = "flareua.pages.dev";

const mobileConfig = `<?xml version="1.0" encoding="UTF-8"?>
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
            <string>${flareHost}</string>
            <key>HTTPPort</key>
            <integer>443</integer>
            <key>HTTPSEnable</key>
            <integer>1</integer>
            <key>HTTPSProxy</key>
            <string>${flareHost}</string>
            <key>HTTPSPort</key>
            <integer>443</integer>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>FlareUA Proxy</string>
    <key>PayloadIdentifier</key>
    <string>com.flareua.profile</string>
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

export async function onRequest(context) {
    const request = context.request;
    const url = new URL(request.url);

    if (url.pathname === "/profile") {
        return new Response(mobileConfig, {
            headers: {
                "Content-Type": "application/x-apple-aspen-config",
                "Content-Disposition": 'attachment; filename="FlareUA.mobileconfig"',
            },
        });
    }

    // /flareua-probe on ANY host = proxied probe request intercepted by our worker
    if (url.pathname === "/flareua-probe" && request.headers.get("X-FlareUA-Probe") === "1") {
        return new Response(JSON.stringify({ proxied: true }), {
            headers: { "Content-Type": "application/json" },
        });
    }

    // Direct probe to our own host = not proxied
    if (url.pathname === "/probe") {
        return new Response(JSON.stringify({ proxied: false }), {
            headers: { "Content-Type": "application/json" },
        });
    }

    if (url.pathname === "/flareua-health") {
        return new Response(JSON.stringify({ status: "ok", version: "1.0.0" }), {
            headers: { "Content-Type": "application/json" },
        });
    }

    const customUA = request.headers.get("X-FlareUA-Agent");
    const newHeaders = new Headers(request.headers);
    if (customUA) {
        newHeaders.set("User-Agent", customUA);
        newHeaders.delete("X-FlareUA-Agent");
    }

    try {
        const response = await fetch(new Request(request, { headers: newHeaders }));
        return new Response(response.body, {
            status: response.status,
            statusText: response.statusText,
            headers: response.headers,
        });
    } catch (err) {
        return new Response("FlareUA error: " + err.message, { status: 502 });
    }
}
