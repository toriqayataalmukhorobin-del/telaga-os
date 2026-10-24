#!/usr/bin/env bash
set -e

# ==============================================================================
# Telaga OS - Debian Live ISO Generator
# Produces a bootable Telaga OS Live ISO (.iso) based on Debian 12 (Bookworm)
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Script pembuat ISO ini membutuhkan akses root (sudo)."
  echo "   Jalankan dengan: sudo ./build-iso.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/build_work"
CHROOT_DIR="$WORK_DIR/chroot"
IMAGE_DIR="$WORK_DIR/image"
OUTPUT_DIR="$SCRIPT_DIR/output"
PKG_DEB="$SCRIPT_DIR/packages/telaga-desktop_0.1.0_amd64.deb"
ISO_NAME="telaga-os-1.0-live-amd64.iso"

echo "🌊===================================================="
echo "          MEMULAI PEMBUATAN ISO TELAGA OS             "
echo "======================================================"

# 0. Pastikan paket .deb telaga-desktop sudah dibuat
if [ ! -f "$PKG_DEB" ]; then
    echo "⚙️  Membangun paket .deb terlebih dahulu..."
    "$SCRIPT_DIR/build-deb.sh"
fi

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 1. Siapkan direktori kerja
mkdir -p "$IMAGE_DIR/live" "$IMAGE_DIR/boot/grub" "$OUTPUT_DIR"

