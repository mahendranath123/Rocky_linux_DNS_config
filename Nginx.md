

# 🧰 Centreon Load Balancer Setup using Nginx

## 📋 Requirements

- **1 Load Balancer Server** (with **public IP**, running **Nginx**)
- **2 Centreon Servers** (with **private IPs**, e.g. `192.168.1.101`, `192.168.1.102`)
- All servers should be reachable **from the Load Balancer**

---

## 🔧 Step-by-Step Setup of Nginx Load Balancer

### ✅ Step 1: Install Nginx on Load Balancer Server

```bash
sudo apt update
sudo apt install nginx -y
```

---

### ✅ Step 2: Configure Nginx for Load Balancing

Create a new config file for Centreon load balancing:

```bash
sudo nano /etc/nginx/conf.d/centreon_lb.conf
```

Paste the following example configuration:

```nginx
upstream centreon_backend {
    server 192.168.1.101;
    server 192.168.1.102;
}

server {
    listen 80;

    location / {
        proxy_pass http://centreon_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

> 🔁 Replace `192.168.1.101` and `192.168.1.102` with your actual Centreon server IPs.

---

### ✅ Step 3: Restart Nginx

Test the configuration and restart Nginx:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

## 🌐 Access Centreon Through Load Balancer

Open your browser and visit:

```
http://<public-ip-of-nginx>
```

Traffic will be forwarded to one of the backend Centreon servers.

---

## 🔁 Types of Load Balancing in Nginx

Customize load balancing behavior in the `upstream` block:

### 1. **Round Robin** (Default)

```nginx
upstream backend {
    server 192.168.1.101;
    server 192.168.1.102;
}
```

⭐ Evenly distributes requests between servers.

---

### 2. **Least Connections**

```nginx
upstream backend {
    least_conn;
    server 192.168.1.101;
    server 192.168.1.102;
}
```

⭐ Sends requests to the server with the **fewest active connections**.

---

### 3. **IP Hash**

```nginx
upstream backend {
    ip_hash;
    server 192.168.1.101;
    server 192.168.1.102;
}
```

⭐ Ensures **sticky sessions** — same client IP always hits the same backend.

---

### 4. **Weight-Based Load Balancing**

```nginx
upstream backend {
    server 192.168.1.101 weight=3;
    server 192.168.1.102 weight=1;
}
```

⭐ `192.168.1.101` handles **3x more traffic** than `192.168.1.102`.

---

## 🛡️ Basic Health Checks (Optional)

Add **failover configuration** inside your `upstream` block:

```nginx
upstream centreon_backend {
    server 192.168.1.101 max_fails=3 fail_timeout=30s;
    server 192.168.1.102 max_fails=3 fail_timeout=30s;
}
```

> This will **temporarily remove** a server if it fails 3 times within 30 seconds.

---

## 🔐 Optional: SSL (HTTPS) Setup

Would you like to secure the load balancer with HTTPS?

We recommend using **Let's Encrypt** + **Certbot**:

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx
```

> 🔒 Follow the interactive prompt to generate and install an SSL certificate.

---

## 💡 Tips

- Ensure firewall (e.g., `ufw`, `iptables`) allows **HTTP (port 80)** and optionally **HTTPS (port 443)**
- Monitor Nginx logs for debugging:
  ```bash
  tail -f /var/log/nginx/access.log /var/log/nginx/error.log
  ```

---

