#!/bin/bash
# SSH tunnel setup script for clangd TCP connection
# This script runs on the local machine and establishes a persistent SSH tunnel

set -euo pipefail

# Configuration
REMOTE_HOST="${CLANGD_REMOTE_HOST:-ap-remote}"
REMOTE_PORT="${CLANGD_REMOTE_PORT:-9999}"
LOCAL_PORT="${CLANGD_LOCAL_PORT:-9999}"
WORKSPACE_DIR="/garage/workspace/ap"
LOG_DIR="${HOME}/.cache/clangd-tunnel"
LOG_FILE="${LOG_DIR}/tunnel.log"
PID_FILE="${LOG_DIR}/tunnel.pid"

# Create log directory
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

# Function to check if tunnel is running
is_tunnel_running() {
    if [[ -f "${PID_FILE}" ]]; then
        local pid=$(cat "${PID_FILE}")
        if ps -p "${pid}" > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Function to stop tunnel
stop_tunnel() {
    if [[ -f "${PID_FILE}" ]]; then
        local pid=$(cat "${PID_FILE}")
        log "Stopping SSH tunnel (PID: ${pid})"
        kill "${pid}" 2>/dev/null || true
        rm -f "${PID_FILE}"
    fi
    
    # Also kill any SSH processes forwarding our port
    pkill -f "ssh.*${LOCAL_PORT}:localhost:${REMOTE_PORT}" 2>/dev/null || true
}

# Function to start tunnel
start_tunnel() {
    log "Starting SSH tunnel: localhost:${LOCAL_PORT} -> ${REMOTE_HOST}:${REMOTE_PORT}"
    
    # Start SSH tunnel in background with auto-reconnect
    ssh -N -L "${LOCAL_PORT}:localhost:${REMOTE_PORT}" \
        -o ServerAliveInterval=60 \
        -o ServerAliveCountMax=3 \
        -o ExitOnForwardFailure=yes \
        -o TCPKeepAlive=yes \
        "${REMOTE_HOST}" >> "${LOG_FILE}" 2>&1 &
    
    local pid=$!
    echo "${pid}" > "${PID_FILE}"
    
    # Wait a moment and check if it's still running
    sleep 2
    if ps -p "${pid}" > /dev/null 2>&1; then
        log "SSH tunnel started successfully (PID: ${pid})"
        return 0
    else
        log "ERROR: SSH tunnel failed to start"
        rm -f "${PID_FILE}"
        return 1
    fi
}

# Function to ensure remote server is running
ensure_remote_server() {
    log "Checking if remote clangd server is running..."
    
    # Check if server is running on remote
    if ssh "${REMOTE_HOST}" "lsof -Pi :${REMOTE_PORT} -sTCP:LISTEN -t" >/dev/null 2>&1; then
        log "Remote clangd server is already running"
        return 0
    fi
    
    log "Starting remote clangd server..."
    
    # Copy the server script to remote
    scp -q "$(dirname "$0")/clangd-tcp-server.sh" "${REMOTE_HOST}:${WORKSPACE_DIR}/scripts/"
    
    # Start the server on remote in a screen/tmux session
    ssh "${REMOTE_HOST}" "cd ${WORKSPACE_DIR} && \
        chmod +x scripts/clangd-tcp-server.sh && \
        nohup scripts/clangd-tcp-server.sh > /dev/null 2>&1 &"
    
    # Wait for server to start
    sleep 3
    
    if ssh "${REMOTE_HOST}" "lsof -Pi :${REMOTE_PORT} -sTCP:LISTEN -t" >/dev/null 2>&1; then
        log "Remote clangd server started successfully"
        return 0
    else
        log "ERROR: Failed to start remote clangd server"
        return 1
    fi
}

# Main script
case "${1:-start}" in
    start)
        if is_tunnel_running; then
            log "SSH tunnel is already running"
            exit 0
        fi
        
        ensure_remote_server
        start_tunnel
        ;;
    
    stop)
        stop_tunnel
        log "SSH tunnel stopped"
        ;;
    
    restart)
        stop_tunnel
        sleep 1
        ensure_remote_server
        start_tunnel
        ;;
    
    status)
        if is_tunnel_running; then
            pid=$(cat "${PID_FILE}")
            log "SSH tunnel is running (PID: ${pid})"

            # Test connection
            if nc -z localhost "${LOCAL_PORT}" 2>/dev/null; then
                log "Local port ${LOCAL_PORT} is accessible"
            else
                log "WARNING: Local port ${LOCAL_PORT} is not accessible"
            fi
        else
            log "SSH tunnel is not running"
            exit 1
        fi
        ;;
    
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

