#!/usr/bin/env bash
set -e

# ==============================================================================
# Telaga OS - Debian Live ISO Generator (Hardened High-Stability Edition)
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
ISO_NAME="telaga-os-1.0-live-amd64.iso"
SRC_DESKTOP_DIR="$SCRIPT_DIR/../desktop"
SRC_BRANDING_DIR="$SCRIPT_DIR/../branding"

echo "🌊===================================================="
echo "      MEMULAI PEMBUATAN ISO TELAGA OS (STABIL)        "
echo "======================================================"

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

# Pastikan DNS resolver tersedia di dalam chroot
mkdir -p "$CHROOT_DIR/etc"
cp -L /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf" 2>/dev/null || echo "nameserver 1.1.1.1" > "$CHROOT_DIR/etc/resolv.conf"

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

# 4. Salin source code desktop ke dalam chroot untuk kompilasi native Debian 12
echo "📦 Menyalin source code Telaga Desktop ke dalam chroot..."
rm -rf "$CHROOT_DIR/root/telaga-src"
mkdir -p "$CHROOT_DIR/root/telaga-src"
cp -r "$SRC_DESKTOP_DIR/"* "$CHROOT_DIR/root/telaga-src/"

if [ -d "$SRC_BRANDING_DIR/wallpapers" ]; then
    mkdir -p "$CHROOT_DIR/usr/share/backgrounds/telaga"
    cp -r "$SRC_BRANDING_DIR/wallpapers/"* "$CHROOT_DIR/usr/share/backgrounds/telaga/" 2>/dev/null || true
fi

# 5. Konfigurasi Sistem di dalam Chroot
echo "⚙️  [2/6] Mengonfigurasi kernel, driver, autologin, dan desktop di dalam chroot..."

cat << 'EOF' > "$CHROOT_DIR/setup.sh"
#!/bin/bash
set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

# Konfigurasi APT Repositories Resmi Debian 12
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
echo "📦 [A/E] Memasang Linux Kernel & Live-boot..."
apt-get install -y --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    systemd-sysv

# Pasang Locales & Konfigurasi UTF-8 Baku
echo "🌐 [B/E] Menyiapkan Locales UTF-8..."
apt-get install -y --no-install-recommends locales
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "id_ID.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Pasang GUI Stack, Video Drivers, Audio, Firmware Hardware, dan Qt6 Runtime
echo "📦 [C/E] Memasang Driver Display, Audio, Compositor, Firmware, dan Qt6 Runtime..."
apt-get install -y --no-install-recommends \
    xserver-xorg-core \
    xserver-xorg \
    xserver-xorg-video-all \
    xserver-xorg-video-fbdev \
    xserver-xorg-video-vesa \
    xserver-xorg-video-qxl \
    xserver-xorg-video-vmware \
    xserver-xorg-input-all \
    xserver-xorg-input-libinput \
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
    wireless-tools \
    wpasupplicant \
    pulseaudio \
    pavucontrol \
    arandr \
    lxappearance \
    mousepad \
    htop \
    neofetch \
    zenity \
    gparted \
    parted \
    dosfstools \
    e2fsprogs \
    efibootmgr \
    grub-efi-amd64-bin \
    grub-pc-bin \
    rsync \
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
    qml6-module-qtquick-window \
    papirus-icon-theme \
    firmware-linux-free || true

# Pasang firmware non-free jika repository tersedia
apt-get install -y --no-install-recommends \
    firmware-misc-nonfree \
    firmware-realtek \
    firmware-iwlwifi \
    firmware-atheros \
    intel-microcode \
    amd64-microcode 2>/dev/null || true

# Kompilasi Native Telaga Panel Langsung di Lingkungan Debian 12
echo "⚙️  [D/E] Mengompilasi Native telaga-panel di Debian 12 (Bebas ABI mismatch)..."
apt-get install -y --no-install-recommends \
    build-essential \
    qt6-base-dev \
    qt6-declarative-dev

cd /root/telaga-src/panel
make clean 2>/dev/null || true
qmake6 panel.pro
make -j"$(nproc)"

# Pasang Binary & Script Sesi ke Sistem
cp /root/telaga-src/panel/telaga-panel /usr/bin/telaga-panel
chmod 755 /usr/bin/telaga-panel

cp /root/telaga-src/session/telaga-session /usr/bin/telaga-session
chmod 755 /usr/bin/telaga-session

