#!/usr/bin/env bash
# ==============================================================================
# scripts/vps-agent.sh — Lightweight Real-Time Telemetry Agent for Ubuntu VPS
# Writes live CPU, RAM (MemTotal - MemAvailable), Swap, NVMe Disk, and Load Avg
# to /var/www/rudra/vps-status.json every 2 seconds using atomic file replacement.
# ==============================================================================

set -u

WEB_DIR="${1:-/var/www/rudra}"
if [ ! -d "$WEB_DIR" ]; then
  DETECTED=$(dirname "$(find /var/www /home /usr/share/nginx -name "index.html" 2>/dev/null | head -n 1)" 2>/dev/null || true)
  WEB_DIR="${DETECTED:-/var/www/html}"
fi

while true; do
  CORES=$(nproc 2>/dev/null || echo 4)
  MODEL=$(awk -F: '/model name/{gsub(/^[ \t]+/,"",$2); print $2; exit}' /proc/cpuinfo 2>/dev/null || echo "AMD Ryzen 9")
  GHZ=$(awk -F: '/cpu MHz/{printf "%.1f GHz", $2/1000; exit}' /proc/cpuinfo 2>/dev/null || echo "3.3 GHz")
  [ -z "$GHZ" ] && GHZ="3.3 GHz"

  read -r L1 L5 L15 _ < /proc/loadavg
  read -r _ U1 N1 S1 I1 _ < /proc/stat
  sleep 1
  read -r _ U2 N2 S2 I2 _ < /proc/stat

  DT=$(( (U2 + N2 + S2 + I2) - (U1 + N1 + S1 + I1) ))
  DI=$(( I2 - I1 ))
  CPU=$(( DT > 0 ? (100 * (DT - DI) / DT) : 1 ))

  MEM=$(awk '/MemTotal:/{t=$2}/MemAvailable:/{a=$2}END{u=(t-a)/1048576; tt=t/1048576; printf "%.2f %.1f", u, tt}' /proc/meminfo)
  SWP=$(awk '/SwapTotal:/{t=$2}/SwapFree:/{f=$2}END{printf "%.2f %.1f", (t-f)/1048576, t/1048576}' /proc/meminfo)
  DSK=$(df -BG / | awk 'NR==2{gsub("G",""); printf "%s %s", $3, $2}')
  UP=$(awk '{print int($1)}' /proc/uptime)
  OS="$(uname -s) $(uname -r)"
  H=$(hostname)

  if [ -w "$WEB_DIR" ]; then
    printf '{"name":"%s","region":"Live Ubuntu VPS","cores":%s,"cpuGhz":"%s","cpuModel":"%s","cpu":%s,"load1":%s,"load5":%s,"load15":%s,"ramUsed":%s,"ramTotal":%s,"swapUsed":%s,"swapTotal":%s,"diskUsed":%s,"diskTotal":%s,"uptimeSec":%s,"os":"%s"}\n' \
      "$H" "$CORES" "$GHZ" "$MODEL" "$CPU" "$L1" "$L5" "$L15" $MEM $SWP $DSK "$UP" "$OS" \
      > "$WEB_DIR/vps-status.json.tmp" && \
    chmod 644 "$WEB_DIR/vps-status.json.tmp" && \
    mv -f "$WEB_DIR/vps-status.json.tmp" "$WEB_DIR/vps-status.json"
  fi
  sleep 1
done
