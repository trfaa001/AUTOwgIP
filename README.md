Project deprecated after switching over to a router-provided VPN and DDNS solution.

# ~~AUTOwgIP~~
~~A bash script that automatically updates Wireguard client endpoint IP for every container in proxmox. Useful for servers with dynamic public ip.~~

# ~~Install:~~

# Uninstall:
<pre>
chmod +x uninstall.sh && ./uninstall.sh # While in the repository folder
</pre>

# Config:
location: /etc/wgAUTO/AUTOwgIP.conf
#### Example:
<pre>
# Network settings
PORT=8473

# WireGuard configuration
WG_INTERFACE_NAME="wg0"

# Logging settings
LOG_FILE="/var/log/wgAUTO.log"
LOGGING="on"

# Verification settings
IP_VERIFICATION="on"

# Execution modes
DRY_RUN="off" # Doesnt change any files
FORCE_MODE="off" # Disables all checks

# List of sources for the public ipv4
# The source should return the public ipv4 in clear text by running curl -s $SOURCE if you want to change the list
IP_SOURCES=("https://ifconfig.me" "https://api.ipify.org" "https://icanhazip.com")

</pre>

# Function and limitations

Script function:
1. Check if the IP has changed
2. Go into every container and change the config file
3. Sync the Wireguard config
