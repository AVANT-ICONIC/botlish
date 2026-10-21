#!/usr/bin/env bash
# android-run.sh APK OUT -- installs the probe app on the running emulator,
# starts it and keeps its BOTLISH_PROBE log lines in OUT (exit 1 unless the
# probe's last line, "done", arrives within three minutes).
set -euo pipefail
apk=$1
out=$2
adb wait-for-device
adb shell getprop ro.product.cpu.abi
adb install -r "$apk"
adb logcat -c
adb shell am start -W -n org.botlish.probeapp/.MainActivity
for _ in $(seq 1 90); do
  if adb logcat -d -s ReactNativeJS:V | grep -q "BOTLISH_PROBE done"; then
    break
  fi
  sleep 2
done
adb logcat -d -s ReactNativeJS:V AndroidRuntime:E DEBUG:V libc:V | tee "$out.full" | grep -E "BOTLISH_PROBE|FATAL|Fatal signal|Abort" > "$out" || true
cat "$out"
if ! grep -q "BOTLISH_PROBE done" "$out"; then
  # The screen shows the same lines: read them from the view hierarchy.
  adb shell uiautomator dump /sdcard/probe.xml > /dev/null 2>&1 || true
  adb shell cat /sdcard/probe.xml | tr '>' '\n' | grep -o 'text="[^"]*"' || true
  tail -40 "$out.full"
  exit 1
fi