if [ -f /root/telaga-src/session/telaga-installer ]; then
    cp /root/telaga-src/session/telaga-installer /usr/bin/telaga-installer
    chmod 755 /usr/bin/telaga-installer
fi

if [ -f /root/telaga-src/session/telaga-welcome ]; then
    cp /root/telaga-src/session/telaga-welcome /usr/bin/telaga-welcome
    chmod 755 /usr/bin/telaga-welcome
fi

cp /root/telaga-src/session/telaga.desktop /usr/share/xsessions/telaga.desktop
chmod 644 /usr/share/xsessions/telaga.desktop

mkdir -p /usr/share/applications
if [ -f /root/telaga-src/session/telaga-installer.desktop ]; then
    cp /root/telaga-src/session/telaga-installer.desktop /usr/share/applications/telaga-installer.desktop
    chmod 644 /usr/share/applications/telaga-installer.desktop
fi

if [ -f /root/telaga-src/session/telaga-welcome.desktop ]; then
    cp /root/telaga-src/session/telaga-welcome.desktop /usr/share/applications/telaga-welcome.desktop
    chmod 644 /usr/share/applications/telaga-welcome.desktop
fi

mkdir -p /usr/share/telaga /etc/xdg/openbox
if [ -f /root/telaga-src/session/openbox-rc.xml ]; then
    cp /root/telaga-src/session/openbox-rc.xml /etc/xdg/openbox/telaga-rc.xml
    cp /root/telaga-src/session/openbox-rc.xml /usr/share/telaga/openbox-rc.xml
    chmod 644 /etc/xdg/openbox/telaga-rc.xml
    chmod 644 /usr/share/telaga/openbox-rc.xml
fi

# Bersihkan build tools agar ukuran ISO tetap ramping
apt-get purge -y build-essential qt6-base-dev qt6-declarative-dev
apt-get autoremove -y --purge
rm -rf /root/telaga-src

# Siapkan Grup Keamanan & User Autologin
echo "👤 [E/E] Mengonfigurasi Akun Pengguna, PAM, dan LightDM Autologin..."
for grp in sudo audio video netdev autologin nopasswdlogin input dialout plugdev kvm render; do
    groupadd -f -r "$grp"
done

# Buat User Live Default: "telaga"
if ! id -u telaga >/dev/null 2>&1; then
    useradd -m -s /bin/bash -u 1000 telaga
fi
usermod -aG sudo,audio,video,netdev,autologin,nopasswdlogin,input,dialout,plugdev,kvm,render telaga

# Tetapkan Password & Buka Kunci Akun (100% Bebas Lockout)
echo "telaga:telaga" | chpasswd
passwd -u telaga 2>/dev/null || true
echo "root:root" | chpasswd
passwd -u root 2>/dev/null || true

# Passwordless sudo untuk live session
cat << 'SUDO' > /etc/sudoers.d/telaga-live
telaga ALL=(ALL) NOPASSWD: ALL
root ALL=(ALL) NOPASSWD: ALL
SUDO
chmod 0440 /etc/sudoers.d/telaga-live
chown root:root /etc/sudoers.d/telaga-live

# Konfigurasi PAM Autologin (Mengizinkan autologin tanpa hambatan password)
cat << 'PAM' > /etc/pam.d/lightdm-autologin
#%PAM-1.0
auth      requisite pam_nologin.so
auth      sufficient pam_succeed_if.so user = telaga
auth      sufficient pam_permit.so
@include common-account
session   required  pam_limits.so
session   required  pam_loginuid.so
@include common-session
password  required  pam_deny.so
@include common-password
PAM

# Konfigurasi LightDM untuk autologin langsung ke sesi Telaga OS
mkdir -p /etc/lightdm/lightdm.conf.d
cat << 'LIGHTDM' > /etc/lightdm/lightdm.conf.d/01-telaga.conf
[Seat:*]
autologin-guest=false
autologin-user=telaga
autologin-user-timeout=0
autologin-session=telaga
user-session=telaga
greeter-session=lightdm-gtk-greeter
greeter-hide-users=false
allow-user-switching=true
xserver-command=X -core -noreset
LIGHTDM

# Konfigurasi LightDM GTK Greeter
cat << 'GREETER' > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
theme-name=Adwaita-dark
icon-theme-name=Papirus-Dark
font-name=Sans 11
background=#061524
default-user-image=#apple
screensaver-timeout=0
user-background=false
GREETER

