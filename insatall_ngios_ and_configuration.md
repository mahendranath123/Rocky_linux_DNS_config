# Install Nagios Core on Rocky Linux 8

Below is a step-by-step guide to install **Nagios Core** on **Rocky Linux 8** and configure it to monitor a remote host. Adjust IP addresses, hostnames, and any custom settings to suit your environment.

## 1. Install Apache and PHP

Nagios' web interface requires Apache and PHP. First, install Apache and enable its service:

```bash
sudo dnf install httpd
sudo systemctl enable --now httpd
```

Next, install PHP 8.1 using the Remi repository:

```bash
sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.1 -y
sudo dnf install -y php php-gd php-curl
```

Verify PHP installation:

```bash
php --version
```

Enable PHP-FPM and restart Apache:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl restart httpd
```

(Optional) Create a test file to verify PHP is working:

```bash
sudo tee /var/www/html/info.php << 'EOF'
<?php phpinfo(); ?>
EOF
```

Visit `http://<your_server_ip>/info.php` in your browser.

## 2. Install Nagios Core

### Download and Extract Nagios

Download the Nagios Core source:

```bash
cd ~
sudo wget -O nagios.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.10/nagios-4.4.10.tar.gz
sudo tar zxf nagios.tar.gz
sudo mv nagios-4.4.10 /usr/src/nagios
cd /usr/src/nagios
```

### Compile and Install

Check prerequisites:

```bash
sudo ./configure
```

Compile Nagios:

```bash
sudo make all
```

Create a Nagios user and group:

```bash
sudo make install-groups-users
sudo usermod -a -G nagios apache
```

Install Nagios components:

```bash
sudo make install
sudo make install-commandmode
sudo make install-config
sudo make install-webconf
sudo systemctl restart httpd
sudo make install-daemoninit
```

## 3. Configure Web Authentication

Set up HTTP authentication for the Nagios web interface:

```bash
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
```

Enter and confirm your password, then restart Apache:

```bash
sudo systemctl restart httpd
```

## 4. Install Nagios Plugins

Download and compile the Nagios plugins:

```bash
cd ~
sudo wget -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.3/nagios-plugins-2.4.3.tar.gz
sudo tar zxf nagios-plugins.tar.gz
sudo mv nagios-plugins-2.4.3 /usr/src/nagios-plugins
cd /usr/src/nagios-plugins
sudo ./configure
sudo make
sudo make install
```

## 5. Start Nagios

Start the Nagios service and check its status:

```bash
sudo systemctl start nagios
sudo systemctl status nagios
```

Now, you can open `http://<your_server_ip>/nagios` in your browser and log in using the credentials you set (`nagiosadmin`).

## 6. Configure Nagios to Monitor a Remote Host

### Create a Host Definition

Create a new configuration file:

```bash
sudo nano /usr/local/nagios/etc/objects/remote-host.cfg
```

Add the following host definition (modify as needed):

```cfg
define host {
    use                     linux-server
    host_name               remote-host
    alias                   Remote Host
    address                 192.168.1.100
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}
```

### Define Services to Monitor

Append the following to monitor PING and SSH:

```cfg
define service {
    use                             generic-service
    host_name                       remote-host
    service_description             PING
    check_command                   check_ping!100.0,20%!500.0,60%
}

define service {
    use                             generic-service
    host_name                       remote-host
    service_description             SSH
    check_command                   check_ssh
}
```

### Include the New Configuration File

Open the Nagios configuration file:

```bash
sudo nano /usr/local/nagios/etc/nagios.cfg
```

Add this line:

```cfg
cfg_file=/usr/local/nagios/etc/objects/remote-host.cfg
```

Save and exit.

### Verify and Restart Nagios

Verify your configuration:

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

If everything is valid, restart Nagios:

```bash
sudo systemctl restart nagios
```

## 7. Verify the Setup

Open the Nagios web interface at `http://<your_server_ip>/nagios` and log in. You should see the remote host and its services listed on the dashboard.

---

🎉 **Nagios is now installed and monitoring a remote host!** Let me know if you need further configurations or troubleshooting help.


# Configuring Nagios Core to Monitor a Remote Host

This guide walks you through the steps required to configure Nagios Core to monitor a remote host. It assumes that Nagios Core is already installed and running on your Rocky Linux 8 server. Adjust IP addresses, hostnames, and settings to suit your environment.

---

## Table of Contents

