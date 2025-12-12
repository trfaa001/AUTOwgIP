#!/bin/bash
set -euo pipefail

LOGFILE="/var/log/wgAUTO.log"
CONFIG_DIR="/etc/wgAUTO"
DATA_FILE="$CONFIG_DIR/data.conf"
CRON_JOB="*/20 * * * * /usr/local/bin/autoWG >> /var/log/wgAUTO.log 2>&1"

echo "Starting installation..."

echo "Installing dependencies..."
apt update
apt install -y ipcalc sipcalc curl

echo "Creating config directory at $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

if [ ! -f "$DATA_FILE" ]; then
    echo "Initializing data.conf..."
    touch "$DATA_FILE"
    chmod 600 "$DATA_FILE"
fi

echo "Creating log file at $LOGFILE..."
touch "$LOGFILE"
chmod 640 "$LOGFILE"

# Deploy main script
if [ -f "src/main.sh" ]; then
    cp src/main.sh /usr/local/bin/autoWG
    chmod +x /usr/local/bin/autoWG
fi

# Add cron job
if ! crontab -l 2>/dev/null | grep -q "/usr/local/bin/autoWG"; then
    echo "Adding cron job..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
else
    echo "Cron job already exists."
fi

echo "Installation complete!"