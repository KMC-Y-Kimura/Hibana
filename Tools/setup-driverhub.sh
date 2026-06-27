#!/bin/sh

set -eu

PORT="${ADB_PORT:-5555}"

info() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf '\nエラー: %s\n' "$1" >&2
  exit 1
}

if ! command -v adb >/dev/null 2>&1; then
  fail "adb が見つかりません。
Homebrewを利用している場合は、次を実行してください:
  brew install android-platform-tools"
fi

info "ADBサーバーを起動しています"
adb start-server >/dev/null

USB_DEVICES=$(
  adb devices |
    awk '
      NR > 1 && $2 == "device" && $1 !~ /:/ {
        print $1
      }
    '
)

if [ -z "$USB_DEVICES" ]; then
  adb devices -l
  fail "認証済みのUSB接続端末が見つかりません。
Driver HubをUSB接続し、USBデバッグを有効にして、
Driver Hub側の許可画面を確認してください。"
fi

DEVICE_COUNT=$(printf '%s\n' "$USB_DEVICES" | grep -c . || true)

if [ "$DEVICE_COUNT" -gt 1 ]; then
  printf '\n複数のUSB端末が見つかりました:\n%s\n' "$USB_DEVICES" >&2
  fail "Driver Hub以外のAndroid端末を外してから再実行してください。"
fi

USB_SERIAL=$(printf '%s\n' "$USB_DEVICES" | head -n 1)

info "USB接続端末を検出しました: $USB_SERIAL"
info "Driver HubのWi-Fi IPアドレスを取得しています"

IP=$(
  adb -s "$USB_SERIAL" shell ip -4 addr show wlan0 2>/dev/null |
    tr -d '\r' |
    awk '
      /inet / {
        split($2, address, "/")
        print address[1]
        exit
      }
    '
)

if [ -z "$IP" ]; then
  fail "wlan0のIPアドレスを取得できませんでした。
Driver HubがWi-Fiに接続されていることを確認してください。"
fi

info "Driver Hub IP: $IP"
info "無線ADBをポート $PORT で有効化しています"

adb -s "$USB_SERIAL" tcpip "$PORT"

sleep 2

info "無線ADBへ接続しています"
adb connect "$IP:$PORT"

sleep 1

if adb devices |
  awk -v target="$IP:$PORT" '
    $1 == target && $2 == "device" {
      found = 1
    }
    END {
      exit !found
    }
  '
then
  printf '\nセットアップが完了しました。\n'
  printf '接続先: %s:%s\n' "$IP" "$PORT"
  printf 'USBケーブルを抜いた後、次で確認できます:\n'
  printf '  adb devices\n'
else
  adb devices -l
  fail "無線ADB接続を確認できませんでした。
MacとDriver Hubが同じWi-Fiネットワークに接続されているか確認してください。"
fi
