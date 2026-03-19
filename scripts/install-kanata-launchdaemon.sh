#!/bin/zsh
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo $0"
  exit 1
fi

KANATA_BIN="/opt/homebrew/bin/kanata"
KANATA_CFG="/Users/tfinklea/Library/Application Support/kanata/kanata.kbd"
PLIST_PATH="/Library/LaunchDaemons/com.taylorfinklea.kanata.plist"

if [[ ! -x "${KANATA_BIN}" ]]; then
  echo "kanata binary not found at ${KANATA_BIN}"
  exit 1
fi

if [[ ! -f "${KANATA_CFG}" ]]; then
  echo "kanata config not found at ${KANATA_CFG}"
  exit 1
fi

cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.taylorfinklea.kanata</string>
    <key>ProgramArguments</key>
    <array>
        <string>${KANATA_BIN}</string>
        <string>--cfg</string>
        <string>${KANATA_CFG}</string>
        <string>--no-wait</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/kanata.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/kanata.err.log</string>
</dict>
</plist>
EOF

chown root:wheel "${PLIST_PATH}"
chmod 644 "${PLIST_PATH}"

launchctl bootout system "${PLIST_PATH}" >/dev/null 2>&1 || true
launchctl bootstrap system "${PLIST_PATH}"
launchctl kickstart -k system/com.taylorfinklea.kanata

echo "Installed and started ${PLIST_PATH}"
