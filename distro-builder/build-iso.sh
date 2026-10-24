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
(cd "$SRC_DESKTOP_DIR/panel" && rm -f *.o moc_* qrc_* Makefile .qmake.stash telaga-panel 2>/dev/null || true)
cp -r "$SRC_DESKTOP_DIR/"* "$CHROOT_DIR/root/telaga-src/"

if [ -d "$SRC_BRANDING_DIR/wallpapers" ]; then
    mkdir -p "$CHROOT_DIR/usr/share/backgrounds/telaga" "$CHROOT_DIR/usr/share/wallpapers"
    cp -r "$SRC_BRANDING_DIR/wallpapers/"* "$CHROOT_DIR/usr/share/backgrounds/telaga/" 2>/dev/null || true
    cp -r "$SRC_BRANDING_DIR/wallpapers/"* "$CHROOT_DIR/usr/share/wallpapers/" 2>/dev/null || true
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

# Pasang GUI Stack, Video Drivers, Audio, Firmware Hardware, dan KDE Plasma Desktop Stack
echo "📦 [C/E] Memasang KDE Plasma Desktop, Display Manager SDDM, Audio, dan Driver Hardware..."
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
    kde-plasma-desktop \
    plasma-widgets-addons \
    plasma-nm \
    plasma-pa \
    powerdevil \
    kwin-x11 \
    sddm \
    sddm-theme-breeze \
    dolphin \
    konsole \
    systemsettings \
    krunner \
    spectacle \
    ark \
    kate \
    kcalc \
    papirus-icon-theme \
    breeze-cursor-theme \
    appmenu-gtk3-module \
    appmenu-gtk2-module \
    plasma-browser-integration \
    network-manager \
    wireless-tools \
    wpasupplicant \
    htop \
    neofetch \
    zenity \
    kdialog \
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
    firefox-esr \
    xdg-utils \
    xdg-user-dirs \
    fonts-dejavu-core \
    fonts-noto-core \
    fonts-noto-color-emoji \
    firmware-linux-free || true

# Pasang firmware non-free jika repository tersedia
apt-get install -y --no-install-recommends \
    firmware-misc-nonfree \
    firmware-realtek \
    firmware-iwlwifi \
    firmware-atheros \
    intel-microcode \
    amd64-microcode 2>/dev/null || true

# Bersihkan display manager lama dan window manager lama jika ada
apt-get purge -y lightdm lightdm-gtk-greeter openbox picom dunst 2>/dev/null || true
apt-get autoremove -y --purge 2>/dev/null || true

# Pasang Binary & Script Pembantu ke Sistem
echo "⚙️  [D/E] Menyiapkan Script Installer dan Utilitas Telaga OS..."
if [ -f /root/telaga-src/session/telaga-installer ]; then
    cp /root/telaga-src/session/telaga-installer /usr/bin/telaga-installer
    chmod 755 /usr/bin/telaga-installer
fi

if [ -f /root/telaga-src/session/telaga-welcome ]; then
    cp /root/telaga-src/session/telaga-welcome /usr/bin/telaga-welcome
    chmod 755 /usr/bin/telaga-welcome
fi

mkdir -p /usr/share/applications
if [ -f /root/telaga-src/session/telaga-installer.desktop ]; then
    cp /root/telaga-src/session/telaga-installer.desktop /usr/share/applications/telaga-installer.desktop
    chmod 644 /usr/share/applications/telaga-installer.desktop
fi

if [ -f /root/telaga-src/session/telaga-welcome.desktop ]; then
    cp /root/telaga-src/session/telaga-welcome.desktop /usr/share/applications/telaga-welcome.desktop
    chmod 644 /usr/share/applications/telaga-welcome.desktop
fi

rm -rf /root/telaga-src

# Kustomisasi KDE Plasma menjadi Tampilan macOS Murni + Autologin SDDM
echo "🎨 [E/E] Mengonfigurasi KDE Plasma macOS Layout, Theming, dan SDDM Autologin..."

# A. Siapkan Grup Keamanan & User Autologin
for grp in sudo audio video netdev autologin nopasswdlogin input dialout plugdev kvm render; do
    groupadd -f -r "$grp"
