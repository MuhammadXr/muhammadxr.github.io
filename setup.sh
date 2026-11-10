#!/data/data/com.termux/files/usr/bin/bash

# 1. Fix Termux repository mirror automatically
echo "[*] Fixing Termux repositories..."
sed -i 's|https://.*termux-main|https://packages.termux.dev/apt/termux-main|g' $PREFIX/etc/apt/sources.list

# 2. Update packages and install OpenSSH & Dropbear client
echo "[*] Installing OpenSSH..."
pkg update -y && pkg install -y openssh

# 3. Create persistent root autostart entry for Pinggy reverse tunnel
echo "[*] Setting up persistent reverse tunnel log..."
mkdir -p /sdcard/remote_log

# 4. Kill any previous tunnel and start background connection
pkill -f pinggy.io 2>/dev/null
nohup ssh -p 443 -o StrictHostKeyChecking=no -R 0:localhost:2222 qr@a.pinggy.io > /sdcard/remote_log/pinggy.log 2>&1 &

sleep 5

# 5. Display the generated connection command on screen
echo "=================================================="
echo "SUCCESS! Share the command below with your brother:"
echo "=================================================="
cat /sdcard/remote_log/pinggy.log | grep -E "ssh -p [0-9]+"
