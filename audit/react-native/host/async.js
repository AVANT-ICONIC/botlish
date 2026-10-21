// async.js -- host_async.cpp's script: Promise-returning Botlish calls run on
// the module's worker thread while the JS thread goes on.
const A = globalThis.__turboModuleProxy('BotlishAsync');
globalThis.done = false;
const t0 = Date.now();
const deep = A.depth(1000000);
print('depth(1000000) returned a', Object.prototype.toString.call(deep), 'after', Date.now() - t0, 'ms');
const many = [];
for (let i = 0; i < 1000; i++) many.push(A.reverse('x' + i + 'é'));
Promise.all([deep, A.reverse('héllo, wörld'), Promise.all(many)])
  .then(([d, r, m]) => {
    print('depth(1000000) =>', d, 'after', Date.now() - t0, 'ms');
    print('reverse("héllo, wörld") =>', JSON.stringify(r));
    print('1000 queued reverse calls, last =>', JSON.stringify(m[999]));
  })
  .catch(e => print('rejected', e.name, JSON.stringify(e.message)))
  .finally(() => { globalThis.done = true; });
// Left unsettled when the runtime is torn down:
A.depth(10);
