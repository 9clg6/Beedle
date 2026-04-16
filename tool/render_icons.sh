#!/usr/bin/env bash
# tool/render_icons.sh — Rasterize the Beedle app icon SVG masters into
# 1024×1024 PNGs, then let flutter_launcher_icons derive every store size.
#
# We use rsvg-convert (librsvg) rather than a Flutter widget render because:
#   - google_fonts fetches over network inside `testWidgets`, which blocks
#     indefinitely in our dev environment (we saw 10-min timeouts).
#   - rsvg-convert is deterministic, fast (~100ms), and respects the exact
#     SVG source in assets/branding/ without relying on Flutter state.
#
# Prerequisites (one-time):
#   brew install librsvg
#   # Install Hanken Grotesk TTF so rsvg-convert matches the font used in-app
#   mkdir -p ~/Library/Fonts
#   curl -sSL -o ~/Library/Fonts/HankenGrotesk-Bold.ttf \
#     "https://github.com/google/fonts/raw/main/ofl/hankengrotesk/HankenGrotesk%5Bwght%5D.ttf"
#   curl -sSL -o ~/Library/Fonts/HankenGrotesk-BoldItalic.ttf \
#     "https://github.com/google/fonts/raw/main/ofl/hankengrotesk/HankenGrotesk-Italic%5Bwght%5D.ttf"
#   fc-cache -f
#
# Usage (from repo root):
#   tool/render_icons.sh

set -euo pipefail

# --- Preflight ----------------------------------------------------------------

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "✗ rsvg-convert not found. Install with: brew install librsvg" >&2
  exit 1
fi

if ! fc-list 2>/dev/null | grep -q -i "hanken grotesk"; then
  echo "⚠ Hanken Grotesk not installed system-wide — rsvg-convert will" >&2
  echo "  fall back to a generic sans-serif, which will NOT match the" >&2
  echo "  in-app rendering. See the header of this script for install steps." >&2
  echo "" >&2
  # Don't exit hard — let user decide whether to proceed.
fi

cd "$(dirname "$0")/.."

SVG_DIR="assets/branding"

# --- Render the four 1024×1024 PNG masters ------------------------------------

render() {
  local src="$1"
  local dst="$2"
  echo "• $src  →  $dst"
  rsvg-convert -w 1024 -h 1024 "$SVG_DIR/$src" -o "$SVG_DIR/$dst"
}

render "icon-dot-b.svg"                  "icon-source-1024.png"
render "icon-dot-b-dark.svg"             "icon-dot-b-dark-1024.png"
render "icon-adaptive-foreground.svg"    "icon-adaptive-foreground-1024.png"
render "icon-notification-monochrome.svg" "icon-notification-monochrome-1024.png"

echo ""
echo "✓ Rendered 4 master PNGs at 1024×1024 in $SVG_DIR/"
echo ""

# --- Derive every store size via flutter_launcher_icons ----------------------

echo "• Running flutter_launcher_icons…"
dart run flutter_launcher_icons

echo ""
echo "✓ All done. iOS, Android (classic + adaptive + monochrome) and web"
echo "  icons updated. On iOS, force-quit + reinstall the app to refresh"
echo "  the cached icon on the home screen:"
echo ""
echo "    flutter clean && (cd ios && pod install) && flutter run"
