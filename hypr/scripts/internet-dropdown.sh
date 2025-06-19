#!/usr/bin/env bash
WOFI_INPUT_FILE="/tmp/latency_status_wofi.txt"

# Check if the input file exists and is not empty
if [[ ! -f "$WOFI_INPUT_FILE" ]] || [[ ! -s "$WOFI_INPUT_FILE" ]]; then
  # Display an error message in wofi if data is unavailable
  wofi --dmenu -i -p "Error:" --lines 1 <<< "Latency data unavailable or script not run yet."
  exit 1
fi

# Launch wofi with the latency data
# Adjust wofi parameters (width, lines, etc.) as needed
wofi --dmenu -i -p 'Host Latency:' < "$WOFI_INPUT_FILE"
