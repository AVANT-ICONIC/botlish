// App.tsx -- the probe app's only hand-written file (REACT-NATIVE-TARGET-
// CENSUS.md): an ordinary React Native 0.88 app (`@react-native-community/cli
// init`) with the generated package installed from its npm tarball. It calls
// every export once, logs one "BOTLISH_PROBE" line per call (read back from
// logcat or the simulator's log) and shows the same lines on screen.
import React, { useEffect, useState } from 'react';
import { ScrollView, Text } from 'react-native';
import { add, depth, pick, requirePositive, reverse, same } from 'react-native-botlish-probe';

function attempt(label: string, f: () => unknown): string {
  try {
    return `${label} => ${JSON.stringify(f())}`;
  } catch (e: any) {
    return `${label} threw ${e?.name} ${e?.code} ${JSON.stringify(e?.message)}`;
  }
}

function probe(): string[] {
  const lines = [
    attempt('add(2, 3)', () => add(2, 3)),
    attempt('add(2**53 - 1, 1)', () => add(2 ** 53 - 1, 1)),
    attempt('add(1.5, 1)', () => add(1.5, 1)),
    attempt('reverse("héllo, wörld")', () => reverse('héllo, wörld')),
    attempt('reverse("a😀b")', () => reverse('a\u{1F600}b')),
    attempt('requirePositive(5)', () => requirePositive(5)),
    attempt('requirePositive(-1)', () => requirePositive(-1)),
    attempt('depth(1000)', () => depth(1000)),
    attempt('same("añb", "añb")', () => same('añb', 'añb')),
    attempt('pick(false, "left", "right")', () => pick(false, 'left', 'right')),
  ];
  let last = '';
  const t0 = Date.now();
  for (let i = 0; i < 100000; i++) {
    last = reverse('x' + i + 'y');
  }
  lines.push(`100000 reverse calls => ${JSON.stringify(last)} in ${Date.now() - t0} ms`);
  lines.push('done');
  return lines;
}

export default function App(): React.JSX.Element {
  const [lines, setLines] = useState<string[]>([]);
  useEffect(() => {
    const result = probe();
    result.forEach(line => console.log(`BOTLISH_PROBE ${line}`));
    setLines(result);
  }, []);
  return (
    <ScrollView contentInsetAdjustmentBehavior="automatic" style={{ padding: 24 }}>
      {lines.map(line => (
        <Text key={line}>{line}</Text>
      ))}
    </ScrollView>
  );
}
