#!/usr/bin/env bash

LAST_EXIT_FILE="$HOME/.config/waybar/.last-tailscale-exit"

# Check if tailscale daemon is running
if ! systemctl is-active --quiet tailscaled; then
  echo '{"text": "🔒 Tailscale Off", "tooltip": "Tailscale daemon is not running", "class": "disconnected"}'
  exit 0
fi

# Get tailscale status
STATUS=$(tailscale status --json 2>/dev/null)

if [[ $? -ne 0 ]] || [[ -z "$STATUS" ]]; then
  echo '{"text": "🔒 Tailscale Err", "tooltip": "Error getting Tailscale status", "class": "disconnected"}'
  exit 0
fi

# Check if we're using an active exit node
EXIT_NODE_PEER_INFO=$(echo "$STATUS" | jq -r '([.Peer[] | select(.ExitNode == true and .Online == true)] | .[0])')

if [ -n "$EXIT_NODE_PEER_INFO" ] && [ "$EXIT_NODE_PEER_INFO" != "null" ]; then
  EXIT_NODE_DNSNAME_FULL=$(echo "$EXIT_NODE_PEER_INFO" | jq -r '.DNSName')
  EXIT_NODE_HOSTNAME=$(echo "$EXIT_NODE_PEER_INFO" | jq -r '.HostName')

  DISPLAY_NAME=""
  SAVE_NAME="" # This will be stored in LAST_EXIT_FILE and used for tooltip

  CANDIDATE_DNS_SHORT=""
  if [ "$EXIT_NODE_DNSNAME_FULL" != "null" ] && [ -n "$EXIT_NODE_DNSNAME_FULL" ]; then
    CANDIDATE_DNS_SHORT=$(echo "$EXIT_NODE_DNSNAME_FULL" | cut -d'.' -f1)
  fi

  CANDIDATE_HOSTNAME=""
  if [ "$EXIT_NODE_HOSTNAME" != "null" ] && [ -n "$EXIT_NODE_HOSTNAME" ]; then
    CANDIDATE_HOSTNAME="$EXIT_NODE_HOSTNAME"
  fi

  # Determine DISPLAY_NAME:
  # 1. Prefer short DNS name if it's not generic-looking (e.g., not "ip-xxx")
  if [ -n "$CANDIDATE_DNS_SHORT" ] && ! [[ "$CANDIDATE_DNS_SHORT" == "ip-"* ]] && ! [[ "$CANDIDATE_DNS_SHORT" == "ec2-"* ]]; then
    DISPLAY_NAME="$CANDIDATE_DNS_SHORT"
  # 2. Else, prefer HostName if it's not generic-looking
  elif [ -n "$CANDIDATE_HOSTNAME" ] && ! [[ "$CANDIDATE_HOSTNAME" == "ip-"* ]] && ! [[ "$CANDIDATE_HOSTNAME" == "ec2-"* ]]; then
    DISPLAY_NAME="$CANDIDATE_HOSTNAME"
  # 3. Else, use the short DNS name even if it is generic (it's often the most specific part)
  elif [ -n "$CANDIDATE_DNS_SHORT" ]; then
    DISPLAY_NAME="$CANDIDATE_DNS_SHORT"
  # 4. Else, use the HostName even if it is generic
  elif [ -n "$CANDIDATE_HOSTNAME" ]; then
    DISPLAY_NAME="$CANDIDATE_HOSTNAME"
  else
    DISPLAY_NAME="ExitNode" # Ultimate fallback
  fi

  # Determine SAVE_NAME (full identifier for 'tailscale set --exit-node=SAVE_NAME')
  # Prefer full DNSName as it's often more stable/canonical for 'tailscale set'
  if [ "$EXIT_NODE_DNSNAME_FULL" != "null" ] && [ -n "$EXIT_NODE_DNSNAME_FULL" ]; then
    SAVE_NAME="$EXIT_NODE_DNSNAME_FULL"
  elif [ "$EXIT_NODE_HOSTNAME" != "null" ] && [ -n "$EXIT_NODE_HOSTNAME" ]; then
    SAVE_NAME="$EXIT_NODE_HOSTNAME"
  else
    SAVE_NAME="" # Should not happen if EXIT_NODE_PEER_INFO is valid
  fi

  if [ -n "$SAVE_NAME" ]; then
    echo "$SAVE_NAME" > "$LAST_EXIT_FILE"
  fi

  # Truncate DISPLAY_NAME for display if too long
  if [ ${#DISPLAY_NAME} -gt 15 ]; then # Max length for display
    DISPLAY_NAME="${DISPLAY_NAME:0:13}.."
  fi
  # This echo statement uses double quotes correctly, so it's fine.
  echo "{\"text\": \"🛡️ $DISPLAY_NAME\", \"tooltip\": \"Exit Node: $SAVE_NAME\", \"class\": \"exit-node\"}"
else
  # Check if Tailscale self is online (connected to Tailnet)
  SELF_ONLINE=$(echo "$STATUS" | jq -r '.Self.Online')
  if [ "$SELF_ONLINE" = "true" ]; then
    # CORRECTED: Removed unnecessary backslashes
    echo '{"text": "🔗 Tailscale", "tooltip": "Connected to Tailscale network", "class": "connected"}'
  else
    # CORRECTED: Removed unnecessary backslashes
    echo '{"text": "🔒 Tailscale Off", "tooltip": "Not connected to Tailscale network", "class": "disconnected"}'
  fi
fi

