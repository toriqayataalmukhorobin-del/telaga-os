#!/usr/bin/env bash
set -e

# ==========================================================
# Telaga OS - Universal Debian Package Generator (.deb)
# (Uses standard ar + tar so it runs on ANY Linux distro)
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_DIR="$SCRIPT_DIR/../desktop/panel"
SESSION_DIR="$SCRIPT_DIR/../desktop/session"
OUTPUT_DIR="$SCRIPT_DIR/packages"
PKG_NAME="telaga-desktop"
PKG_VERSION="0.1.0"
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
mkdir -p "$OUTPUT_DIR"

# 3. Create DEBIAN/control file
cat << EOF > "$STAGE_DIR/DEBIAN/control"
Package: ${PKG_NAME}
Version: ${PKG_VERSION}
Section: x11
Priority: optional
Architecture: ${PKG_ARCH}
Depends: libc6, libqt6core6, libqt6gui6, libqt6qml6, libqt6quick6, libqt6quickcontrols2-6, openbox, picom
Maintainer: Silent Wolf <developer@telaga-os.org>
Description: Telaga OS Desktop Environment
 A modern, lightweight, and fluid desktop environment for Telaga OS
 powered by Debian, C++, and Qt6 QML.
EOF

# 4. Copy files to payload
cp "$PANEL_DIR/telaga-panel" "$STAGE_DIR/usr/bin/"
chmod 755 "$STAGE_DIR/usr/bin/telaga-panel"

cp "$SESSION_DIR/telaga-session" "$STAGE_DIR/usr/bin/"
chmod 755 "$STAGE_DIR/usr/bin/telaga-session"

cp "$SESSION_DIR/telaga.desktop" "$STAGE_DIR/usr/share/xsessions/"
chmod 644 "$STAGE_DIR/usr/share/xsessions/telaga.desktop"

# 5. Pack as standard Debian package archive
BUILD_TMP="/tmp/deb_build_$$"
mkdir -p "$BUILD_TMP"

echo "2.0" > "$BUILD_TMP/debian-binary"
tar --numeric-owner --group=0 --owner=0 -czf "$BUILD_TMP/control.tar.gz" -C "$STAGE_DIR/DEBIAN" .
tar --numeric-owner --group=0 --owner=0 -czf "$BUILD_TMP/data.tar.gz" -C "$STAGE_DIR" --exclude='./DEBIAN' .

DEB_FILE="$OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.deb"
ar rcs "$DEB_FILE" "$BUILD_TMP/debian-binary" "$BUILD_TMP/control.tar.gz" "$BUILD_TMP/data.tar.gz"

# Clean up
rm -rf "$STAGE_DIR" "$BUILD_TMP"

echo "✅ Debian package generated successfully!"
echo "📦 Output: $DEB_FILE"
ls -lh "$DEB_FILE"
