// Minimal Chrome DevTools Protocol driver using Node's native WebSocket.
const wsUrl = process.env.CDP_WS;
const ws = new WebSocket(wsUrl);
let id = 0;
const pending = new Map();

function send(method, params = {}) {
  const msgId = ++id;
  return new Promise((resolve, reject) => {
    pending.set(msgId, { resolve, reject });
    ws.send(JSON.stringify({ id: msgId, method, params }));
  });
}

ws.addEventListener('message', (event) => {
  const msg = JSON.parse(event.data);
  if (msg.id && pending.has(msg.id)) {
    const { resolve, reject } = pending.get(msg.id);
    pending.delete(msg.id);
    if (msg.error) reject(new Error(JSON.stringify(msg.error)));
    else resolve(msg.result);
  }
});

function wait(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

const consoleMessages = [];
ws.addEventListener('message', (event) => {
  const msg = JSON.parse(event.data);
  if (msg.method === 'Runtime.consoleAPICalled') {
    consoleMessages.push(msg.params.args.map((a) => a.value ?? a.description).join(' '));
  }
  if (msg.method === 'Runtime.exceptionThrown') {
    consoleMessages.push('EXCEPTION: ' + JSON.stringify(msg.params.exceptionDetails.exception?.description ?? msg.params.exceptionDetails));
  }
});

await new Promise((resolve) => ws.addEventListener('open', resolve));
await send('Page.enable');
await send('Runtime.enable');

const script = process.argv[2];
const steps = JSON.parse(script);

for (const step of steps) {
  if (step.type === 'viewport') {
    await send('Emulation.setDeviceMetricsOverride', {
      width: step.width,
      height: step.height,
      deviceScaleFactor: 1,
      mobile: false,
    });
  } else if (step.type === 'nav') {
    await send('Page.navigate', { url: step.url });
    await wait(step.wait ?? 2000);
  } else if (step.type === 'eval') {
    const result = await send('Runtime.evaluate', { expression: step.expr, returnByValue: true, awaitPromise: true });
    console.log('EVAL RESULT:', JSON.stringify(result.result?.value ?? result.result));
  } else if (step.type === 'wait') {
    await wait(step.ms);
  } else if (step.type === 'click') {
    await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: step.x, y: step.y, buttons: 0 });
    await send('Input.dispatchMouseEvent', { type: 'mousePressed', x: step.x, y: step.y, button: 'left', buttons: 1, clickCount: 1 });
    await wait(60);
    await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: step.x, y: step.y, button: 'left', buttons: 0, clickCount: 1 });
    await wait(step.wait ?? 500);
  } else if (step.type === 'scroll') {
    await send('Input.dispatchMouseEvent', {
      type: 'mouseWheel', x: step.x, y: step.y, deltaX: 0, deltaY: step.deltaY,
    });
    await wait(step.wait ?? 500);
  } else if (step.type === 'type') {
    for (const char of step.text) {
      await send('Input.dispatchKeyEvent', { type: 'char', text: char });
    }
    await wait(step.wait ?? 200);
  } else if (step.type === 'key') {
    await send('Input.dispatchKeyEvent', { type: 'rawKeyDown', windowsVirtualKeyCode: step.code, key: step.key });
    await send('Input.dispatchKeyEvent', { type: 'keyUp', windowsVirtualKeyCode: step.code, key: step.key });
    await wait(step.wait ?? 300);
  } else if (step.type === 'screenshot') {
    const params = { format: 'png' };
    if (step.clip) params.clip = { ...step.clip, scale: 1 };
    const result = await send('Page.captureScreenshot', params);
    const fs = await import('node:fs');
    fs.writeFileSync(step.path, Buffer.from(result.data, 'base64'));
    console.log('SAVED', step.path);
  }
}

console.log('CONSOLE:', JSON.stringify(consoleMessages));
ws.close();
process.exit(0);
