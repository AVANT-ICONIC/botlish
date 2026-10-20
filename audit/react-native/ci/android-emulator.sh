#!/usr/bin/env bash
# android-emulator.sh -- boots an x86_64 API 34 emulator on a GitHub Linux
# runner (KVM enabled) and waits for it. The runner's own sdkmanager may be
# older than the SDK repository's XML: install the current command-line
# tools first, then the emulator and the system image, each with retries.
set -euo pipefail
sdk=${ANDROID_HOME:?}
# The emulator's qemu links PulseAudio and X libraries the runner lacks.
sudo apt-get update -qq
sudo apt-get install -y -qq libpulse0 libgl1 libnss3 libxcomposite1 libxcursor1 libxi6 libxtst6 > /dev/null
image="system-images;android-34;google_apis;x86_64"
old=$(ls -d "$sdk"/cmdline-tools/*/bin/sdkmanager | sort -V | tail -1)
yes | "$old" --licenses > /dev/null || true
for _ in 1 2 3; do "$old" --install "cmdline-tools;latest" > /dev/null && break || sleep 10; done
sm=$(ls -d "$sdk"/cmdline-tools/*/bin/sdkmanager | sort -V | tail -1)
yes | "$sm" --licenses > /dev/null || true
for _ in 1 2 3; do "$sm" --install emulator platform-tools "$image" > /dev/null && break || sleep 15; done
"$sdk/emulator/emulator" -version | head -1
"$sdk/emulator/emulator" -accel-check || true
# A shared library the runner lacks stops qemu before adb ever sees it.
for q in "$sdk"/emulator/qemu/linux-x86_64/qemu-system-x86_64*; do
  ldd "$q" | grep "not found" && echo "($q)" || true
done
echo no | "$(dirname "$sm")/avdmanager" create avd --force -n probe -k "$image"
echo
log=${RUNNER_TEMP:-/tmp}/emulator.log
nohup "$sdk/emulator/emulator" -avd probe -no-window -gpu swiftshader_indirect -no-snapshot \
  -noaudio -no-boot-anim -accel on > "$log" 2>&1 &
emulator=$!
export PATH="$sdk/platform-tools:$PATH"
fail() {
  echo "emulator: $1"
  ps -o pid,etime,args -p "$emulator" || echo "the emulator process has exited"
  adb devices -l || true
  echo "== the emulator's log:"
  tail -80 "$log"
  exit 1
}
for _ in $(seq 1 120); do
  kill -0 "$emulator" 2> /dev/null || fail "exited before boot"
  if [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; then
    echo "emulator booted"
    adb shell settings put global window_animation_scale 0 || true
    adb shell settings put global transition_animation_scale 0 || true
    adb shell settings put global animator_duration_scale 0 || true
    exit 0
  fi
  sleep 5
done
fail "not booted after ten minutes"
