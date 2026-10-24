# Telaga OS

![Telaga OS](https://img.shields.io/badge/Telaga%20OS-v1.0-blue?style=for-the-badge)
![Debian 12](https://img.shields.io/badge/Base-Debian%2012%20Bookworm-D70A53?style=for-the-badge&logo=debian&logoColor=white)
![Qt 6](https://img.shields.io/badge/UI-Qt%206%20%2F%20QML-41CD52?style=for-the-badge&logo=qt&logoColor=white)
![C++17](https://img.shields.io/badge/Core-C%2B%2B17-00599C?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-x86__64-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-GPL--3.0-green?style=for-the-badge)

Telaga OS adalah proyek desktop Linux berbasis Debian yang mengadaptasi tampilan dan beberapa pola interaksi macOS untuk PC biasa. Proyek ini menggunakan Qt 6, QML, dan C++17 untuk membangun antarmuka desktopnya.

> **Status proyek:** beberapa bagian masih dalam pengembangan. Ketersediaan fitur dan keberhasilan proses build perlu diuji pada versi kode yang digunakan.

## Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur](#fitur)
- [Teknologi](#teknologi)
- [Struktur Repositori](#struktur-repositori)
- [Persiapan Lingkungan](#persiapan-lingkungan)
- [Build dan Menjalankan Desktop](#build-dan-menjalankan-desktop)
- [Membuat Paket Debian](#membuat-paket-debian)
- [Membangun Live ISO](#membangun-live-iso)
- [Menjalankan ISO dengan QEMU](#menjalankan-iso-dengan-qemu)
- [Pintasan Keyboard](#pintasan-keyboard)
- [Rencana Pengembangan](#rencana-pengembangan)
- [Kontribusi](#kontribusi)
- [Lisensi](#lisensi)

## Tentang Proyek

**Telaga OS** dikembangkan sebagai lingkungan desktop Linux dengan tampilan yang terinspirasi dari macOS Sonoma dan Sequoia. Tujuannya adalah menghadirkan pengalaman desktop yang konsisten di komputer berbasis PC, tanpa harus menggunakan perangkat Apple.

Antarmuka desktop dibuat menggunakan **Qt 6 Quick/QML** dengan bagian backend yang ditulis dalam **C++17**. Untuk pengelolaan jendela dan efek komposit, proyek ini menggunakan Openbox dan Picom di atas sistem Debian 12.

Telaga OS bukan macOS dan tidak menyertakan sistem operasi Apple. Proyek ini menggunakan Linux sebagai basisnya, sementara desain antarmukanya mengambil inspirasi dari beberapa elemen visual macOS.

## Fitur

Berikut adalah fitur yang ditargetkan atau disediakan oleh shell desktop Telaga OS. Pastikan setiap fitur telah diuji pada build yang digunakan sebelum menganggapnya siap dipakai.

| Fitur | Keterangan |
| --- | --- |
| **Dock dengan efek magnifikasi** | Ikon di Dock membesar saat penunjuk mouse bergerak melewatinya. |
| **Animasi minimize** | Jendela dapat dianimasikan menuju ikon Dock saat diminimalkan, jika integrasi animasinya aktif. |
| **Animasi peluncuran aplikasi** | Ikon aplikasi dapat menampilkan animasi ketika aplikasi dibuka. |
| **Mission Control** | Tampilan ringkas untuk melihat dan berpindah di antara jendela yang terbuka. |
| **Pencarian aplikasi** | Launcher di tengah layar untuk mencari dan membuka aplikasi. |
| **Control Center** | Panel akses cepat untuk pengaturan seperti volume, kecerahan, dan jaringan, sesuai dukungan sistem. |
| **Widget dan notifikasi** | Panel samping untuk menampilkan widget atau informasi yang disediakan desktop. |
| **Kontrol jendela** | Tombol tutup, minimalkan, dan maksimalkan dengan tata letak yang terinspirasi dari macOS. |
| **Ikon dan efek transparansi** | Gaya ikon membulat, bayangan, serta transparansi untuk menyatukan tampilan desktop. |

## Teknologi

| Bagian | Teknologi |
| --- | --- |
| Sistem dasar | Debian 12 (Bookworm), amd64 |
| Bahasa | C++17 |
| Antarmuka | Qt 6, QML, Qt Quick Controls |
| Window manager | Openbox |
| Compositor | Picom |
| Display manager | LightDM |
| Browser bawaan | Firefox ESR |
| Terminal | Alacritty |
| File manager | PCManFM |

Akselerasi grafis dan kelancaran animasi bergantung pada GPU, driver, compositor, serta konfigurasi komputer. Karena itu, angka performa tertentu tidak dicantumkan tanpa hasil pengujian yang dapat diulang.

## Struktur Repositori

```text
telaga-os/
├── desktop/
│   ├── panel/
│   │   ├── qml/
│   │   │   ├── components/
│   │   │   ├── LauncherMenu.qml
│   │   │   └── MainPanel.qml
│   │   ├── src/
│   │   ├── panel.pro
│   │   └── resources.qrc
│   └── session/
│       ├── telaga-session
│       └── telaga.desktop
├── distro-builder/
│   ├── build-deb.sh
│   ├── build-iso.sh
│   └── run-live.sh
├── branding/
│   └── wallpapers/
├── .gitignore
└── README.md
```

Nama dan lokasi berkas di atas mengikuti struktur yang direncanakan untuk repositori. Jika susunan kode berubah, perbarui bagian ini agar sesuai dengan isi repositori sebenarnya.

## Persiapan Lingkungan

Langkah berikut ditujukan untuk Debian atau Ubuntu. Paket yang tersedia bisa berbeda tergantung versi distribusi dan repositori yang digunakan.

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    qt6-base-dev \
    qt6-declarative-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-templates \
    openbox \
    picom \
    alacritty \
    pcmanfm \
    papirus-icon-theme
```

## Build dan Menjalankan Desktop

Masuk ke direktori panel, lalu jalankan `qmake6` dan `make`:

```bash
cd desktop/panel
qmake6 panel.pro
make -j"$(nproc)"
```

Jika proses build berhasil dan menghasilkan executable `telaga-panel`, jalankan dengan:

```bash
./telaga-panel
```

Perintah ini menjalankan aplikasi desktop di sesi yang sedang aktif. Hasilnya bisa berbeda menurut konfigurasi Qt, modul QML yang terpasang, dan lingkungan desktop. Jika build gagal, periksa pesan error untuk mengetahui dependensi atau modul yang belum tersedia.

## Membuat Paket Debian

Repositori menyediakan skrip `build-deb.sh` untuk proses packaging. Jalankan:

```bash
chmod +x distro-builder/build-deb.sh
./distro-builder/build-deb.sh
```

Periksa keluaran skrip untuk mengetahui lokasi paket `.deb` yang dihasilkan. Lokasi dan nama paket dapat berbeda jika konfigurasi skrip diubah.

## Membangun Live ISO

Pembuatan ISO memerlukan sejumlah utilitas tambahan. Pada Debian atau Ubuntu, paket yang umum diperlukan antara lain:

```bash
sudo apt install -y \
    debootstrap \
    xorriso \
    isolinux \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    squashfs-tools
```

Setelah dependensi terpasang, jalankan skrip pembuat ISO:

```bash
chmod +x distro-builder/build-iso.sh
sudo ./distro-builder/build-iso.sh
```

Skrip ini dimaksudkan untuk menyiapkan sistem Debian minimal, memasang komponen desktop Telaga OS, lalu menyusun image ISO yang dapat diuji melalui mesin virtual atau media boot. Keberhasilan build bergantung pada isi skrip, dependensi, koneksi internet, dan konfigurasi BIOS/UEFI. Tinjau skrip sebelum menjalankannya dengan hak akses root.

## Menjalankan ISO dengan QEMU

Untuk mencoba ISO melalui skrip yang tersedia:

```bash
chmod +x distro-builder/run-live.sh
./distro-builder/run-live.sh
```

Pastikan ISO hasil build berada di lokasi yang diharapkan oleh skrip. Ketersediaan akselerasi KVM bergantung pada dukungan perangkat keras dan konfigurasi host.

Jika konfigurasi sesi Live menggunakan akun default, periksa kredensial yang ditetapkan di skrip atau konfigurasi image sebelum digunakan. Jangan memakai kata sandi bawaan untuk instalasi yang terhubung ke jaringan atau digunakan di luar lingkungan pengujian.

## Pintasan Keyboard

Pintasan berikut merupakan pemetaan yang direncanakan. Perilakunya bergantung pada implementasi dan konfigurasi yang aktif.

| Pintasan | Fungsi |
| --- | --- |
| `Ctrl + Space` | Membuka atau menutup pencarian aplikasi |
| `F3` | Membuka tampilan Mission Control |
| `F11` | Beralih antara mode layar penuh dan tampilan berjendela, jika didukung |
| `Ctrl + Cmd + Q` | Pintasan penguncian sesi yang direncanakan; pastikan kombinasi tombol dan dukungannya sudah dikonfigurasi |
| Klik logo Telaga di kiri atas | Membuka menu sistem |
| Klik jam dan tanggal di kanan atas | Membuka panel widget atau notifikasi |
| Klik ikon Control Center | Membuka panel pengaturan cepat |
| Klik tombol minimalkan | Meminimalkan jendela |
| Klik ikon aplikasi di Dock | Membuka aplikasi atau mengembalikan jendelanya |

Catatan: `Cmd` adalah istilah yang umum dipakai pada keyboard Apple. Pada keyboard PC, tombol yang sesuai mungkin perlu dipetakan ke `Super`, `Meta`, atau kombinasi lain sesuai konfigurasi.

## Rencana Pengembangan

- [x] Shell desktop berbasis C++ dan Qt 6/QML.
- [x] Efek magnifikasi Dock.
- [x] Animasi minimize dan peluncuran aplikasi, sesuai implementasi yang tersedia.
- [ ] Otomatisasi build paket Debian (`.deb`).
- [ ] Otomatisasi pembuatan Live ISO Debian 12 untuk BIOS dan UEFI.
- [ ] Dukungan compositor Wayland.
- [ ] Integrasi menu aplikasi global melalui D-Bus.
- [ ] Tema terang/gelap yang dapat berubah otomatis.
- [ ] Integrasi installer grafis, misalnya Calamares.

Status pada daftar ini sebaiknya diperbarui berdasarkan pengujian pada repositori. Tandai fitur sebagai selesai hanya jika implementasinya sudah tersedia dan dapat dijalankan.

## Kontribusi

Masukan, laporan bug, dan kontribusi kode sangat terbuka. Untuk mengusulkan perubahan, alur kerja Git yang umum digunakan adalah:

1. Buat branch baru untuk perubahan.
   ```bash
   git checkout -b feature/nama-fitur
   ```
2. Lakukan perubahan dan uji bagian yang terdampak.
3. Commit perubahan.
   ```bash
   git add .
   git commit -m "Menambahkan nama fitur"
   ```
4. Push branch ke repositori.
   ```bash
   git push origin feature/nama-fitur
   ```
5. Ajukan Pull Request dan jelaskan perubahan serta hasil pengujiannya.

## Lisensi

Telaga OS menggunakan lisensi **GNU General Public License v3.0 (GPL-3.0)**, sesuai deklarasi proyek. Pastikan berkas lisensi dan lisensi dependensi disertakan dengan benar di repositori.

Tampilan Telaga OS terinspirasi oleh beberapa elemen antarmuka macOS. macOS dan merek Apple merupakan milik pemegang hak masing-masing; Telaga OS adalah proyek terpisah dan bukan produk resmi Apple.
