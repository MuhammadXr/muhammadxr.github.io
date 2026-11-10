#!/data/data/com.termux/files/usr/bin/bash

LOG_FILE="/sdcard/pinggy_info.txt"
RAW_LOG="/sdcard/pinggy_raw.log"

echo "=========================================="
echo " Starting Automatic SSH & Mirror Setup"
echo "=========================================="

# 1. Non-interactively replace broken Termux main mirrors
echo "[1/4] Repairing Termux package mirrors..."
mkdir -p $PREFIX/etc/apt/sources.list.d
echo "deb https://packages.termux.dev/apt/termux-main main" > $PREFIX/etc/apt/sources.list

# 2. Update package list and install OpenSSH
echo "[2/4] Updating package index & installing OpenSSH..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -o Acquire::ForceIPv4=true
apt-get install -y openssh -o Acquire::ForceIPv4=true

# 3. Clean up any existing tunnels
echo "[3/4] Resetting background tunnel processes..."
pkill -f pinggy.io > /dev/null 2>&1
rm -f "$LOG_FILE" "$RAW_LOG"

# 4. Launch persistent auto-reconnecting Pinggy tunnel
echo "[4/4] Starting background Pinggy tunnel..."
nohup bash -c "
while true; do
    ssh -p 443 -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -R 0:localhost:2222 qr@a.pinggy.io > $RAW_LOG 2>&1
    sleep 5
done
" > /dev/null 2>&1 &

# 5. Wait up to 15 seconds to capture the active SSH connection string
echo "[*] Waiting for Pinggy to assign public URL..."
COUNT=0
while [ $COUNT -lt 15 ]; do
    if grep -q "ssh -p" "$RAW_LOG" 2>/dev/null; then
        grep -E "ssh -p [0-9]+" "$RAW_LOG" | head -n 1 > "$LOG_FILE"
        break
    fi
    sleep 1
    COUNT=$((COUNT + 1))
done

echo ""
echo "=========================================="
if [ -s "$LOG_FILE" ]; then
    echo " SUCCESS! CONNECT USING THIS COMMAND:"
    echo "------------------------------------------"
    cat "$LOG_FILE"
    echo "------------------------------------------"
    echo "Saved to: $LOG_FILE"
else
    echo " Tunnel running in background."
    echo " Check output manually: cat /sdcard/pinggy_raw.log"
fi
echo "=========================================="
