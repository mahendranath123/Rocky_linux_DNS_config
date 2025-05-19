Absolutely! Let's expand the guide with full **failover/high availability using Keepalived**, plus show how to **change the load balancing algorithm** in HAProxy (to `weight`, `leastconn`, etc.) – all tailored for **Rocky Linux + Centreon** setup.

---

# 🛡️ HAProxy Load Balancer with High Availability (Keepalived) for Centreon

---

## ✅ What You'll Achieve

- 🧰 **2 HAProxy servers** (active-passive setup)
- 🛡️ **Keepalived** to manage a **Virtual IP (VIP)**
- 🔁 **Failover** between HAProxy servers if the active one fails
- 📊 **HAProxy** load balances traffic to **2 Centreon servers**
- 🔄 Use of **load balancing algorithms**: `roundrobin`, `leastconn`, `weight`, etc.

---

## 📦 Updated Architecture

```
          [Client Browser]
                 │
                 ▼
        ┌────────────────────┐
        │ Virtual IP (VIP)   │  ← Managed by Keepalived (e.g. 192.168.1.100)
        └────────┬───────────┘
                 │
    ┌────────────┴────────────┐
    ▼                         ▼
┌────────────┐          ┌────────────┐
│ HAProxy #1 │          │ HAProxy #2 │
│ Master     │          │ Backup     │
└────────────┘          └────────────┘
         │                     │
         └────┬────────────┬───┘
              ▼            ▼
     ┌──────────────┐   ┌──────────────┐
     │ Centreon #1  │   │ Centreon #2  │
     │ 192.168.1.101│   │ 192.168.1.102│
     └──────────────┘   └──────────────┘
```

---

## 🧱 Requirements

| Component       | Description                          |
|----------------|--------------------------------------|
| HAProxy-1       | Primary Load Balancer (Master)        |
| HAProxy-2       | Backup Load Balancer (Slave)          |
| Keepalived      | Provides Virtual IP and failover      |
| Centreon-1/2    | Monitoring servers (load balanced)    |

> All servers must be on same subnet for VIP to work.

---

## 🛠️ Part 1: Install Keepalived on Both HAProxy Servers

### ✅ Step 1.1: Install Keepalived

```bash
sudo dnf install keepalived -y
```

---

### ✅ Step 1.2: Configure Keepalived on **HAProxy #1 (Master)**

```bash
sudo nano /etc/keepalived/keepalived.conf
```

```conf
vrrp_instance VI_1 {
    state MASTER
    interface eth0                # Replace with your network interface
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass secretpass
    }
    virtual_ipaddress {
        192.168.1.100             # Virtual IP to float between LB nodes
    }
}
```

---

### ✅ Step 1.3: Configure Keepalived on **HAProxy #2 (Backup)**

```bash
sudo nano /etc/keepalived/keepalived.conf
```

```conf
vrrp_instance VI_1 {
    state BACKUP
    interface eth0                # Same interface
    virtual_router_id 51
    priority 90                   # Lower priority so it's backup
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass secretpass
    }
    virtual_ipaddress {
        192.168.1.100
    }
}
```

---

### ✅ Step 1.4: Enable and Start Keepalived

```bash
sudo systemctl enable keepalived
sudo systemctl start keepalived
```

> 🧪 Test by shutting down HAProxy-1, and pinging `192.168.1.100`. It should failover to HAProxy-2.

---

## ⚙️ Part 2: Configure HAProxy with Load Balancing Algorithms

### 🔁 Default Configuration (Round Robin)

```haproxy
backend centreon_servers
    balance roundrobin
    option httpchk GET /
    server centreon1 192.168.1.101:80 check
    server centreon2 192.168.1.102:80 check
```

---

### 🔄 Change to Least Connections

```haproxy
backend centreon_servers
    balance leastconn
    option httpchk GET /
    server centreon1 192.168.1.101:80 check
    server centreon2 192.168.1.102:80 check
```

> ⚖️ Useful when server load varies. Requests go to the server with the fewest connections.

---

### ⚖️ Use Weighted Load Balancing

```haproxy
backend centreon_servers
    balance roundrobin
    option httpchk GET /
    server centreon1 192.168.1.101:80 weight 3 check
    server centreon2 192.168.1.102:80 weight 1 check
```

> 🏋️ Centreon-1 will receive 3x more traffic than Centreon-2.

---

### 📌 Use Source IP Hashing (Sticky Sessions)

```haproxy
backend centreon_servers
    balance source
    option httpchk GET /
    server centreon1 192.168.1.101:80 check
    server centreon2 192.168.1.102:80 check
```

> 💡 Sticky sessions — same clients are always sent to the same server.

---

## 🧪 Part 3: Testing High Availability

### ✅ Test VIP Failover

1. Ping the VIP from a client:
   ```bash
   ping 192.168.1.100
   ```

2. Stop Keepalived on HAProxy-1:
   ```bash
   sudo systemctl stop keepalived
   ```

3. The VIP should automatically switch to HAProxy-2.

---

## 🔁 Summary

| Component | IP Address         | Role              |
|----------|--------------------|-------------------|
| HAProxy-1 (Master) | 192.168.1.10        | Load Balancer + Keepalived MASTER |
| HAProxy-2 (Backup) | 192.168.1.11        | Load Balancer + Keepalived BACKUP |
| Virtual IP         | 192.168.1.100       | Client entry point (VIP) |
| Centreon-1         | 192.168.1.101       | Backend monitoring server |
| Centreon-2         | 192.168.1.102       | Backend monitoring server |

---

## 🔐 Optional: Add HTTPS (SSL Termination)

Want the HAProxy to serve HTTPS using Let's Encrypt or self-signed certs?

Let me know and I’ll generate that guide too.

---

## ✅ Final Recommendations

- Use **Keepalived health checks** for deeper failover logic (e.g., check HAProxy is actually running).
- Monitor HAProxy with the **stats page**:
  ```haproxy
  listen stats
      bind *:8404
      stats enable
      stats uri /stats
      stats auth admin:admin123
  ```

---

