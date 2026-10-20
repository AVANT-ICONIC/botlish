#!/usr/bin/env bash
# ios-run.sh APP-BUNDLE OUT -- boots an available iPhone simulator, installs
# and launches the probe app and keeps its BOTLISH_PROBE log lines in OUT
# (exit 1 unless the probe's last line, "done", arrives within three
# minutes). React Native logs console.log at info level through os_log,
# which `log show` omits and may not persist, so the log is streamed live
# from before the launch.
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
: > "$out.stream"
xcrun simctl spawn "$udid" log stream --level info --style compact \
  --predicate 'eventMessage CONTAINS "BOTLISH_PROBE" OR (process == "BotlishProbeApp" AND messageType == fault)' \
  > "$out.stream" 2>&1 &
streamer=$!
sleep 3
xcrun simctl launch "$udid" org.botlish.probeapp
for _ in $(seq 1 90); do
  if grep -q "BOTLISH_PROBE done" "$out.stream"; then
    break
  fi
  sleep 2
done
kill "$streamer" || true
grep "BOTLISH_PROBE\|fault" "$out.stream" > "$out" || true
cat "$out"
if ! grep -q "BOTLISH_PROBE done" "$out"; then
  echo "== no probe output. The bundle's JS:"
  ls -l "$bundle" | grep -i "jsbundle" || echo "no main.jsbundle in the app"
  echo "== the app's process:"
  xcrun simctl spawn "$udid" launchctl list | grep -i probeapp || echo "not running"
  echo "== the app's own log (last 10 minutes):"
  xcrun simctl spawn "$udid" log show --last 10m --info --debug --style compact \
    --predicate 'process == "BotlishProbeApp"' 2>/dev/null | grep -v "^Timestamp" | tail -120 || true
  echo "== crash reports:"
  for report in $(ls -t ~/Library/Logs/DiagnosticReports 2>/dev/null | head -5); do
    echo "-- $report"
    grep -i -m1 -A3 '"exception"\|Exception Type' ~/Library/Logs/DiagnosticReports/"$report" || true
    grep -m 25 -E 'rnprobe|botlish|Botlish|BotlishProbeApp' ~/Library/Logs/DiagnosticReports/"$report" || true
  done
  exit 1
fi
