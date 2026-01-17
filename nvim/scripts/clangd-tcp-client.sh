#!/bin/bash
# Local clangd TCP client wrapper
# This script connects to the remote clangd server via the SSH tunnel
# Use this as your clangd command in your editor configuration

set -euo pipefail

# Configuration
LOCAL_PORT="${CLANGD_LOCAL_PORT:-9999}"
TUNNEL_SCRIPT="$(dirname "$0")/clangd-tunnel-setup.sh"
LOG_DIR="${HOME}/.cache/clangd-client"
LOG_FILE="${LOG_DIR}/client.log"

# Create log directory
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${LOG_FILE}"
}

# Function to ensure tunnel is running
ensure_tunnel() {
    if ! "${TUNNEL_SCRIPT}" status >/dev/null 2>&1; then
        log "Tunnel not running, starting it..."
        "${TUNNEL_SCRIPT}" start
        sleep 2
    fi
}

# Main execution
log "Clangd TCP client starting..."
log "Connecting to localhost:${LOCAL_PORT}"

# Ensure tunnel is running
ensure_tunnel

# Check if port is accessible
if ! nc -z localhost "${LOCAL_PORT}" 2>/dev/null; then
    log "ERROR: Cannot connect to localhost:${LOCAL_PORT}"
    log "Attempting to restart tunnel..."
    "${TUNNEL_SCRIPT}" restart
    sleep 2
    
    if ! nc -z localhost "${LOCAL_PORT}" 2>/dev/null; then
        log "ERROR: Still cannot connect after restart"
        exit 1
    fi
fi

log "Connected successfully, starting socat relay..."

# Use socat to relay stdin/stdout to the TCP connection
exec socat - TCP:localhost:${LOCAL_PORT}