done

# Buat User Live Default: "telaga"
if ! id -u telaga >/dev/null 2>&1; then
    useradd -m -s /bin/bash -u 1000 telaga
fi
usermod -aG sudo,audio,video,netdev,autologin,nopasswdlogin,input,dialout,plugdev,kvm,render telaga

# Bebas Password untuk Sesi Live (Hapus Password & Cegah Lockout)
passwd -d telaga 2>/dev/null || true
passwd -d root 2>/dev/null || true
echo "telaga:telaga" | chpasswd
echo "root:root" | chpasswd
passwd -u telaga 2>/dev/null || true
passwd -u root 2>/dev/null || true

# Passwordless sudo untuk live session
cat << 'SUDO' > /etc/sudoers.d/telaga-live
telaga ALL=(ALL) NOPASSWD: ALL
root ALL=(ALL) NOPASSWD: ALL
SUDO
chmod 0440 /etc/sudoers.d/telaga-live
chown root:root /etc/sudoers.d/telaga-live

# B. Konfigurasi SDDM Autologin (Langsung Boot ke Desktop Plasma Tanpa Layar Login)
mkdir -p /etc/sddm.conf.d
cat << 'SDDM_AUTO' > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=telaga
Session=plasma.desktop
Relogin=false
SDDM_AUTO

cat << 'SDDM_CONF' > /etc/sddm.conf
[Theme]
Current=breeze

[Autologin]
User=telaga
Session=plasma.desktop
Relogin=false
SDDM_CONF

# PAM SDDM (100% Bypass Password Prompt)
cat << 'PAM_SDDM' > /etc/pam.d/sddm-autologin
#%PAM-1.0
auth        sufficient  pam_permit.so
@include    common-account
session     required    pam_limits.so
@include    common-session
password    required    pam_permit.so
@include    common-password
PAM_SDDM

cat << 'PAM_SDDM_DEF' > /etc/pam.d/sddm
#%PAM-1.0
auth        sufficient  pam_permit.so
@include    common-auth
@include    common-account
session     required    pam_limits.so
@include    common-session
password    required    pam_permit.so
@include    common-password
PAM_SDDM_DEF

# Konfigurasi Autologin Konsol TTY1 (Cadangan Darurat jika X11 Mengalami Gangguan)
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << 'GETTY' > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin telaga --noclear %I $TERM
GETTY

# C. Kustomisasi macOS Layout Script untuk KDE Plasma (Top Bar Global Menu + Bottom Floating Dock)
mkdir -p /usr/share/plasma/shells/org.kde.plasma.desktop/contents
cat << 'LAYOUT_JS' > /usr/share/plasma/shells/org.kde.plasma.desktop/contents/layout.js
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
    desktopsArray[j].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktopsArray[j].writeConfig("Image", "file:///usr/share/backgrounds/telaga/telaga-macos.jpg");
    desktopsArray[j].writeConfig("FillMode", "2");
}

// 1. Panel Atas (macOS Top Menu Bar)
var topPanel = new Panel();
topPanel.location = "top";
topPanel.height = 28;

var kickoff = topPanel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "distributor-logo-debian");

var appmenu = topPanel.addWidget("org.kde.plasma.appmenu");

topPanel.addWidget("org.kde.plasma.panelspacer");

var systray = topPanel.addWidget("org.kde.plasma.systemtray");

var clock = topPanel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("dateFormat", "shortDate");
clock.writeConfig("showDate", true);
clock.writeConfig("use24hFormat", "2");

// 2. Dock Bawah (macOS Centered Floating Dock)
var dock = new Panel();
dock.location = "bottom";
dock.alignment = "center";
dock.height = 58;
dock.floating = true;

var icontasks = dock.addWidget("org.kde.plasma.icontasks");
icontasks.currentConfigGroup = ["General"];
icontasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:firefox-esr.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop",
    "applications:org.kde.kate.desktop",
    "applications:telaga-installer.desktop",
    "applications:telaga-welcome.desktop"
].join(","));

dock.addWidget("org.kde.plasma.trash");
LAYOUT_JS

