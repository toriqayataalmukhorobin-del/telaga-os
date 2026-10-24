#!/usr/bin/env bash
set -e

# ==========================================================
# Telaga OS - Universal Debian Package Generator (.deb)
# (Uses standard ar + tar so it runs on ANY Linux distro)
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_DIR="$SCRIPT_DIR/../desktop/panel"
SESSION_DIR="$SCRIPT_DIR/../desktop/session"
BRANDING_DIR="$SCRIPT_DIR/../branding"
OUTPUT_DIR="$SCRIPT_DIR/packages"
PKG_NAME="telaga-desktop"
PKG_VERSION="1.0.0"
PKG_ARCH="amd64"
STAGE_DIR="/tmp/${PKG_NAME}_staging_$$"

echo "🌊 [Telaga OS] Generating Debian Package: ${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.deb"

# 1. Compile native binary
echo "⚙️  Compiling telaga-panel binary with Qt6..."
cd "$PANEL_DIR"
qmake6 panel.pro
make -j"$(nproc)"

# 2. Prepare staging structure
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"/DEBIAN
mkdir -p "$STAGE_DIR"/usr/bin
mkdir -p "$STAGE_DIR"/usr/share/xsessions
mkdir -p "$STAGE_DIR"/usr/share/telaga
mkdir -p "$STAGE_DIR"/etc/xdg/openbox
mkdir -p "$STAGE_DIR"/usr/share/backgrounds/telaga
mkdir -p "$OUTPUT_DIR"

# 3. Create DEBIAN/control file with all required runtime dependencies
cat << EOF > "$STAGE_DIR/DEBIAN/control"
Package: ${PKG_NAME}
Version: ${PKG_VERSION}
Section: x11
Priority: optional
Architecture: ${PKG_ARCH}
Depends: libc6, libqt6core6, libqt6gui6, libqt6qml6, libqt6quick6, libqt6quickcontrols2-6, qml6-module-qtquick, qml6-module-qtquick-controls, qml6-module-qtquick-layouts, qml6-module-qtquick-templates, openbox, picom, dunst, policykit-1-gnome, x11-xserver-utils, dbus-x11, xdg-utils, papirus-icon-theme
Recommends: alacritty, pcmanfm, firefox-esr, network-manager-gnome, pavucontrol, fonts-noto-color-emoji
Maintainer: Silent Wolf <developer@telaga-os.org>
Description: Telaga OS Native Desktop Environment
 A fluid, high-stability macOS Sonoma & Sequoia inspired desktop environment
 for Telaga OS powered by Debian 12 Bookworm, native C++17, and Qt6 Quick / QML.
EOF

# 4. Create DEBIAN/postinst script
cat << 'EOF' > "$STAGE_DIR/DEBIAN/postinst"
#!/bin/sh
set -e

if [ "$1" = "configure" ]; then
    # Register as alternative x-session-manager
    update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/telaga-session 60
    
    # If openbox rc.xml doesn't exist, place telaga-rc.xml
    if [ ! -f /etc/xdg/openbox/rc.xml ] && [ -f /etc/xdg/openbox/telaga-rc.xml ]; then
        cp /etc/xdg/openbox/telaga-rc.xml /etc/xdg/openbox/rc.xml
    fi
fi

exit 0
EOF
chmod 755 "$STAGE_DIR/DEBIAN/postinst"

# 5. Copy files to payload
cp "$PANEL_DIR/telaga-panel" "$STAGE_DIR/usr/bin/"
chmod 755 "$STAGE_DIR/usr/bin/telaga-panel"

cp "$SESSION_DIR/telaga-session" "$STAGE_DIR/usr/bin/"
chmod 755 "$STAGE_DIR/usr/bin/telaga-session"

cp "$SESSION_DIR/telaga.desktop" "$STAGE_DIR/usr/share/xsessions/"
chmod 644 "$STAGE_DIR/usr/share/xsessions/telaga.desktop"

if [ -f "$SESSION_DIR/openbox-rc.xml" ]; then
    cp "$SESSION_DIR/openbox-rc.xml" "$STAGE_DIR/etc/xdg/openbox/telaga-rc.xml"
    cp "$SESSION_DIR/openbox-rc.xml" "$STAGE_DIR/usr/share/telaga/openbox-rc.xml"
    chmod 644 "$STAGE_DIR/etc/xdg/openbox/telaga-rc.xml"
    chmod 644 "$STAGE_DIR/usr/share/telaga/openbox-rc.xml"
fi

if [ -d "$BRANDING_DIR/wallpapers" ]; then
    cp -r "$BRANDING_DIR/wallpapers/"* "$STAGE_DIR/usr/share/backgrounds/telaga/" 2>/dev/null || true
fi

# 6. Pack as standard Debian package archive
BUILD_TMP="/tmp/deb_build_$$"
mkdir -p "$BUILD_TMP"

echo "2.0" > "$BUILD_TMP/debian-binary"
tar --numeric-owner --group=0 --owner=0 -czf "$BUILD_TMP/control.tar.gz" -C "$STAGE_DIR/DEBIAN" .
tar --numeric-owner --group=0 --owner=0 -czf "$BUILD_TMP/data.tar.gz" -C "$STAGE_DIR" --exclude='./DEBIAN' .

DEB_FILE="$OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.deb"
ar rcs "$DEB_FILE" "$BUILD_TMP/debian-binary" "$BUILD_TMP/control.tar.gz" "$BUILD_TMP/data.tar.gz"

# Also maintain 0.1.0 symlink/copy for backward compatibility with existing build scripts
cp "$DEB_FILE" "$OUTPUT_DIR/${PKG_NAME}_0.1.0_${PKG_ARCH}.deb"

# Clean up
rm -rf "$STAGE_DIR" "$BUILD_TMP"

echo "✅ Debian package generated successfully!"
echo "📦 Output: $DEB_FILE"
ls -lh "$DEB_FILE"
