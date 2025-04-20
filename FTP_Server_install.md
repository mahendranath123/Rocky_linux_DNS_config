
# 🚀 Setup Guide: FTP Server (vsftpd) on Rocky Linux

A step-by-step guide to install and configure a **secure FTP server** using `vsftpd` on **Rocky Linux 8/9**.

---

## 📋 Prerequisites

✅ A system running **Rocky Linux 8 or 9**  
✅ Root or sudo privileges  
✅ Internet connectivity  

---

## 🛠️ Installation & Setup

### 1. 🔄 Update System Packages

```bash
sudo yum update -y
```

---

### 2. 📦 Install vsftpd

```bash
sudo dnf install -y vsftpd
```

---

### 3. ▶️ Start & Enable the Service

```bash
sudo systemctl enable --now vsftpd
```

Check service status:

```bash
sudo systemctl status vsftpd
```

---

### 4. 🔥 Configure the Firewall

```bash
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=30000-31000/tcp
sudo firewall-cmd --reload
```

---

### 5. 🔐 Configure SELinux (Optional but Recommended)

Allow FTP access to home directories:

```bash
sudo setsebool -P ftp_home_dir on
```

(Optional) Allow full FTPD access:

```bash
sudo setsebool -P allow_ftpd_full_access on
```

Install SELinux tools if needed:

```bash
sudo dnf install -y policycoreutils policycoreutils-python-utils
```

---

### 6. ⚙️ Configure vsftpd

Edit the config file:

```bash
sudo vi /etc/vsftpd/vsftpd.conf
```

Recommended configuration options:

```ini
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
pasv_min_port=30000
pasv_max_port=31000
```

> ✅ Save and exit (`:wq` in `vi`)

---

### 7. 🔁 Restart vsftpd

```bash
sudo systemctl restart vsftpd
```

---

## ✅ Verification

### Check service:
```bash
sudo systemctl status vsftpd
```

### Check port 21:
```bash
sudo ss -tlnp | grep :21
```

### Check firewall rules:
```bash
sudo firewall-cmd --list-all
```

### Get server IP:
```bash
ip a
```

---

## 💡 Notes

- Use **passive mode** in your FTP client with ports `30000–31000`
- If you face permission issues, double-check **SELinux** and **directory ownership**
- For secure alternatives, consider using **SFTP** (SSH-based FTP)

---

