#!/usr/bin/env bash
set -e

# ==========================================================
# Telaga OS - QEMU Live Test Runner (Auto Hardware Detection)
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_FILE="$SCRIPT_DIR/output/telaga-os-1.0-live-amd64.iso"

if [ ! -f "$ISO_FILE" ]; then
    echo "⚠️  File ISO belum ditemukan di: $ISO_FILE"
    echo "👉 Silakan bangun file ISO terlebih dahulu dengan: sudo ./build-iso.sh"
    exit 1
fi

if ! which qemu-system-x86_64 >/dev/null 2>&1; then
    echo "⚠️  QEMU belum terpasang di sistem ini."
    exit 1
fi

KVM_FLAG=""
if [ -w /dev/kvm ]; then
    KVM_FLAG="-enable-kvm"
    echo "⚡ Akselerasi Hardware: KVM Aktif (Performa Maksimal)"
else
    echo "ℹ️  Akselerasi KVM memerlukan izin grup. Menjalankan mode kompatibel..."
    echo "   (Tips: kamu bisa jalankan 'sudo chmod 666 /dev/kvm' di terminal agar KVM aktif)"
fi

echo "🌊===================================================="
echo "        MENJALANKAN TELAGA OS DI EMULATOR QEMU        "
echo "======================================================"
echo "Memori RAM  : 3 GB"
echo "Virtual CPU : 4 Cores"
echo "Grafis      : VirtIO GPU"
echo "Mouse       : USB Tablet (Mulus Tanpa Trap)"
echo "File ISO    : $ISO_FILE"
echo "------------------------------------------------------"

exec qemu-system-x86_64 \
    $KVM_FLAG \
    -m 3072 \
    -smp 4 \
    -vga virtio \
    -device virtio-balloon \
    -device intel-hda -device hda-duplex \
    -usb -device usb-tablet \
    -cdrom "$ISO_FILE" \
    -boot d
