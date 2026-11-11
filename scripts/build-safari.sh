#!/usr/bin/env bash
# Generates an Xcode project that wraps this extension as a Safari Web Extension.
# Requires macOS with Xcode installed. Extra arguments are passed to the converter,
# e.g.  npm run build:safari -- --macos-only
#
# Set BUNDLE_ID to your own reverse-DNS identifier before distributing.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! xcrun --find safari-web-extension-converter >/dev/null 2>&1; then
  echo "error: safari-web-extension-converter not found. Install Xcode (macOS only)." >&2
  exit 1
fi

BUNDLE_ID="${BUNDLE_ID:-com.example.crunchyroll-auto-skipper}"
STAGE="dist/safari-extension"

# Stage only the files the extension ships, so the Xcode project doesn't pick up
# the repository's tooling files.
rm -rf "$STAGE" safari
mkdir -p "$STAGE/icons"
cp manifest.json "$STAGE/"
cp -R content popup "$STAGE/"
cp icons/*.png icons/icon.svg "$STAGE/icons/"

xcrun safari-web-extension-converter "$STAGE" \
  --project-location safari \
  --app-name "Crunchyroll Auto Skipper" \
  --bundle-identifier "$BUNDLE_ID" \
  --swift \
  --copy-resources \
  --no-open \
  --no-prompt \
  --force \
  "$@"

# Xcode refuses to build unless every extension's bundle identifier is prefixed with
# the app's, so normalise them: apps get BUNDLE_ID, extensions get BUNDLE_ID.Extension.
export BUNDLE_ID
find safari -name project.pbxproj -exec perl -pi -e \
  's/(PRODUCT_BUNDLE_IDENTIFIER = )"?[^";]*?(\.Extension)?"?;/$1 . "\"$ENV{BUNDLE_ID}" . ($2 ? ".Extension" : "") . "\";"/ie' {} +

echo
echo "Bundle identifiers: $BUNDLE_ID (app), $BUNDLE_ID.Extension (extension)"
echo "Xcode project created in ./safari"
echo "Open it with: open \"safari/Crunchyroll Auto Skipper/Crunchyroll Auto Skipper.xcodeproj\""
