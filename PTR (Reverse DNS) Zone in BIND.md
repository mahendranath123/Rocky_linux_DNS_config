
# Configuring a PTR (Reverse DNS) Zone in BIND

This guide explains how to set up a reverse DNS zone (PTR record) in BIND. It covers the following steps:

- Modifying `/etc/named.conf` to include the reverse zone.
- Creating the reverse zone file.
- Setting proper permissions.
- Restarting BIND.
- Testing the PTR record.

> **Note:** Adjust the domain names, file paths, and IP ranges to match your environment.

---

## Table of Contents

- [1. Modify `/etc/named.conf` to Include Reverse Zone](#1-modify-etcnamedconf-to-include-reverse-zone)
- [2. Create the Reverse Zone File](#2-create-the-reverse-zone-file)
- [3. Set Permissions](#3-set-permissions)
- [4. Restart BIND](#4-restart-bind)
- [5. Test Reverse DNS](#5-test-reverse-dns)

---

## 1. Modify `/etc/named.conf` to Include Reverse Zone

Edit the `/etc/named.conf` file and add the following zone entry:

```conf
zone "147.423.103.in-addr.arpa" IN {
    type master;
    file "/var/named/rev.103.423.147.db";
    allow-update { none; };
};
```

**Explanation:**

- `"147.423.103.in-addr.arpa"` is the reverse DNS zone for the IP range `103.423.147.x`.
- The zone file is stored in `/var/named/rev.103.423.147.db`.

---

## 2. Create the Reverse Zone File

Create the file `/var/named/rev.103.423.147`:

```bash
sudo nano /var/named/rev.103.423.147.db
```

Add the following content:

```conf
$TTL 86400
@   IN  SOA ms.mahendranath.com. admin.mahendranath.xom. (
            2025032001  ; Serial (change this when editing)
            3600        ; Refresh
            1800        ; Retry
            604800      ; Expire
            86400 )     ; Minimum TTL

    IN  NS  ms.mahendranath.com.

254 IN  PTR ms.mahendranath.com.
```

**Explanation:**

- **Serial number:** `2025032001` — Update this number whenever you modify the file.
- **PTR Record:** `254 IN PTR ms.mahendranth.com.` maps the IP address `103.423.147` to `ms.mahendranth.com.`

---

## 3. Set Permissions

Ensure the zone file has the correct permissions:

```bash
sudo chown named:named /var/named/rev.103.423.147.db
sudo chmod 640 /var/named/rev.103.423.147.db
```

---

## 4. Restart BIND

Restart the BIND service to apply the changes:

```bash
sudo systemctl restart named
```

---

## 5. Test Reverse DNS

To verify that the PTR record is working, run:

```bash
dig -x 103.423.147 @localhost
```

If configured correctly, the output should include:

```css
;; ANSWER SECTION:
103.423.147.in-addr.arpa. 86400 IN PTR ms.mahendranth.com.
```

---

