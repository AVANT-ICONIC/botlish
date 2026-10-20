#!/usr/bin/env bash
# ios-run.sh APP-BUNDLE OUT -- boots an available iPhone simulator, installs
# and launches the probe app and keeps its BOTLISH_PROBE log lines in OUT
# (exit 1 unless the probe's last line, "done", arrives within three
# minutes).
set -euo pipefail
bundle=$1
out=$2
udid=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
for runtime in sorted(devices, reverse=True):
    if "iOS" in runtime:
        for d in devices[runtime]:
            if d["name"].startswith("iPhone"):
                print(d["udid"]); sys.exit(0)
sys.exit("no iPhone simulator")')
echo "simulator $udid"
xcrun simctl boot "$udid" || true
xcrun simctl bootstatus "$udid" -b
xcrun simctl install "$udid" "$bundle"
xcrun simctl launch "$udid" org.botlish.probeapp
for _ in $(seq 1 90); do
  if xcrun simctl spawn "$udid" log show --last 5m --style compact --predicate 'eventMessage CONTAINS "BOTLISH_PROBE"' 2>/dev/null | grep -q "BOTLISH_PROBE done"; then
    break
  fi
  sleep 2
done
xcrun simctl spawn "$udid" log show --last 5m --style compact --predicate 'eventMessage CONTAINS "BOTLISH_PROBE"' > "$out" || true
cat "$out"
grep -q "BOTLISH_PROBE done" "$out"
