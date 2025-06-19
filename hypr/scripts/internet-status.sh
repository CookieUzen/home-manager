#!/usr/bin/env bash

# --- Configuration ---
CRITICAL_URLS=("youtube.com" "1.1.1.1" "kagi.com" "music.apple.com" )
ALL_URLS_TO_MONITOR=("youtube.com" "cloudflare.com" "reddit.com" "github.com" "bing.com" "weixin.qq.com" "bing.com" "wechat.com" "douyin.com" "xiaohongshu.com" "weibo.com" "jd.com" "taobao.com" "zhihu.com" "baidu.com" "google.com" "facebook.com" "instagram.com" "wikipedia.org" "tiktok.com")
LATENCY_WOFI_OUTPUT_FILE="/tmp/latency_status_wofi.txt"
HTTPING_REQUEST_TIMEOUT="8s"
COMMAND_OVERALL_TIMEOUT="10s"
MAX_PARALLEL=${MAX_PARALLEL:-20}  # Maximum number of parallel processes
# --- End Configuration ---

# Create temporary directory for parallel results
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

all_critical_ok=true
failed_critical_details_array=()

# Check if httping is available
if ! command -v httping &> /dev/null; then
    json_text="🚫"
    json_tooltip="httping command not found!"
    json_class="error"
    echo "{\"text\": \"$json_text\", \"tooltip\": \"$json_tooltip\", \"class\": \"$json_class\"}"
    echo "Error: httping not found." > "$LATENCY_WOFI_OUTPUT_FILE"
    exit 1
fi

# Function to process a single URL
process_url() {
    local url="$1"
    local display_name="$2"
    local is_critical="$3"
    local result_file="$4"

    # Build httping command
    local httping_cmd=()
    httping_cmd=("httping" "-c" "1" "-t" "$HTTPING_REQUEST_TIMEOUT" "-g" "$url")
    [[ "$url" == https://* ]] && httping_cmd+=("-S")

    # Execute with timeout
    local httping_output exit_code
    if command -v timeout &> /dev/null; then
        httping_output=$(timeout "$COMMAND_OVERALL_TIMEOUT" "${httping_cmd[@]}" 2>&1)
        exit_code=$?
    else
        httping_output=$("${httping_cmd[@]}" 2>&1)
        exit_code=$?
    fi

    # Process result
    local latency_result=""
    if [[ $exit_code -eq 0 ]]; then
        if [[ "$httping_output" =~ time=([0-9]+\.?[0-9]*)\ ms ]]; then
            latency_result="${BASH_REMATCH[1]} ms"
        else
            latency_result="OK (No time)"
        fi
    elif [[ $exit_code -eq 124 ]]; then
        latency_result="Timeout (Sys)"
    elif [[ "$httping_output" =~ timeout|deadline|timed\ out ]]; then
        latency_result="Timeout"
    else
        local error_line=$(echo "$httping_output" | head -n 1 | tr -d '\n' | cut -c1-35)
        latency_result="Error ($exit_code)"
        [[ -n "$error_line" ]] && latency_result+=" ($error_line)"
    fi

    # Format output
    local result_line
    if [[ "$latency_result" == Error* || "$latency_result" == Timeout* ]]; then
        result_line="FAILED: $display_name: $latency_result"
    else
        result_line="$display_name: $latency_result"
    fi

    # Store critical status
    if [[ "$is_critical" == "yes" && \
          (! "$latency_result" == *ms && ! "$latency_result" == "OK (No time)") ]]; then
        echo "CRITICAL:$display_name: $latency_result" >> "$TMPDIR/critical_status"
    fi

    # Write result to file
    echo "$result_line" > "$result_file"
}

# --- Main Execution ---
# Start all URL checks in parallel
running_pids=()
url_count=0
for url in "${ALL_URLS_TO_MONITOR[@]}"; do
    display_name="$url"

    # Determine if this is a critical URL
    is_critical="no"
    for critical_url in "${CRITICAL_URLS[@]}"; do
        [[ "$url" == "$critical_url" ]] && is_critical="yes" && break
    done

    # Limit parallel processes
    while (( ${#running_pids[@]} >= MAX_PARALLEL )); do
        # Wait for any background process to finish
        for pid in "${!running_pids[@]}"; do
            if ! kill -0 "$pid" 2>/dev/null; then
                unset 'running_pids[$pid]'
            fi
        done
        sleep 0.1
    done

    # Start new process
    result_file="$TMPDIR/result_$url_count"
    process_url "$url" "$display_name" "$is_critical" "$result_file" &
    running_pids["$!"]=$result_file
    ((url_count++))
done

# Wait for all remaining processes
while (( ${#running_pids[@]} )); do
    for pid in "${!running_pids[@]}"; do
        if ! kill -0 "$pid" 2>/dev/null; then
            unset 'running_pids[$pid]'
        fi
    done
    sleep 0.1
done

# --- Sorting Section ---
sorted_output=()
errors=()
successes=()
ok_no_time=()

# Read all results
for result_file in "$TMPDIR"/result_*; do
    [[ -f "$result_file" ]] && cat "$result_file"
done > "$TMPDIR/all_results"

# Process results
while IFS= read -r line; do
    if [[ "$line" == "FAILED: "* ]]; then
        errors+=("$line")
    elif [[ "$line" == *" ms" ]]; then
        successes+=("$line")
    else
        ok_no_time+=("$line")
    fi
done < "$TMPDIR/all_results"

# Sort successes by latency (high to low)
if (( ${#successes[@]} > 0 )); then
    IFS=$'\n'
    successes=($(printf "%s\n" "${successes[@]}" | awk '
    {
        line = $0
        if (match(line, /([0-9]+(\.[0-9]*)?) ms/, arr)) {
            print -arr[1] " " line
        } else {
            print "0 " line
        }
    }
    ' | sort -n | awk '{ $1=""; print substr($0, 2) }'))
fi

# Combine all parts
sorted_output=("${errors[@]}" "${successes[@]}" "${ok_no_time[@]}")

# Write sorted output
printf "%s\n" "${sorted_output[@]}" > "$LATENCY_WOFI_OUTPUT_FILE"

# --- Process Critical Status ---
# Read critical status from file
if [[ -f "$TMPDIR/critical_status" ]]; then
    all_critical_ok=false
    while IFS=":" read -r _ name reason; do
        failed_critical_details_array+=("$name: $reason")
    done < "$TMPDIR/critical_status"
fi

# Generate JSON output
json_text="⏳"
json_tooltip_content=""
json_class=""

if $all_critical_ok; then
    json_text="🌐"
    json_tooltip_content="Internet Connected. All critical hosts reachable.\nClick for full list."
    json_class="connected"
else
    json_text="⚠️"
    json_tooltip_content="Connection Issue Detected!\n"
    for detail in "${failed_critical_details_array[@]}"; do
        json_tooltip_content+="$detail\n"
    done
    json_tooltip_content+="Click for full list."
    json_class="warning"
fi

# Escape tooltip for JSON
json_tooltip_escaped=$(echo -n "$json_tooltip_content" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')

# Output JSON
echo "{\"text\": \"$json_text\", \"tooltip\": \"$json_tooltip_escaped\", \"class\": \"$json_class\"}"

