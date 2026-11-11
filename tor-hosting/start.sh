#!/usr/bin/env bash
set -Eeuo pipefail

HOME_DIR="/home/container"
WEB_ROOT="${WEB_ROOT:-public_html}"
TOR_ENABLED="${TOR_ENABLED:-1}"
ONION_PORT="${ONION_PORT:-80}"

WEB_DIR="$HOME_DIR/$WEB_ROOT"
TOR_DIR="$HOME_DIR/.tor"
HS_DIR="$TOR_DIR/hidden_service"
DATA_DIR="$TOR_DIR/data"

mkdir -p "$WEB_DIR" "$HS_DIR" "$DATA_DIR" "$HOME_DIR/logs"
chmod 700 "$TOR_DIR" "$HS_DIR" "$DATA_DIR"

if [ ! -f "$WEB_DIR/index.php" ] && [ ! -f "$WEB_DIR/index.html" ]; then
  cat > "$WEB_DIR/index.php" <<'PHP'
<?php
echo "<h1>Tor Web Hosting</h1><p>Your onion website is online.</p>";
PHP
fi

# Keep Nginx/PHP config fixed to the standard document root for predictable isolation.
if [ "$WEB_ROOT" != "public_html" ]; then
  echo "WEB_ROOT must be public_html with this image." >&2
  exit 1
fi

php-fpm8.2 -F -y /opt/tor-hosting/php-fpm.conf &
PHP_PID=$!

nginx -c /opt/tor-hosting/nginx.conf -g 'daemon off;' &
NGINX_PID=$!

TOR_PID=""
if [ "$TOR_ENABLED" = "1" ]; then
  cat > "$TOR_DIR/torrc" <<EOF
DataDirectory $DATA_DIR
HiddenServiceDir $HS_DIR
HiddenServiceVersion 3
HiddenServicePort $ONION_PORT 127.0.0.1:8080
SocksPort 0
Log notice stdout
RunAsDaemon 0
EOF
  tor -f "$TOR_DIR/torrc" &
  TOR_PID=$!
fi

cleanup() {
  kill "$PHP_PID" "$NGINX_PID" ${TOR_PID:-} 2>/dev/null || true
}
trap cleanup EXIT TERM INT

for i in $(seq 1 60); do
  if [ "$TOR_ENABLED" != "1" ] || [ -s "$HS_DIR/hostname" ]; then
    break
  fi
  sleep 1
done

if [ "$TOR_ENABLED" = "1" ] && [ -s "$HS_DIR/hostname" ]; then
  printf 'ONION_ADDRESS=%s\n' "$(cat "$HS_DIR/hostname")"
elif [ "$TOR_ENABLED" = "1" ]; then
  echo "Tor did not create an onion hostname within 60 seconds." >&2
fi

wait "$NGINX_PID"
