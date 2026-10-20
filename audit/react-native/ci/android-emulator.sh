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
# The current avdmanager and the emulator do not agree on a default AVD
# directory (run 5: "Unknown AVD name [probe]"): name it for both.
export ANDROID_AVD_HOME=$HOME/.android/avd
mkdir -p "$ANDROID_AVD_HOME"
echo no | "$(dirname "$sm")/avdmanager" create avd --force -n probe -k "$image"
echo
if ! "$sdk/emulator/emulator" -list-avds | grep -qx probe; then
  echo "the emulator does not see the AVD; avdmanager wrote:"
  find "$HOME" /usr/local/lib/android -name 'probe.ini' -o -name 'probe.avd' 2> /dev/null || true
  exit 1
fi
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
