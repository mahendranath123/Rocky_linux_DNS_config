
---

# PowerDNS Reverse DNS (PTR) Management Guide

## Overview

This guide provides step-by-step instructions for managing reverse DNS (PTR) records using PowerDNS on Linux systems.

## Table of Contents

* [Configuration Files and Directories](#configuration-files-and-directories)
* [Creating Reverse Zones](#creating-reverse-zones)
* [Adding PTR Records](#adding-ptr-records)
* [Modifying or Deleting PTR Records](#modifying-or-deleting-ptr-records)
* [Bulk PTR Record Management](#bulk-ptr-record-management)
* [Verification and Troubleshooting](#verification-and-troubleshooting)
* [References](#references)

---

## Configuration Files and Directories

* **Main Configuration**: `/etc/powerdns/pdns.conf`
* **Zone Files**: Depending on the backend:

  * **BIND Backend**: `/etc/bind/zones/`
  * **SQLite Backend**: `/var/lib/powerdns/pdns.sqlite3`
* **Logs**: `/var/log/pdns/`

---

## Creating Reverse Zones

To manage PTR records, ensure that the appropriate reverse zone exists.([Poweradmin Documentation][1])

### IPv4 Example

For the IP range `192.0.2.0/24`, create the zone `2.0.192.in-addr.arpa`:

```bash
pdnsutil create-zone 2.0.192.in-addr.arpa ns1.example.com hostmaster.example.com
```



### IPv6 Example

For the IPv6 range `2001:db8::/64`, create the zone `8.b.d.0.1.0.0.2.ip6.arpa`:([Poweradmin Documentation][1])

```bash
pdnsutil create-zone 8.b.d.0.1.0.0.2.ip6.arpa ns1.example.com hostmaster.example.com
```



---

## Adding PTR Records

### Using `pdnsutil`

To add a PTR record for IP `192.0.2.42` pointing to `host42.example.com`:

```bash
pdnsutil add-record 2.0.192.in-addr.arpa 42 PTR host42.example.com.
```



Then, reload the zone:([PowerDNS Documentation][2])

```bash
pdnsutil reload-zone 2.0.192.in-addr.arpa
```



### Using SQL Backend

If you're using a SQL backend (e.g., MySQL or PostgreSQL):

```sql
INSERT INTO records (domain_id, name, type, content, ttl, prio)
VALUES (
  (SELECT id FROM domains WHERE name='2.0.192.in-addr.arpa'),
  '42.2.0.192.in-addr.arpa',
  'PTR',
  'host42.example.com.',
  86400,
  0
);
```



After inserting, reload PowerDNS:

```bash
pdns_control reload
```



---

## Modifying or Deleting PTR Records

### Deleting a PTR Record

To delete the PTR record for `192.0.2.42`:

```bash
pdnsutil delete-rrset 2.0.192.in-addr.arpa 42 PTR
```



Then, reload the zone:

```bash
pdnsutil reload-zone 2.0.192.in-addr.arpa
```



### Replacing a PTR Record

To replace the PTR record for `192.0.2.42` with `host42.corrected.example.com`:

```bash
pdnsutil replace-rrset 2.0.192.in-addr.arpa 42 PTR 86400 host42.corrected.example.com.
```



Then, reload the zone:

```bash
pdnsutil reload-zone 2.0.192.in-addr.arpa
```



---

## Bulk PTR Record Management

### Using PowerDNS Admin (GUI)

PowerDNS Admin offers a "Batch PTR Records" feature:([Poweradmin Documentation][1])

1. Navigate to **Zones → Batch PTR Records**.
2. Fill in the required fields:

   * **IP Version**: IPv4 or IPv6
   * **Network Prefix**: e.g., `192.168.1`
   * **Host Prefix**: e.g., `server`
   * **Domain**: e.g., `example.com`
   * **TTL**: e.g., `86400`
3. Click "Create PTR Records".([Poweradmin Documentation][1])

This will generate PTR records like:

```plaintext
0.1.168.192.in-addr.arpa → server-0.example.com.
1.1.168.192.in-addr.arpa → server-1.example.com.
...
```



### Using Lua Records

For dynamic PTR record generation, you can use Lua scripting:([mailman.powerdns.com][3])

1. Enable Lua records in `pdns.conf`:

   ```ini
   lua-dns-script=/etc/powerdns/reverse.lua
   ```



2. Create `/etc/powerdns/reverse.lua` with content:

   ```lua
   function preresolve(dq)
     if dq.qtype == pdns.PTR then
       local ip = dq.qname:match("(%d+)%.2%.0%.192%.in%-addr%.arpa")
       if ip then
         dq:addAnswer(pdns.PTR, "host" .. ip .. ".example.com.")
         return true
       end
     end
     return false
   end
   ```



3. Restart PowerDNS:

   ```bash
   systemctl restart pdns
   ```



This script dynamically generates PTR records for IPs in the `192.0.2.0/24` range.

---

## Verification and Troubleshooting

### Verify PTR Record

Use `dig` to verify a PTR record:

```bash
dig @127.0.0.1 -x 192.0.2.42 +short
```



Expected output:

```plaintext
host42.example.com.
```



### Check Zone Integrity

To check a specific zone:([HackMD][4])

```bash
pdnsutil check-zone 2.0.192.in-addr.arpa
```



To check all zones:([HackMD][4])

```bash
pdnsutil check-all-zones
```



---

## References

* [PowerDNS Authoritative Server Documentation](https://doc.powerdns.com/authoritative/)
* [PowerDNS Admin - Batch PTR Records](https://docs.poweradmin.org/user-guide/reverse-dns/)
* [PowerDNS Lua Records Guide](https://doc.powerdns.com/authoritative/lua-records/functions.html)
* [PowerDNS Users Mailing List](https://mailman.powerdns.com/mailman/listinfo/pdns-users)

---

For further assistance or advanced configurations, refer to the official PowerDNS documentation or reach out to the PowerDNS community.

---

[1]: https://docs.poweradmin.org/user-guide/reverse-dns/?utm_source=chatgpt.com "Reverse DNS (PTR Records) Guide - Poweradmin Documentation"
[2]: https://doc.powerdns.com/authoritative/upgrading.html?utm_source=chatgpt.com "Upgrade Notes — PowerDNS Authoritative Server documentation"
[3]: https://mailman.powerdns.com/pipermail/pdns-users/2022-June/027727.html?utm_source=chatgpt.com "[Pdns-users] Generating PTR Records for IPv4 and IPv6 Addresses ..."
[4]: https://hackmd.io/%40haquenafeem/Sy20t2W6d?utm_source=chatgpt.com "PowerDNS R&D - HackMD"