# 2. Debootstrap Debian Bookworm Minimal (jika belum ada)
if [ ! -f "$CHROOT_DIR/bin/bash" ]; then
    echo "📥 [1/6] Mengunduh Debian 12 Bookworm base system (debootstrap)..."
    DEBOOT_SHARE="$WORK_DIR/debootstrap_share"
    mkdir -p "$DEBOOT_SHARE"
    cp -r /usr/share/debootstrap/* "$DEBOOT_SHARE/"
    echo "amd64" > "$DEBOOT_SHARE/arch"
    export DEBOOTSTRAP_DIR="$DEBOOT_SHARE"
    debootstrap --no-check-gpg --arch=amd64 --variant=minbase bookworm "$CHROOT_DIR" http://deb.debian.org/debian/
else
    echo "♻️  [1/6] Menggunakan base system Debian yang sudah terunduh..."
fi

# 3. Mount pseudo-filesystems untuk chroot
mount --bind /dev "$CHROOT_DIR/dev"
mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
mount -t proc proc "$CHROOT_DIR/proc"
mount -t sysfs sysfs "$CHROOT_DIR/sys"

cleanup() {
    echo "🧹 Melepas mount chroot..."
    umount -lf "$CHROOT_DIR/dev/pts" 2>/dev/null || true
    umount -lf "$CHROOT_DIR/dev" 2>/dev/null || true
    umount -lf "$CHROOT_DIR/proc" 2>/dev/null || true
    umount -lf "$CHROOT_DIR/sys" 2>/dev/null || true
}
trap cleanup EXIT

# 4. Konfigurasi Sistem di dalam Chroot
echo "⚙️  [2/6] Mengonfigurasi kernel, repositori, dan desktop di dalam chroot..."

# Salin deb ke dalam chroot
cp "$PKG_DEB" "$CHROOT_DIR/root/telaga-desktop.deb"

cat << 'EOF' > "$CHROOT_DIR/setup.sh"
#!/bin/bash
set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

# Konfigurasi APT Repositories
cat << 'REPO' > /etc/apt/sources.list
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
REPO

apt-get update

# Pasang Hostname
echo "telaga-os" > /etc/hostname
cat << 'HOSTS' > /etc/hosts
127.0.0.1   localhost
127.0.1.1   telaga-os
HOSTS

# Pasang Kernel Linux dan Live Boot Core
echo "📦 Memasang Linux Kernel & Live-boot..."
apt-get install -y --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    systemd-sysv

# Pasang GUI Stack (Xorg, Drivers, Window Manager, Compositor, Fonts, Audio, & Qt6)
echo "📦 Memasang Graphic Stack, Drivers, Audio, dan Qt6..."
apt-get install -y --no-install-recommends \
    xserver-xorg-core \
    xserver-xorg \
    xserver-xorg-video-all \
    xserver-xorg-input-all \
    mesa-utils \
    libgl1-mesa-dri \
    xinit \
    x11-xserver-utils \
    dbus-x11 \
    openbox \
    picom \
    dunst \
    lightdm \
    lightdm-gtk-greeter \
    policykit-1-gnome \
    network-manager \
    network-manager-gnome \
    pulseaudio \
    pavucontrol \
    passwd \
    sudo \
    curl \
    nano \
    alacritty \
    pcmanfm \
    firefox-esr \
    xdg-utils \
    xdg-user-dirs \
    fonts-dejavu-core \
    fonts-noto-core \
    fonts-noto-color-emoji \
    libqt6core6 \
    libqt6gui6 \
    libqt6qml6 \
    libqt6quick6 \
    libqt6quickcontrols2-6 \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-templates \
    papirus-icon-theme

# Pasang Paket Telaga Desktop (.deb)
echo "🌊 Memasang Telaga Desktop Environment..."
apt-get install -y /root/telaga-desktop.deb

# Siapkan Grup Keamanan & Autologin
groupadd -r autologin 2>/dev/null || true
groupadd -r nopasswdlogin 2>/dev/null || true

# Buat User Live Default: "telaga"
echo "👤 Menyiapkan user live 'telaga'..."
if ! id -u telaga >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G sudo,audio,video,netdev,autologin,nopasswdlogin,input telaga
else
    usermod -aG sudo,audio,video,netdev,autologin,nopasswdlogin,input telaga
fi
echo "telaga:telaga" | chpasswd
echo "root:root" | chpasswd

# Passwordless sudo untuk live session (Permissions 0440 strictly enforced)
echo "telaga ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/telaga-live
chmod 0440 /etc/sudoers.d/telaga-live
chown root:root /etc/sudoers.d/telaga-live

# Konfigurasi PAM Autologin (Menjamin 100% bypass password prompt pada live boot)
cat << 'PAM' > /etc/pam.d/lightdm-autologin
#%PAM-1.0
auth      requisite pam_nologin.so
auth      required  pam_permit.so
@include common-account
session   required  pam_limits.so
session   required  pam_loginuid.so
@include common-session
password  required  pam_deny.so
@include common-password
PAM

# Konfigurasi LightDM untuk autologin ke sesi Telaga OS
mkdir -p /etc/lightdm/lightdm.conf.d
cat << 'LIGHTDM' > /etc/lightdm/lightdm.conf.d/01-telaga-autologin.conf
[Seat:*]
autologin-guest=false
autologin-user=telaga
autologin-user-timeout=0
autologin-session=telaga
user-session=telaga
greeter-session=lightdm-gtk-greeter
LIGHTDM

# Pastikan default systemd target adalah Graphical Mode
systemctl set-default graphical.target
systemctl enable lightdm
systemctl enable NetworkManager

# Generate direktori standar user (Desktop, Downloads, Documents, dll)
su - telaga -c "xdg-user-dirs-update" 2>/dev/null || true

# Bersihkan cache
apt-get clean
rm -rf /var/lib/apt/lists/* /root/telaga-desktop.deb /setup.sh
EOF

chmod +x "$CHROOT_DIR/setup.sh"
chroot "$CHROOT_DIR" /usr/bin/env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" /bin/bash /setup.sh

# 5. Salin Kernel dan Initrd ke direktori ISO
echo "🚚 [3/6] Mengambil vmlinuz dan initrd..."
VMLINUZ="$(ls -t "$CHROOT_DIR/boot/vmlinuz"* | head -n1)"
INITRD="$(ls -t "$CHROOT_DIR/boot/initrd.img"* | head -n1)"

cp "$VMLINUZ" "$IMAGE_DIR/live/vmlinuz"
cp "$INITRD" "$IMAGE_DIR/live/initrd"

# 6. Lepas mount chroot sebelum kompresi squashfs
cleanup
trap - EXIT

# 7. Buat Squashfs filesystem
echo "🗜️  [4/6] Mengompresi sistem menjadi filesystem.squashfs (XZ)..."
mksquashfs "$CHROOT_DIR" "$IMAGE_DIR/live/filesystem.squashfs" -comp xz -e boot

# 8. Konfigurasi GRUB Boot Menu
echo "📝 [5/6] Mengonfigurasi GRUB bootloader..."
cat << 'EOF' > "$IMAGE_DIR/boot/grub/grub.cfg"
set default="0"
set timeout=5

insmod efi_gop
insmod font
if loadfont /boot/grub/fonts/unicode.pf2 ; then
    insmod gfxterm
    set gfxmode=auto
    set gfxpayload=keep
    terminal_output gfxterm
fi

menuentry "🌊 Telaga OS (Live)" {
    linux /live/vmlinuz boot=live quiet splash components
    initrd /live/initrd
}

menuentry "🌊 Telaga OS (Failsafe Mode)" {
    linux /live/vmlinuz boot=live nomodeset components
    initrd /live/initrd
}
EOF

# 9. Buat ISO Hybrid Bootable menggunakan xorriso / grub-mkrescue
echo "💿 [6/6] Menghasilkan file ISO bootable..."
grub-mkrescue -o "$OUTPUT_DIR/$ISO_NAME" "$IMAGE_DIR" \
    -- -volid "TELAGA_OS"

echo "🎉===================================================="
echo "    SUKSES! ISO TELAGA OS TELAH SELESAI DIBUAT!      "
echo "======================================================"
echo "Lokasi ISO : $OUTPUT_DIR/$ISO_NAME"
ls -lh "$OUTPUT_DIR/$ISO_NAME"
echo ""
echo "💡 Kamu bisa langsung mengujinya di VirtualBox atau QEMU:"
echo "   qemu-system-x86_64 -m 2G -enable-kvm -cdrom $OUTPUT_DIR/$ISO_NAME"
