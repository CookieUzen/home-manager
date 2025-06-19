#!/usr/bin/env bash

set -u
LAST_EXIT_FILE="$HOME/.config/waybar/.last-tailscale-exit"
WOFI_PROMPT="Tailscale Exit Node"

notify_send() {
  # Non-blocking notification to prevent hangs
  if command -v notify-send &>/dev/null; then
    timeout 0.5s notify-send -a "Tailscale Control" "$@" &> /dev/null &
    disown
  fi
}

# Get current exit node (DNSName if available)
CURRENT_EXIT=$(tailscale status --json 2>/dev/null | jq -r '.Self.ExitNodeName // empty')

# Get exit nodes prioritizing DNSName
exit_nodes=$(tailscale status --json 2>/dev/null | jq -r '
  .Peer[] 
  | select(.ExitNodeOption == true and .Online == true) 
  | .DNSName // .HostName // empty' | sort -u)

# Fallback to HostName if no DNSName found
if [ -z "$exit_nodes" ]; then
  exit_nodes=$(tailscale status --json 2>/dev/null | jq -r '
    .Peer[] 
    | select(.ExitNodeOption == true and .Online == true) 
    | .HostName // empty' | sort -u)
fi

# Exit if no exit nodes found
if [ -z "$exit_nodes" ]; then
  notify_send "Tailscale" "No exit nodes available"
  exit 1
fi

# Prepare options for Wofi
mapfile -t exit_nodes_list <<< "$exit_nodes"
wofi_options=("[Disconnect]" "[Reconnect Last]")
wofi_options+=("${exit_nodes_list[@]}")

# Run Wofi with proper input handling
wofi_input=$(printf "%s\n" "${wofi_options[@]}")
wofi_selection=$(echo "$wofi_input" | wofi --dmenu -i -p "$WOFI_PROMPT")

# Handle user cancellation (Escape key)
if [ $? -ne 0 ] || [ -z "${wofi_selection:-}" ]; then
  exit 0
fi

# Process selection
case "$wofi_selection" in
  "[Disconnect]")
    if [ -n "$CURRENT_EXIT" ]; then
      tailscale set --exit-node=""
      notify_send "Tailscale" "Disconnected from exit node"
    else
      notify_send "Tailscale" "Not currently using an exit node"
    fi
    ;;
  "[Reconnect Last]")
    if [ -f "$LAST_EXIT_FILE" ]; then
      last_exit=$(cat "$LAST_EXIT_FILE")
      if [ -n "$last_exit" ] && [ "$last_exit" != "$CURRENT_EXIT" ]; then
        tailscale set --exit-node="$last_exit"
        notify_send "Tailscale" "Connecting to last exit node: $last_exit"
      elif [ -n "$last_exit" ]; then
        notify_send "Tailscale" "Already using last exit node: $last_exit"
      fi
    else
      notify_send "Tailscale" "No previous exit node record found"
    fi
    ;;
  *)
    # Regular exit node selection
    if [ "$wofi_selection" != "$CURRENT_EXIT" ]; then
      tailscale set --exit-node="$wofi_selection"
      echo "$wofi_selection" > "$LAST_EXIT_FILE"
      notify_send "Tailscale" "Connecting to exit node: $wofi_selection"
    else
      notify_send "Tailscale" "Already using exit node: $wofi_selection"
    fi
    ;;
esac

exit 0