# D. Kustomisasi Window Buttons (Traffic Light Kiri: Close, Minimize, Maximize) & Efek Blur KWin
mkdir -p /etc/xdg
cat << 'KWINRC' > /etc/xdg/kwinrc
[Compositing]
AnimationSpeed=3
Backend=OpenGL
Enabled=true
GLCore=true
GLPlatformInterface=glx
WindowsBlockCompositing=false

[Plugins]
blurEnabled=true
desktopgridEnabled=true
fadeEnabled=true
kwin4_effect_translucencyEnabled=true
presentwindowsEnabled=true
slideEnabled=true

[org.kde.kdecoration2]
BorderSize=None
ButtonsOnLeft=XIA
ButtonsOnRight=
CloseOnDoubleClickOnMenu=false
ShowToolTips=true
theme=Breeze
KWINRC

# E. Tema Gelap macOS (Breeze Dark) & Ikon Papirus-Dark
cat << 'KDEGLOBALS' > /etc/xdg/kdeglobals
[General]
ColorScheme=BreezeDark
Name=Breeze Dark
fixed=Monospace,10,-1,5,50,0,0,0,0,0
font=Noto Sans,10,-1,5,50,0,0,0,0,0
menuFont=Noto Sans,10,-1,5,50,0,0,0,0,0
smallestReadableFont=Noto Sans,8,-1,5,50,0,0,0,0,0
toolBarFont=Noto Sans,10,-1,5,50,0,0,0,0,0

[Icons]
Theme=Papirus-Dark

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
SingleClick=false
KDEGLOBALS

# F. Pintasan Keyboard macOS (Spotlight: Ctrl+Space, Mission Control: F3, Launchpad: F4, Cmd+Q, Cmd+M)
cat << 'SHORTCUTS' > /etc/xdg/kglobalshortcutsrc
[kwin]
Expose=F3,Ctrl+F9,Toggle Present Windows (Current desktop)
ExposeAll=Ctrl+F10,none,Toggle Present Windows (All desktops)
Grid=F4,Ctrl+F8,Show Desktop Grid
ShowDesktop=F11,Meta+D,Show Desktop
Window Close=Meta+Q,Alt+F4,Close Window
Window Maximize=Meta+F,Alt+F10,Maximize Window
Window Minimize=Meta+M,Alt+F9,Minimize Window

[org.kde.krunner.desktop]
_k_friendly_name=KRunner
run command=Ctrl+Space,Meta+Space,Search
SHORTCUTS

# G. Spotlight Search Melayang di Tengah Layar (KRunner Floating)
cat << 'KRUNNER' > /etc/xdg/krunnerrc
[General]
FreeFloating=true
historyEnabled=true
retainPriorSearch=false
KRUNNER

# H. Kursor & Tema Plasma
cat << 'KCMINPUT' > /etc/xdg/kcminputrc
[Mouse]
cursorTheme=breeze_cursors
cursorSize=24
KCMINPUT

cat << 'PLASMARC' > /etc/xdg/plasmarc
[Theme]
name=breeze-dark
PLASMARC

# Salin konfigurasi ke /etc/skel dan /home/telaga agar aktif seketika
mkdir -p /etc/skel/.config /home/telaga/.config
for cfg in kwinrc kdeglobals kglobalshortcutsrc krunnerrc kcminputrc plasmarc; do
    cp "/etc/xdg/$cfg" "/etc/skel/.config/$cfg"
    cp "/etc/xdg/$cfg" "/home/telaga/.config/$cfg"
done

# Pastikan tidak ada sisa plasma-org.kde.plasma.desktop-appletsrc lama agar layout.js dieksekusi bersih
rm -f /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc /home/telaga/.config/plasma-org.kde.plasma.desktop-appletsrc

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
systemctl enable sddm
systemctl enable NetworkManager
systemctl disable lightdm 2>/dev/null || true

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
    linux /live/vmlinuz boot=live components locales=en_US.UTF-8 username=telaga hostname=telaga-os quiet splash
    initrd /live/initrd
}

menuentry "🌊 Telaga OS (Failsafe Mode)" {
    linux /live/vmlinuz boot=live components locales=en_US.UTF-8 username=telaga hostname=telaga-os nomodeset xforcevesa
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