1. [Create a New Configuration File for the Remote Host](#1-create-a-new-configuration-file-for-the-remote-host)
2. [Add Host and Service Definitions](#2-add-host-and-service-definitions)
3. [Include the New Configuration File in Nagios](#3-include-the-new-configuration-file-in-nagios)
4. [Verify and Restart Nagios](#4-verify-and-restart-nagios)
5. [Additional Considerations](#5-additional-considerations)

---

## 1. Create a New Configuration File for the Remote Host

It’s best practice to keep your host and service definitions modular. Create a new file for your remote host:

```bash
sudo nano /usr/local/nagios/etc/objects/remote-host.cfg
```

---

## 2. Add Host and Service Definitions

Within the newly created file, add both your host and service definitions. For example:

```cfg
#################################################################
# Host Definition for the Remote Host
#################################################################
define host {
    use                     linux-server          ; Inherit default values from a template (adjust as necessary)
    host_name               remote-host           ; Unique identifier for the host in Nagios
    alias                   Remote Host           ; Friendly display name
    address                 192.168.1.100         ; Replace with the remote host's IP address
    max_check_attempts      5                     ; Attempts before marking as DOWN
    check_period            24x7                  ; Time period during which checks are performed
    notification_interval   30                    ; Minutes between notifications
    notification_period     24x7                  ; Time period during which notifications are sent
}

#################################################################
# Service Check: PING
#################################################################
define service {
    use                             generic-service       ; Inherit default settings from a service template
    host_name                       remote-host           ; The host this service applies to
    service_description             PING                  ; Service description
    check_command                   check_ping!100.0,20%!500.0,60% ; Adjust thresholds as needed
}

#################################################################
# Service Check: SSH
#################################################################
define service {
    use                             generic-service       ; Inherit default settings for services
    host_name                       remote-host           ; The host this service applies to
    service_description             SSH                   ; Service description
    check_command                   check_ssh             ; Uses the default SSH check command defined in commands.cfg
}
```

**Explanation:**

- **Host Definition:**  
  - `use linux-server` inherits common settings from a template (adjust if needed).
  - `host_name` and `alias` must be unique.
  - `address` should be the remote host’s IP address or resolvable DNS name.

- **Service Definitions:**  
  - **PING:** Checks basic connectivity. The `check_ping` command uses thresholds that can be adjusted.
  - **SSH:** Ensures SSH availability. The command `check_ssh` should be predefined in your `commands.cfg`.

---

## 3. Include the New Configuration File in Nagios

To load your new configuration file, add an include statement in the main Nagios configuration file.

Open the main configuration file:

```bash
sudo nano /usr/local/nagios/etc/nagios.cfg
```

Add the following line at an appropriate section (if not already present):

```cfg
cfg_file=/usr/local/nagios/etc/objects/remote-host.cfg
```

Save and close the file.

---

## 4. Verify and Restart Nagios

Before restarting, verify your configuration for errors:

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

If the verification output shows **"Things look okay"** without errors, restart Nagios to apply the changes:

```bash
sudo systemctl restart nagios
```

Once restarted, open the Nagios web interface at:

```
http://<your_nagios_server_ip>/nagios
```

Log in using your credentials (e.g., `nagiosadmin`). You should now see your remote host along with its service checks (such as PING and SSH) on the dashboard.

---

## 5. Additional Considerations

- **Firewall and Network Settings:**  
  Ensure the remote host allows ICMP (for PING checks) and necessary ports (e.g., TCP port 22 for SSH). Adjust firewall rules on both the Nagios server and the remote host as needed.

- **Custom Templates:**  
  If you monitor multiple similar hosts, consider creating reusable host and service templates (commonly defined in a separate file like `templates.cfg`).

- **Extending Service Checks:**  
  You can add additional service checks (e.g., HTTP, Disk Space, CPU Load) by defining more `service` blocks and ensuring the corresponding commands are set up.

- **Logging and Debugging:**  
  If you encounter issues, check the Nagios log file at `/usr/local/nagios/var/nagios.log` or use the system journal for further diagnostics.

---

By following these steps, you will have Nagios Core configured to monitor a remote host. This setup is scalable and can be extended to monitor additional hosts and services as your environment grows.

Happy monitoring!
```

This file uses clear section headings, code blocks, and inline explanations to ensure that your Nagios configuration is easy to follow and visually engaging. Enjoy setting up your monitoring environment!
