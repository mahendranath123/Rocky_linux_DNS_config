
# Logging BIND Messages in `/var/log/messages` on Rocky Linux

> **Tip:** BIND may log to syslog by default. The configuration below ensures that your BIND logs appear in `/var/log/messages`.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [1. Ensure rsyslog Is Installed and Running](#1-ensure-rsyslog-is-installed-and-running)
- [2. Configure BIND to Log to Syslog](#2-configure-bind-to-log-to-syslog)
  - [2.1 Edit the Main BIND Configuration File](#21-edit-the-main-bind-configuration-file)
  - [2.2 Add or Modify the Logging Section](#22-add-or-modify-the-logging-section)
- [3. Restart BIND and Verify Logging](#3-restart-bind-and-verify-logging)
- [4. Verify BIND Logs in `/var/log/messages`](#4-verify-bind-logs-in-varlogmessages)
- [5. Additional Restart (If Needed)](#5-additional-restart-if-needed)
- [YAML Example (Optional)](#yaml-example-optional)

---

## Prerequisites

- **Rocky Linux** system
- BIND (named) installed and configured
- Administrative (sudo) access

---

## 1. Ensure rsyslog Is Installed and Running

First, install and enable rsyslog:

```bash
sudo dnf install rsyslog -y
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
```

Verify that rsyslog is active:

```bash
sudo systemctl status rsyslog
```

Check that `/var/log/messages` exists:

```bash
ls -l /var/log/messages
```

If the file exists, you’re ready to proceed.

---

## 2. Configure BIND to Log to Syslog

### 2.1 Edit the Main BIND Configuration File

Open the BIND configuration file:

```bash
sudo vi /etc/named.conf
```

### 2.2 Add or Modify the Logging Section

Insert (or update) the following `logging { ... }` section to direct BIND logs to syslog:

```conf
logging {
    channel default_syslog {
         syslog daemon;  // Use the syslog 'daemon' facility
         severity info;  // Set the log level as desired (e.g., info, debug, etc.)
    };
    category default { default_syslog; };
    category security { default_syslog; };
    category config { default_syslog; };
    category resolver { default_syslog; };
    // You can add additional categories if needed.
};
```

> **Note:** Ensure your rsyslog configuration (typically in `/etc/rsyslog.conf`) is set to capture messages from the daemon facility into `/var/log/messages`.

Save your changes and exit the editor.

---

## 3. Restart BIND and Verify Logging

Restart the BIND service to apply your new logging configuration:

```bash
sudo systemctl restart named
```

Check the status of the BIND service:

```bash
sudo systemctl status named
```

Generate some activity (for example, by querying your server):

```bash
dig @127.0.0.1 ms.mahendranath.com
```

---

## 4. Verify BIND Logs in `/var/log/messages`

Tail the `/var/log/messages` file to view the BIND log entries:

```bash
sudo tail -f /var/log/messages
```

Look for log entries tagged with **"named"** or from the syslog daemon facility.

---

## 5. Additional Restart (If Needed)

If required, you can restart BIND again with:

```bash
sudo systemctl restart named
```

---

## YAML Example (Optional)

For those who prefer YAML configuration snippets, here’s an example:

```yaml
logging:
  channels:
    default_syslog:
      syslog: daemon   # Use the syslog 'daemon' facility
      severity: info   # Set the desired log level
  categories:
    default: [default_syslog]
    security: [default_syslog]
    config: [default_syslog]
    resolver: [default_syslog]
```

---

By following these steps, your BIND logs will now be sent to `/var/log/messages` via the syslog daemon on Rocky Linux.

Happy logging!  
```

This Markdown file includes a table of contents, clear section headings, and inline notes for a more engaging and readable experience. Enjoy!
