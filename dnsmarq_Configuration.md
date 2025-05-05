# DNSMasq Configuration Reference

This document provides a concise reference for the `dnsmasq` configuration file (`/etc/dnsmasq.conf`) and how to define forward and reverse DNS records using `host-record` and `ptr-record` directives.

## `/etc/dnsmasq.conf`

### Primary Configuration File

At startup, `dnsmasq` reads `/etc/dnsmasq.conf` (unless overridden with `--conf-file`) to load all settings and behavior directives.

### One‐Option‐Per‐Line Syntax

Each non-comment line in the file corresponds to a single `dnsmasq` long-form option (without the leading `--` used on the command line).

### Comments

Lines beginning with `#` are ignored. The default shipped file is heavily commented to document each available option.

## Key Roles of `dnsmasq.conf`

### DNS Forwarding & Caching

* **Upstream servers**: e.g., `server=8.8.8.8`
* **Cache control**: adjust size and TTL limits

### DHCP Service (if enabled)

* **Address pools**: `dhcp-range=`
* **Static mappings**: `dhcp-host=` for MAC-to-IP assignments

### TFTP / PXE Boot

* **Enable TFTP**: `enable-tftp`
* **Set root**: `tftp-root=` for firmware/boot images

### Custom Hosts & Domains

* **Additional hosts**: `addn-hosts=` to include extra host files
* **Local domains**: `local=/example.lan/` to define special zones

## Configuring PTR (Reverse DNS) Records

When you need to serve reverse-DNS (PTR) queries, you have three primary methods:

### 1. `host-record=` (Recommended)

Defines both the forward (A/AAAA) and reverse (PTR) record in one directive:

```ini
host-record=<hostname>,<IPv4-address>[,<IPv6-address>]
```

**Example**:

```ini
# Creates both A and PTR for printer.local ↔ 192.168.2.50
host-record=printer.local,192.168.2.50
```

### 2. `ptr-record=` (Use Sparingly)

Defines only a PTR record, useful when the forward record is managed elsewhere:

```ini
ptr-record=<reversed-ip>.in-addr.arpa,<fully-qualified-domain-name>
```

**Example**:

```ini
# For IP 192.168.2.1 pointing back to cs-tech1.local
ptr-record=1.2.168.192.in-addr.arpa,cs-tech1.local
```

### 3. `/etc/hosts` + `expand-hosts`

Leverage your existing `/etc/hosts` file and let `dnsmasq` synthesize both A and PTR records:

```ini
# In /etc/dnsmasq.conf
expand-hosts
domain=your.local.domain
```

Add entries to `/etc/hosts`:

```
192.168.2.10    device1.local
```

## Recommendation

Use `host-record=` for devices managed by `dnsmasq` to ensure consistent forward and reverse mappings. Reserve `ptr-record=` only for exceptional cases where the A/AAAA record is hosted on another DNS system.
