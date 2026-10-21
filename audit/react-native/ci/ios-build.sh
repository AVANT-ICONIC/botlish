#!/usr/bin/env bash
# ios-build.sh WORK VARIANT -- the probe app's release build for the iOS
# simulator (arm64), as `WORK/probe app` holds it after app.sh and pod
# install. On success it records the app bundle's path in WORK/app-bundle
# and VARIANT in WORK/variant; on failure it prints the linker's and the
# compiler's diagnostics.
set -euo pipefail
work=$1
variant=$2
app="$work/probe app"
log="$work/xcodebuild-$variant.log"
set +e
xcodebuild -workspace "$app/ios/BotlishProbeApp.xcworkspace" -scheme BotlishProbeApp \
  -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$work/derived" ARCHS=arm64 ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO \
  build > "$log" 2>&1
status=$?
set -e
grep -E "error:|warning: .*(built for|platform)|ld: |Undefined symbols|BUILD (SUCCEEDED|FAILED)|\*\* BUILD" "$log" | sort | uniq -c | head -60 || true
if [ $status -ne 0 ]; then
  grep -B2 -A12 "Undefined symbols\|ld: \|clang: error" "$log" | head -80 || true
  exit $status
fi
echo "$work/derived/Build/Products/Release-iphonesimulator/BotlishProbeApp.app" > "$work/app-bundle"
echo "$variant" > "$work/variant"
