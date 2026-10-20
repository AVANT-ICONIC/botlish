#!/usr/bin/env bash
# android-emulator.sh -- boots an x86_64 API 34 emulator on a GitHub Linux
# runner (KVM enabled) and waits for it. The runner's own sdkmanager may be
# older than the SDK repository's XML: install the current command-line
# tools first, then the emulator and the system image, each with retries.
set -euo pipefail
sdk=${ANDROID_HOME:?}
image="system-images;android-34;google_apis;x86_64"
old=$(ls -d "$sdk"/cmdline-tools/*/bin/sdkmanager | sort -V | tail -1)
yes | "$old" --licenses > /dev/null || true
for _ in 1 2 3; do "$old" --install "cmdline-tools;latest" > /dev/null && break || sleep 10; done
sm="$sdk/cmdline-tools/latest/bin/sdkmanager"
yes | "$sm" --licenses > /dev/null || true
for _ in 1 2 3; do "$sm" --install emulator platform-tools "$image" > /dev/null && break || sleep 15; done
"$sdk/emulator/emulator" -version | head -1
echo no | "$sdk/cmdline-tools/latest/bin/avdmanager" create avd --force -n probe -k "$image"
nohup "$sdk/emulator/emulator" -avd probe -no-window -gpu swiftshader_indirect -no-snapshot \
  -noaudio -no-boot-anim -accel on > "${RUNNER_TEMP:-/tmp}/emulator.log" 2>&1 &
export PATH="$sdk/platform-tools:$PATH"
timeout 600 adb wait-for-device
for _ in $(seq 1 120); do
  if [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; then
    echo "emulator booted"
    adb shell settings put global window_animation_scale 0 || true
    adb shell settings put global transition_animation_scale 0 || true
    adb shell settings put global animator_duration_scale 0 || true
    exit 0
  fi
  sleep 5
done
tail -50 "${RUNNER_TEMP:-/tmp}/emulator.log"
exit 1
