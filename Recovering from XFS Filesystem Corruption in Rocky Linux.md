Certainly! Below is a **detailed, step-by-step README** file that explains how to recover your Rocky Linux VM from the **Dracut emergency shell** due to **XFS filesystem corruption**, and how to fully repair and restore a clean boot environment.

---

# ✅ README: Recovering from XFS Filesystem Corruption in Rocky Linux

---

## 📌 Description

This guide walks you through the **complete recovery process** when your Rocky Linux VM fails to boot and drops you into the **Dracut emergency shell**, due to **XFS metadata corruption** on the root filesystem (`/dev/mapper/rl-root`).

You’ll learn to:
- Repair the XFS filesystem using `xfs_repair`
- Mount and chroot into your system
- Rebuild your GRUB configuration
- Restore a clean and graphical boot

---

## 🧨 Symptoms

You may see the following errors during boot:

```text
XFS (dm-0): metadata I/O error
XFS (dm-0): need to repair filesystem on dm-0
mount: /sysroot: cannot mount block device dm-0 read-write, or read-only: Invalid argument
Error 117 on filesystem dm-0: Structure needs cleaning
```

Later, when trying to recover:

```text
/usr/sbin/xfs_repair: command not found
mount: special device /dev/mapper/rl-root does not exist
cannot open ‘/boot/grub2/grubenv.new’: No such file or directory
```

---

## ⚠️ Root Cause

| Problem | Explanation |
|--------|-------------|
| ❌ XFS Corruption | The root filesystem is damaged and cannot be mounted |
| ❌ Minimal Shell | The initramfs (Dracut) shell lacks `xfs_repair`, LVM tools, and full mount support |
| ❌ GRUB Unusable | `/boot` and `/boot/efi` are not mounted, so GRUB can't update configs |

---

## 🧰 Requirements

- **Rocky Linux ISO** (same version as your installed OS)
- Access to the VM console or boot menu
- Basic familiarity with shell commands

---

## 🛠️ Step-by-Step Recovery Instructions

---

### 🔹 A) Boot into Rescue Mode via ISO

1. **Attach the Rocky Linux ISO** to your VM (via virtualization platform).
2. **Reboot the VM** and boot from the ISO.
3. At the boot menu, select:

   ```
   Troubleshooting → Rescue a Rocky Linux system
   ```

4. When prompted about mounting the system:
   - Choose **Skip to shell** (recommended), or allow auto-mounting (read-only).
   - You will land in a shell with most tools available.

---

### 🔹 B) Repair the XFS Root Filesystem

1. **Unmount `/mnt/sysimage`** in case it was auto-mounted:

   ```bash
   umount /mnt/sysimage 2>/dev/null || true
   ```

2. **Run the filesystem repair**:

   ```bash
   xfs_repair /dev/mapper/rl-root
   ```

3. **If you get a "dirty log" error**, force the repair with:

   ```bash
   xfs_repair -L /dev/mapper/rl-root
   ```

> ⚠️ The `-L` flag clears the log and may result in some data loss, but it's necessary if the filesystem refuses to mount.

4. **Wait** for the repair process to finish without errors.

---

### 🔹 C) Mount, Chroot, and Rebuild GRUB

---

#### 1. Mount the root filesystem:

```bash
mount /dev/mapper/rl-root /mnt/sysimage
```

---

#### 2. Bind-mount system directories:

```bash
for d in dev proc sys; do
  mount --bind /$d /mnt/sysimage/$d
done
```

---

#### 3. Chroot into your system:

```bash
chroot /mnt/sysimage /bin/bash
```

Now you're operating **inside your real system**.

---

#### 4. Mount `/boot` and EFI partitions:

Use `blkid` or `lsblk` to identify the correct devices.

Example:

- `/dev/sda2`: XFS → `/boot`
- `/dev/sda1`: VFAT → `/boot/efi`

Mount them:

```bash
mkdir -p /boot
mount /dev/sda2 /boot

mkdir -p /boot/efi
mount /dev/sda1 /boot/efi
```

---

#### 5. Edit GRUB settings (optional but recommended):

```bash
vi /etc/default/grub
```

Find the line:

```bash
GRUB_CMDLINE_LINUX="..."
```

Update it to include:

```bash
GRUB_CMDLINE_LINUX="... quiet rhgb loglevel=3"
```

- **quiet**: suppresses most kernel messages
- **rhgb**: enables graphical boot splash
- **loglevel=3**: only show warnings and errors

---

#### 6. Rebuild the GRUB configuration:

- **For BIOS systems**:

  ```bash
  grub2-mkconfig -o /boot/grub2/grub.cfg
  ```

- **For UEFI systems**:

  ```bash
  grub2-mkconfig -o /boot/efi/EFI/rocky/grub.cfg
  ```

---

#### 7. Exit and reboot:

```bash
exit
reboot
```

> 🛑 **Detach the ISO** from your VM before rebooting so it boots from the repaired disk.

---

## ✅ What This Fixes

| Fix | Result |
|-----|--------|
| 🛠️ XFS repaired | Kernel can now mount root filesystem |
| 🛠️ GRUB rebuilt | Bootloader works properly |
| 👁️ Boot parameters updated | Graphical splash screen instead of verbose logs |
| ✅ System boots normally | No more emergency shell |

---

## 🧪 Optional: Rebuild Initramfs

If you regain full access and want to ensure LVM and filesystem tools are available during boot in the future:

```bash
dracut -f --regenerate-all
```

Or for your current kernel:

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

---

## 🧠 Troubleshooting Notes

| Issue | Fix |
|-------|-----|
| `xfs_repair: command not found` | You’re still in the minimal Dracut shell. Boot from ISO. |
| `/dev/mapper/rl-root` missing | Run `lvm vgchange -ay` to activate logical volumes |
| GRUB can’t write config | Make sure `/boot` and `/boot/efi` are mounted and writable |
| Still booting to emergency shell | Re-check `/etc/fstab` for missing or incorrect entries |

---

## 📘 Summary

| Step | Description |
|------|-------------|
| Boot from ISO | Enter full rescue environment |
| Repair XFS | Use `xfs_repair` to fix metadata |
| Mount and chroot | Access your real system |
| Rebuild GRUB | Make bootloader changes persistent |
| Reboot | Boot normally into Rocky Linux |

---

## 🧩 Helpful Commands Reference

```bash
# Activate LVM volumes (if needed)
lvm vgscan
lvm vgchange -ay

# Mount devices
mount /dev/mapper/rl-root /mnt/sysimage
mount --bind /dev /mnt/sysimage/dev

# Enter system
chroot /mnt/sysimage /bin/bash

# Repair filesystem
xfs_repair /dev/mapper/rl-root
xfs_repair -L /dev/mapper/rl-root

# Rebuild GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg   # BIOS
grub2-mkconfig -o /boot/efi/EFI/rocky/grub.cfg  # UEFI
```

---

