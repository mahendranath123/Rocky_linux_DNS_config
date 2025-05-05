# BIND DNS Server Setup & Troubleshooting

This document provides a quick reference for configuring and troubleshooting BIND (named) on a Linux system.

---

## 🔧 Main Configuration Files & Directories

| Path                       | Purpose                                                  |
| -------------------------- | -------------------------------------------------------- |
| `/etc/named.conf`          | Main BIND configuration file (entry point)               |
| `/var/named/`              | Default directory for zone files (forward/reverse zones) |
| `/etc/named.rfc1912.zones` | Optional zone definitions included in `named.conf`       |
| `/etc/named.root.key`      | Root zone trust anchor for DNSSEC                        |
| `/var/named/data/`         | Statistics, cache dumps, etc.                            |
| `/var/named/dynamic/`      | Directory for dynamic zones (e.g., `nsupdate`)           |
| `/run/named/`              | Runtime files (PID files, etc.)                          |
| `/etc/sysconfig/named`     | Environment settings (RedHat/CentOS)                     |

## 🗂️ Example Zone Files (in `/var/named/`)

* `/var/named/example.com.zone`       	# Forward zone file for `example.com`
* `/var/named/1.168.192.in-addr.arpa` 	# Reverse zone for `192.168.1.x`

These files must be referenced in your `named.conf` or included zone definition files.

## 🔍 Listing & Validating Configurations

```bash
# View main configuration
cat /etc/named.conf

# List available zone files
ts
ls -l /var/named/

# Validate named.conf syntax
ts
named-checkconf

# Validate a zone file syntax
ts
named-checkzone example.com /var/named/example.com.zone
```

---

## 🪵 Log Files for Troubleshooting

| Log File                          | Description                                           |
| --------------------------------- | ----------------------------------------------------- |
| `/var/log/messages`               | General system log (common location for named errors) |
| `/var/log/named/named.log`        | Dedicated BIND log (if enabled in `named.conf`)       |
| `/var/log/syslog` (Debian/Ubuntu) | System log including DNS messages                     |
| `/var/log/secure`                 | Security events (SELinux, policy denials)             |

On systemd systems, you can also use:

```bash
journalctl -u named.service
```

---

## 🧪 Checking Service Status

```bash
# RedHat/CentOS
systemctl status named

# SysV init systems
service named status
```

---

## 🛠️ Common Troubleshooting Commands

```bash
# Check main configuration syntax
named-checkconf

# Validate a zone file
named-checkzone mydomain.com /var/named/mydomain.com.zone

# Test DNS resolution locally
dig @localhost mydomain.com

# Check BIND runtime status
rndc status

# Reload configuration without downtime
rndc reload
```

---

## 🔐 SELinux & Firewall (RHEL/CentOS)

```bash
# Check SELinux mode
sestatus

# List named-related SELinux booleans
getsebool -a | grep named

# Allow DNS through firewalld
firewall-cmd --add-service=dns --permanent
firewall-cmd --reload
```

---

## 📌 Enabling Debug Logging

If you need more detailed logs, add a logging section in `/etc/named.conf`:

```conf
logging {
    channel default_debug {
        file "/var/log/named/named.log";
        severity dynamic;
    };
    category default { default_debug; };
};
```

Then restart BIND:

```bash
systemctl restart named
```

---

*End of README.md*
