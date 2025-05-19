Absolutely! Here's a **comprehensive, detailed step-by-step guide** for setting up **HAProxy Load Balancer** on **Rocky Linux** to load balance two **Centreon monitoring servers.**

---

# 🧰 Step-by-Step Guide: HAProxy Load Balancer for Centreon on Rocky Linux

---

## 📋 Overview

We will set up:

- **1 HAProxy server** (with a **public IP**) acting as a **load balancer**
- **2 Centreon servers** (with **private IPs**, e.g., `192.168.1.101` and `192.168.1.102`)
- All traffic to the HAProxy server will be distributed to the backend Centreon servers

---

## 🧱 Architecture Diagram

```
                ┌────────────────────────────┐
                │     Client (Web Browser)   │
                └────────────┬───────────────┘
                             │
                             ▼
              ┌─────────────────────────────┐
              │  HAProxy Load Balancer (LB) │   ← Public IP
              └──────┬──────────────────────┘
                     │
      ┌──────────────┼──────────────┐
      ▼                              ▼
┌──────────────┐              ┌──────────────┐
│ Centreon #1  │              │ Centreon #2  │
│ 192.168.1.101│              │ 192.168.1.102│
└──────────────┘              └──────────────┘
```

---

## 🛠️ Prerequisites

- A **Rocky Linux 8 or 9 server** for HAProxy with a public IP
- Two **Centreon monitoring servers** installed and running
- Access to the terminal with **sudo/root privileges**

---

## 🔧 Step 1: Install HAProxy on Rocky Linux

### 1.1 Update the system and install EPEL

```bash
sudo dnf update -y
sudo dnf install epel-release -y
```

### 1.2 Install HAProxy

```bash
sudo dnf install haproxy -y
```

### 1.3 Enable and start HAProxy

```bash
sudo systemctl enable haproxy
sudo systemctl start haproxy
sudo systemctl status haproxy
```

> ✅ HAProxy is now installed and running!

---

## ⚙️ Step 2: Configure HAProxy to Load Balance Centreon

### 2.1 Backup the original config

```bash
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
```

### 2.2 Edit the HAProxy configuration

```bash
sudo nano /etc/haproxy/haproxy.cfg
```

Replace the contents with the following configuration:

```haproxy
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon
    maxconn 2048

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend http_front
    bind *:80
    default_backend centreon_servers

backend centreon_servers
    balance roundrobin
    option httpchk GET /
    http-check expect status 200
    server centreon1 192.168.1.101:80 check
    server centreon2 192.168.1.102:80 check
```

### 🔍 Explanation:

| Section | Description |
|--------|-------------|
| `frontend http_front` | Listens on port **80** (for HTTP) |
| `backend centreon_servers` | Backend pool containing both Centreon servers |
| `balance roundrobin` | Load balancing method (can be changed to `leastconn`, `source`, etc.) |
| `option httpchk` | Performs a health check using HTTP GET `/` |
| `check` | Enables active health checks on Centreon servers |

---

## 🔐 Step 3: Configure Firewall

Allow HTTP traffic (port 80):

```bash
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
```

---

## 🔄 Step 4: Restart HAProxy to Apply Config

```bash
sudo systemctl restart haproxy
```

---

## 🌐 Step 5: Test the Load Balancer

Open your browser and access:

```
http://<public-ip-of-haproxy-server>
```

You should see the Centreon web interface.

> 🔁 Refresh the page multiple times — HAProxy will forward requests to different backends (round-robin).

---

## 🎛️ Step 6: Enable HAProxy Statistics Page (Optional)

Useful for monitoring backend health and traffic.

### 6.1 Add to `haproxy.cfg`:

```haproxy
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 10s
    stats realm Haproxy\ Statistics
    stats auth admin:admin123
```

### 6.2 Restart HAProxy:

```bash
sudo systemctl restart haproxy
```

### 6.3 Access the stats page:

```
http://<public-ip>:8404/stats
```

Login with:

- **Username**: `admin`
- **Password**: `admin123`

---

## 🔁 Load Balancing Algorithms (Optional)

You can switch the load balancing method in the backend section:

### 🔄 1. Round Robin (Default)

```haproxy
balance roundrobin
```

Distributes connections evenly.

---

### 📉 2. Least Connections

```haproxy
balance leastconn
```

Sends traffic to the server with the fewest active connections.

---

### 📍 3. Source (Sticky Sessions)

```haproxy
balance source
```

Same IP always goes to the same backend (useful for sessions).

---

## 🔐 Optional: Add HTTPS (SSL) with HAProxy

If you want HAProxy to handle **HTTPS**, you’ll need:

1. SSL certificate (from Let's Encrypt or self-signed)
2. Update HAProxy config to bind port 443 and point to the certificate

> Let me know if you want a **detailed SSL setup guide** too!

---

## 🛠️ Troubleshooting Tips

| Issue | Solution |
|-------|----------|
| HAProxy not starting | Check with `sudo haproxy -c -f /etc/haproxy/haproxy.cfg` |
| Backend not reachable | Check firewall, ping the backend IPs |
| Centreon not loading | Try accessing backend IPs directly to verify |
| 503 Service Unavailable | Backend servers may be down or health check failing |

---

## ✅ Summary

| Component | Role | IP Address |
|----------|------|------------|
| HAProxy Load Balancer | Public-facing | `<public-ip>` |
| Centreon Server 1 | Monitoring backend | `192.168.1.101` |
| Centreon Server 2 | Monitoring backend | `192.168.1.102` |

---