# Siapkan sesi default di .dmrc dan Openbox untuk user telaga
mkdir -p /home/telaga/.config/openbox /etc/skel/.config/openbox
cat << 'DMRC' > /home/telaga/.dmrc
[Desktop]
Session=telaga
DMRC
cp /home/telaga/.dmrc /etc/skel/.dmrc

if [ -f /usr/share/telaga/openbox-rc.xml ]; then
    cp /usr/share/telaga/openbox-rc.xml /home/telaga/.config/openbox/rc.xml
    cp /usr/share/telaga/openbox-rc.xml /etc/skel/.config/openbox/rc.xml
fi

for dir in Desktop Documents Downloads Music Pictures Videos; do
    mkdir -p "/home/telaga/$dir" "/etc/skel/$dir"
done

# Pasang pintasan installer dan welcome di Desktop user
if [ -f /usr/share/applications/telaga-installer.desktop ]; then
    cp /usr/share/applications/telaga-installer.desktop /home/telaga/Desktop/
    cp /usr/share/applications/telaga-installer.desktop /etc/skel/Desktop/
fi
if [ -f /usr/share/applications/telaga-welcome.desktop ]; then
    cp /usr/share/applications/telaga-welcome.desktop /home/telaga/Desktop/
    cp /usr/share/applications/telaga-welcome.desktop /etc/skel/Desktop/
fi
chmod +x /home/telaga/Desktop/*.desktop /etc/skel/Desktop/*.desktop 2>/dev/null || true

chown -R telaga:telaga /home/telaga
chmod 755 /home/telaga

# Aktifkan service systemd
systemctl set-default graphical.target
systemctl enable lightdm
systemctl enable NetworkManager

# Perbarui Initramfs agar hook live-boot 100% terpasang
echo "🔄 Memperbarui initramfs dengan hook live-boot..."
update-initramfs -u -k all

# Bersihkan cache paket
apt-get clean
rm -rf /var/lib/apt/lists/* /setup.sh
EOF

chmod +x "$CHROOT_DIR/setup.sh"
chroot "$CHROOT_DIR" /usr/bin/env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" /bin/bash /setup.sh

# 6. Salin Kernel dan Initrd yang telah terbarui ke direktori ISO
echo "🚚 [3/6] Mengambil kernel vmlinuz dan initrd..."
VMLINUZ="$(ls -t "$CHROOT_DIR/boot/vmlinuz"* | head -n1)"
INITRD="$(ls -t "$CHROOT_DIR/boot/initrd.img"* | head -n1)"

cp "$VMLINUZ" "$IMAGE_DIR/live/vmlinuz"
cp "$INITRD" "$IMAGE_DIR/live/initrd"

# 7. Lepas mount chroot sebelum kompresi squashfs
cleanup
trap - EXIT

# 8. Buat Squashfs filesystem (bersihkan squashfs lama terlebih dahulu)
echo "🗜️  [4/6] Mengompresi sistem menjadi filesystem.squashfs (XZ)..."
rm -f "$IMAGE_DIR/live/filesystem.squashfs"
mksquashfs "$CHROOT_DIR" "$IMAGE_DIR/live/filesystem.squashfs" -comp xz -noappend -e boot

# 9. Konfigurasi GRUB Boot Menu
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
    linux /live/vmlinuz boot=live components locales=en_US.UTF-8 quiet splash
    initrd /live/initrd
}

menuentry "🌊 Telaga OS (Failsafe Mode)" {
    linux /live/vmlinuz boot=live components locales=en_US.UTF-8 nomodeset xforcevesa
    initrd /live/initrd
}
EOF

# 10. Buat ISO Hybrid Bootable menggunakan xorriso / grub-mkrescue
echo "💿 [6/6] Menghasilkan file ISO bootable..."
grub-mkrescue -o "$OUTPUT_DIR/$ISO_NAME" "$IMAGE_DIR" \
    -- -volid "TELAGA_OS"

echo "🎉===================================================="
echo "    SUKSES! ISO TELAGA OS TELAH SELESAI DIBUAT!      "
echo "======================================================"
echo "Lokasi ISO : $OUTPUT_DIR/$ISO_NAME"
ls -lh "$OUTPUT_DIR/$ISO_NAME"
echo ""
echo "💡 Jalankan pengujian ISO di emulator QEMU dengan:"
echo "   ./distro-builder/run-live.sh"
