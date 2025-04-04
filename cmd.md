1)For systems using NetworkManager (common in many modern distributions like Ubuntu, Fedora, and CentOS):
```bash
sudo systemctl restart NetworkManager
```
On many Red Hat–based systems (such as RHEL, CentOS, or Fedora), network interface settings are stored in files located in the **/etc/sysconfig/network-scripts/** directory. These files are usually named **ifcfg-<interface_name>** (for example, **ifcfg-eth0** or **ifcfg-enp3s0**).

Below is an example of a static IP configuration file (e.g., ifcfg-eth0):

```bash
DEVICE=eth0
BOOTPROTO=static
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
ONBOOT=yes
```

**Explanation of the options:**

- **DEVICE:** The name of the network interface.
- **BOOTPROTO:** How the IP address is obtained. Use **static** for a manually configured IP, or **dhcp** for dynamic assignment.
- **IPADDR:** The static IP address assigned to the interface.
- **NETMASK:** The network mask.
- **GATEWAY:** The default gateway.
- **ONBOOT:** Indicates whether the interface should be activated during boot.

If you are using DHCP instead, your file might look like this:

```bash
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
```

After editing these files, restart the networking service to apply your changes. For example:

```bash
sudo systemctl restart network
```

Remember to replace **eth0** with your actual interface name if it differs.
