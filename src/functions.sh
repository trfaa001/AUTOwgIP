log() {
    # Simple function for logging, example: log "function_name failed"

    if [ "$LOGGING" = "off" ]; then
        return
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$0] $*" >>"$LOG_FILE" 2>/dev/null || true
}

validate_port() {
    # Simple function if a port is the valid range, example: validate_port "123" returns True

    local PORT="$1"
    #Check if the port is in the range 1-65535
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        log "Error: PORT ($PORT) is not valid. Must be between 1 and 65535."
        exit 1
    fi
}


validate_ip() {
    # Check if the ip given is a valid public ip before changing files, stops the entire script if it isn't

    local IP="$1"

    if [[ -z "$IP" ]]; then
        log "Could not fetch current local IP!"
        exit 3
    fi

    # Try IPv4 with ipcalc
    if ipcalc -c "$IP" >/dev/null 2>&1; then
        log "Valid ipcalc"
        return 0
    fi

    # Try IPv6 with sipcalc or getent
    if command -v sipcalc >/dev/null; then
        if sipcalc "$IP" >/dev/null 2>&1; then
            log "Valid sipcalc"
            return 0
        fi
    else
        if getent hosts "$IP" >/dev/null 2>&1; then
            log "Valid getent"
            return 0
        fi
    fi

    log "Invalid IP"
    exit 2
}

soft_validate_ip() {
    # Check if the ip given is a valid public ip we can use in the script, returns true or false

    local IP="$1"

    if [[ -z "$IP" ]]; then
        log "Could not fetch current local IP!"
        return 1
    fi

    # Try IPv4 with ipcalc
    if ipcalc -c "$IP" >/dev/null 2>&1; then
        log "Valid ipcalc"
        return 0
    fi

    # Try IPv6 with sipcalc or getent
    if command -v sipcalc >/dev/null; then # Check if sipcalc is installed
        if sipcalc "$IP" >/dev/null 2>&1; then
            log "Valid sipcalc"
            return 0
        fi
    else
        if getent hosts "$IP" >/dev/null 2>&1; then
            log "Valid getent"
            return 0
        fi
    fi

    return 1
}

run_in_ct() {
    # Runs a command in Proxmox ct, example run_in_ct "echo Hello World! >> test.txt"

    local CTID="$1"; shift
    
    if ! pct exec "$CTID" -- "$@"; then
        log "Error: command '$*' failed in container $CTID"
        exit 4
    fi
}

check_file_existence() {
    # Check if a file exists, example: check_file_existance "test.txt"

    local File="$1"

    if [ -f "$File" ]; then
        return 0
    else
        return 1
    fi
}

get_current_ip() {
    # Checks for a valid public ip adress from multiple sources defined in the config, returns a ip or 0

    for SOURCE in "${IP_SOURCES[@]}"; do
        READ_IP="$(curl -s --max-time 3 "$SOURCE")"

        log "Read $READ_IP from $SOURCE"

        if soft_validate_ip "$READ_IP"; then
            log "$READ_IP valid from $SOURCE"
            
            echo "$READ_IP"
            return 0
        else
            log "$READ_IP invalid from $SOURCE"
        fi
    done

    log "No valid IP found from any source"
    echo "999.999.999.999"
    return 1
}           