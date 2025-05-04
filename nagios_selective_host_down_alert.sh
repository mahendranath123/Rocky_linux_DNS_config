#!/bin/bash

# Path to Nagios log
LOG_FILE="/usr/local/nagios/var/nagios.log"

# Email address to send alerts
#EMAIL="support@jeebr.net"
EMAIL="mahendranath123mp@gmail.com"

# Path to msmtp
MSMTP="/usr/bin/msmtp"

# Optional log file for monitoring events
MONITOR_LOG="/var/log/nagios_monitor.log"

# Hostname prefixes to trigger alerts for
ALERT_PREFIXES=( )

# Associative array to track hosts already alerted
declare -A alerted_hosts

echo "[ $(date) ] Starting real-time monitoring of Nagios log..." | tee -a "$MONITOR_LOG"

# Use stdbuf to force line buffering; -n 0 avoids replaying old log lines
sudo stdbuf -oL tail -n 0 -F "$LOG_FILE" </dev/null | while read -r line; do
    event_type=""
    host=""

    # Check for HOST NOTIFICATION events from Nagios
    if echo "$line" | grep -q "HOST NOTIFICATION:"; then
         if echo "$line" | grep -q ";DOWN;"; then
             event_type="HOST DOWN"
             host=$(echo "$line" | awk -F';' '{print $2}')
         elif echo "$line" | grep -q ";UP;"; then
             event_type="HOST UP"
             host=$(echo "$line" | awk -F';' '{print $2}')
         fi
    # Check for host timeout events
    elif echo "$line" | grep -q "Warning: Check of host" && echo "$line" | grep -q "timed out"; then
         event_type="HOST TIMEOUT"
         host=$(echo "$line" | sed -nE "s/.*Check of host '([^']+)'.*/\1/p")
    else
         continue
    fi

    # Skip if host is empty
    [[ -z "$host" ]] && continue

    # Process events only if the host matches one of our prefixes
    should_alert=false
    for prefix in "${ALERT_PREFIXES[@]}"; do
        if [[ "$host" == "$prefix"* ]]; then
            should_alert=true
            break
        fi
    done

    if [[ "$should_alert" == true ]]; then
        # For DOWN or TIMEOUT events, only alert if we haven't already alerted the host
        if [[ "$event_type" == "HOST DOWN" || "$event_type" == "HOST TIMEOUT" ]]; then
            if [[ -z "${alerted_hosts[$host]}" ]]; then
                # Try extracting an epoch timestamp from the log entry; if not available, use the current time
                epoch=$(echo "$line" | sed -nE 's/^\[([0-9]+)\].*/\1/p')
                if [[ -n "$epoch" ]]; then
                    timestamp_readable=$(date -d @"$epoch" "+%A %d %B %Y %I:%M:%S %p %Z")
                else
                    timestamp_readable=$(date "+%A %d %B %Y %I:%M:%S %p %Z")
                fi

                echo "[${timestamp_readable}] ALERT: Host '$host' is $event_type. Sending notification..." | tee -a "$MONITOR_LOG"
                alerted_hosts["$host"]=1

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
                echo "$body" | $MSMTP -t >> /var/log/msmtp.log 2>&1 &
            else
                echo "[INFO] Duplicate event for '$host' ignored." | tee -a "$MONITOR_LOG"
            fi

        # For recovery events, reset the alerted flag so future DOWN events can trigger notifications again
        elif [[ "$event_type" == "HOST UP" ]]; then
             if [[ -n "${alerted_hosts[$host]}" ]]; then
                 epoch=$(echo "$line" | sed -nE 's/^\[([0-9]+)\].*/\1/p')
                 if [[ -n "$epoch" ]]; then
                     timestamp_readable=$(date -d @"$epoch" "+%A %d %B %Y %I:%M:%S %p %Z")
                 else
                     timestamp_readable=$(date "+%A %d %B %Y %I:%M:%S %p %Z")
                 fi

                 echo "[${timestamp_readable}] RECOVERY: Host '$host' is now UP. Clearing alert flag." | tee -a "$MONITOR_LOG"
                 unset alerted_hosts["$host"]

                 # Optional: send a recovery notification email
                 body=$(cat <<EOF
To: $EMAIL
Subject: ** NAGIOS RECOVERY: Host $host is now UP **

***** Nagios Realtime Monitor *****

Host $host has recovered (UP).

Log Entry:
$line

Date/Time: $timestamp_readable
EOF
)
                 echo "$body" | $MSMTP -t >> /var/log/msmtp.log 2>&1 &
             fi
        fi
    fi
done
