// probe.js -- what an app's JS does with the probe module: under the New
// Architecture TurboModuleRegistry.getEnforcing(name) is
// global.__turboModuleProxy(name). Prints one line per call.
const BotlishProbe = globalThis.__turboModuleProxy('BotlishProbe');
if (BotlishProbe == null) throw new Error('BotlishProbe not registered');
function attempt(label, f) {
  try { print(label, '=>', JSON.stringify(f())); }
  catch (e) { print(label, 'threw', e.name, e.code, JSON.stringify(e.message)); }
}
attempt('add(2, 3)', () => BotlishProbe.add(2, 3));
attempt('add(-7, 2**52)', () => BotlishProbe.add(-7, 2 ** 52));
attempt('add(2**53 - 1, 1)', () => BotlishProbe.add(2 ** 53 - 1, 1));
attempt('add(1.5, 1)', () => BotlishProbe.add(1.5, 1));
attempt('add(NaN, 1)', () => BotlishProbe.add(NaN, 1));
attempt('add("2", 1)', () => BotlishProbe.add('2', 1));
attempt('add(1)', () => BotlishProbe.add(1));
attempt('reverse("héllo, wörld")', () => BotlishProbe.reverse('héllo, wörld'));
attempt('reverse("a😀b")', () => BotlishProbe.reverse('a\u{1F600}b'));
attempt('reverse("\\ud800")', () => BotlishProbe.reverse('\ud800'));
attempt('reverse("")', () => BotlishProbe.reverse(''));
attempt('requirePositive(5)', () => BotlishProbe.requirePositive(5));
attempt('requirePositive(-1)', () => BotlishProbe.requirePositive(-1));
attempt('depth(1000)', () => BotlishProbe.depth(1000));
let last = '';
const t0 = Date.now();
for (let i = 0; i < 100000; i++) last = BotlishProbe.reverse('x' + i + 'y');
print('100000 reverse calls, last =>', JSON.stringify(last), 'in', Date.now() - t0, 'ms');
