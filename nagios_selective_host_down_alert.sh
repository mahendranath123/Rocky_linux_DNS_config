#!/bin/bash

# Path to Nagios log
LOG_FILE="/usr/local/nagios/var/nagios.log"

# Email address to send alerts
#EMAIL="support@jeebr.net"
EMAIL="mahendranath123mp@gmail.com"

# Path to msmtp
MSMTP="/usr/bin/msmtp"

# Hostname prefixes to trigger alerts for
ALERT_PREFIXES=("Pharma" "Infinity_Cars" "Priceline.com" "AR_Gold" "ICMP_Veefin" "Vishwa_Niketan" "Fifth_Gear_Ventures" "Sound_and_Vision" "AP_Shah" "EZO" "Tejax_Support" "SME_Cellcure" "Hubcom_Technology" "Multistream_Technology" "SME_Sectona_Technologies" "Light_House_Learning" "Maharashtra_State_Skills" "LRN_Technologies" "ICMP_Block_LRN_Technologies" "PLEASE_SEE_ADVERTISING" "ICMP_Veefin_Solutions" "Reflection_Pictures" "ICMP_Reflection_Pictures" "UFO_Moviez_India" "SALMAN_SALIM_KHAN" "testing1" "Sun_Petrochemicals")

# Time threshold to suppress repeated alerts (in seconds)
ALERT_COOLDOWN=300  # 5 minutes

# Track alerts to avoid repeated notifications
declare -A sent_alerts

echo "[ $(date) ] Monitoring Nagios log for HOST DOWN / TIMEOUT alerts..."

# Watch the Nagios log in real-time; note the redirection of standard input from /dev/null below.
sudo tail -F "$LOG_FILE" </dev/null | while read -r line; do
    event_type=""
    host=""

    # Condition A: Look for HOST NOTIFICATION lines with ";DOWN;"
    if echo "$line" | grep -q "HOST NOTIFICATION:" && echo "$line" | grep -q ";DOWN;"; then
        event_type="HOST DOWN"
        # For HOST NOTIFICATION lines, assume the host is the second semicolon-delimited field.
        host=$(echo "$line" | awk -F';' '{print $2}')

    # Condition B: Look for timeout warning lines
    elif echo "$line" | grep -q "Warning: Check of host" && echo "$line" | grep -q "timed out"; then
        event_type="HOST TIMEOUT"
        # Extract the host name from within single quotes.
        host=$(echo "$line" | sed -nE "s/.*Check of host '([^']+)'.*/\1/p")
    else
        continue
    fi

    # Skip if host is empty.
    [[ -z "$host" ]] && continue

    # Check if the host name matches one of the prefixes.
    should_alert=false
    for prefix in "${ALERT_PREFIXES[@]}"; do
        if [[ "$host" == "$prefix"* ]]; then
            should_alert=true
            break
        fi
    done

    if [[ "$should_alert" == true ]]; then
        # Extract the epoch timestamp and convert to a human-readable format.
        epoch=$(echo "$line" | sed -nE 's/^\[([0-9]+)\].*/\1/p')
        timestamp_readable=$(date -d @"$epoch" "+%A %d %B %Y %I:%M:%S %p %Z")

        current_time=$(date +%s)
        last_sent=${sent_alerts["$host"]:-0}
        time_diff=$(( current_time - last_sent ))

        if (( time_diff >= ALERT_COOLDOWN )); then
            echo "[${timestamp_readable}] ALERT: Host '$host' is $event_type. Sending email alert..."
            sent_alerts["$host"]=$current_time

            body=$(cat <<EOF
To: $EMAIL
Subject: ** NAGIOS ALERT: Host $host is $event_type **

***** Nagios Realtime Monitor *****

Event Type: $event_type
Host: $host

Log Entry:
$line

Date/Time: $timestamp_readable
EOF
)
            # Send email with msmtp; output will be logged to /var/log/msmtp.log.
            echo "$body" | $MSMTP -t >> /var/log/msmtp.log 2>&1 &
        else
            echo "[${timestamp_readable}] INFO: Host '$host' is $event_type but alert was sent recently ($time_diff seconds ago). Skipping..."
        fi
    fi
done
