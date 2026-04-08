export async function onRequest(context) {
  const request = context.request;
  const url = new URL(request.url);

  if (url.pathname === '/flareua-health') {
    return new Response(JSON.stringify({ status: 'ok', version: '1.0.0' }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }

  const customUA = request.headers.get('X-FlareUA-Agent');

  const newHeaders = new Headers(request.headers);
  if (customUA) {
    newHeaders.set('User-Agent', customUA);
    newHeaders.delete('X-FlareUA-Agent');
  }

  try {
    const response = await fetch(new Request(request, { headers: newHeaders }));
    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers
    });
  } catch (err) {
    return new Response('FlareUA error: ' + err.message, { status: 502 });
  }
}
