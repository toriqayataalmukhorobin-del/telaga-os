# 🌊 Telaga OS

![Telaga OS](https://img.shields.io/badge/Telaga%20OS-v1.0-blue?style=for-the-badge)
![Debian 12](https://img.shields.io/badge/Base-Debian%2012-D70A53?style=for-the-badge&logo=debian&logoColor=white)
![Qt 6](https://img.shields.io/badge/UI-Qt%206%20%2F%20QML-41CD52?style=for-the-badge&logo=qt&logoColor=white)
![C++17](https://img.shields.io/badge/Core-C%2B%2B17-00599C?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![License](https://img.shields.io/badge/License-GPL--3.0-green?style=for-the-badge)

**A Linux desktop project inspired by macOS, built with Qt 6, QML, and C++17.**

**Proyek desktop Linux yang terinspirasi dari macOS, dibangun menggunakan Qt 6, QML, dan C++17.**

[English](#english) · [Bahasa Indonesia](#bahasa-indonesia) · [Contributing](#contributing--kontribusi)

---

<a id="english"></a>

# 🇬🇧 English

## About

**Telaga OS** is an open-source desktop project based on Debian 12. It explores a desktop experience inspired by macOS while running on standard PC hardware.

The desktop interface is developed using Qt 6 Quick, QML, and C++17. The project also uses Openbox for window management and Picom for compositing.

Telaga OS is an independent Linux project, not a version of macOS or an official Apple product. Its goal is to develop a desktop environment with its own identity while learning from familiar desktop design patterns.

## Features

The project includes or aims to support the following features. Availability may vary depending on the current implementation.

| Feature | Description |
| --- | --- |
| Custom Dock | A dock interface with icon magnification effects. |
| Window animations | Animation effects for minimizing and restoring windows, where implemented. |
| App launch animation | Visual feedback when launching applications. |
| Mission Control | An overview of open windows and workspaces. |
| Application launcher | A central interface for finding and launching applications. |
| Control Center | Quick access to supported system settings. |
| Widgets and notifications | A side panel for desktop information and widgets. |
| Window controls | Familiar close, minimize, and maximize controls. |
| Custom visual style | Rounded icons, shadows, and transparency effects. |

## Technology Stack

| Component | Technology |
| --- | --- |
| Base system | Debian 12 (Bookworm) |
| Architecture | x86_64 / amd64 |
| Programming language | C++17 |
| UI framework | Qt 6, QML, Qt Quick Controls |
| Window manager | Openbox |
| Compositor | Picom |
| Display manager | LightDM |
| Browser | Firefox ESR |
| Terminal | Alacritty |
| File manager | PCManFM |

Performance depends on hardware, graphics drivers, and system configuration. Benchmark results will be added when reproducible tests are available.

## Getting Started

### Requirements

The following packages are intended for Debian or Ubuntu-based development systems.

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

### Build the Desktop Shell

Clone the repository and enter the panel directory:

```bash
git clone https://github.com/toriqayataalmukhorobin-del/telaga-os.git
cd telaga-os/desktop/panel
```

Generate the Makefile and compile the project:

```bash
qmake6 panel.pro
make -j"$(nproc)"
```

If the build succeeds and produces the `telaga-panel` executable, you can try running it:

```bash
./telaga-panel
```

This runs the desktop shell in the current session. Additional configuration or dependencies may be required depending on the source code and environment.

### Build a Debian Package

If the packaging script is available and configured, run it from the repository root:

```bash
chmod +x distro-builder/build-deb.sh
./distro-builder/build-deb.sh
```

Check the script output for the generated package location.

### Build a Live ISO

Install the required ISO-building utilities:

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

Then run the build script from the repository root:

```bash
chmod +x distro-builder/build-iso.sh
sudo ./distro-builder/build-iso.sh
```

Review the script before running it with root privileges. ISO generation depends on the script implementation, installed dependencies, network access, and boot configuration.

### Test with QEMU

If the ISO and test script are available, run:

```bash
chmod +x distro-builder/run-live.sh
./distro-builder/run-live.sh
```

Make sure the ISO path matches the location expected by the script. KVM acceleration requires compatible hardware and host configuration.

## Keyboard Shortcuts

The following shortcuts describe the intended interaction model. Verify that each shortcut is implemented and configured in the current build.

| Shortcut | Action |
| --- | --- |
| `Ctrl + Space` | Open or close application search |
| `F3` | Open Mission Control |
| `F11` | Toggle fullscreen mode, if supported |
| `Ctrl + Cmd + Q` | Planned session-lock shortcut; configuration may be required |

Other actions may be available through the top panel, Dock, and Control Center, depending on the implementation.

## Roadmap

- [x] Qt 6 / QML desktop shell foundation.
- [x] Dock magnification effect.
- [x] Window and application animations, where implemented.
- [ ] Improve Debian package automation.
- [ ] Improve Live ISO generation for BIOS and UEFI.
- [ ] Explore native Wayland support.
- [ ] Investigate global application menu integration.
- [ ] Add automatic light and dark themes.
- [ ] Explore graphical installation with Calamares.

Roadmap status should reflect the actual state of the code. Completed items should be verified before release.

## Contributing

Contributions are welcome! You can help with code, design, testing, documentation, bug reports, or feature ideas.

You don't need to be an expert to get involved. Start by exploring the repository, checking existing issues, or suggesting an improvement.

A typical contribution workflow is:

1. Fork the repository.
2. Create a feature branch.
3. Make and test your changes.
4. Commit your work.
5. Open a Pull Request with a clear explanation of the changes.

Example:

```bash
git checkout -b feature/my-improvement
git add .
git commit -m "Improve desktop interface"
git push origin feature/my-improvement
```

Please describe what you changed and include relevant testing details when submitting a Pull Request.

## License

Telaga OS is intended to be distributed under the **GNU General Public License v3.0 (GPL-3.0)**, subject to the license files included in the repository.

macOS and Apple are trademarks of their respective owners. Telaga OS is an independent project and is not affiliated with Apple.

---

<a id="bahasa-indonesia"></a>

# 🇮🇩 Bahasa Indonesia

## Tentang Proyek

**Telaga OS** adalah proyek desktop open-source berbasis Debian 12. Proyek ini mengembangkan antarmuka desktop yang terinspirasi dari macOS dan ditujukan untuk komputer PC pada umumnya.

Antarmuka desktop dikembangkan menggunakan Qt 6 Quick, QML, dan C++17. Proyek ini juga menggunakan Openbox untuk mengelola jendela dan Picom untuk menangani efek komposit.

Telaga OS merupakan proyek Linux independen, bukan versi macOS atau produk resmi Apple. Tujuannya adalah mengembangkan lingkungan desktop dengan identitas sendiri sambil mempelajari pola desain yang sudah dikenal pengguna komputer.

## Fitur

Berikut adalah fitur yang tersedia atau direncanakan. Ketersediaannya bergantung pada implementasi di versi yang sedang digunakan.

| Fitur | Keterangan |
| --- | --- |
| Dock kustom | Dock dengan efek pembesaran ikon. |
| Animasi jendela | Efek animasi untuk meminimalkan dan memulihkan jendela, jika sudah diterapkan. |
| Animasi peluncuran aplikasi | Umpan balik visual saat aplikasi dibuka. |
| Mission Control | Tampilan ringkas jendela dan ruang kerja yang terbuka. |
| Peluncur aplikasi | Antarmuka untuk mencari dan membuka aplikasi. |
| Control Center | Akses cepat ke pengaturan sistem yang didukung. |
| Widget dan notifikasi | Panel samping untuk informasi desktop dan widget. |
| Kontrol jendela | Tombol tutup, minimalkan, dan maksimalkan. |
| Gaya visual kustom | Ikon membulat, bayangan, dan efek transparansi. |

## Teknologi

| Komponen | Teknologi |
| --- | --- |
| Sistem dasar | Debian 12 (Bookworm) |
| Arsitektur | x86_64 / amd64 |
| Bahasa pemrograman | C++17 |
| Framework antarmuka | Qt 6, QML, Qt Quick Controls |
| Window manager | Openbox |
| Compositor | Picom |
| Display manager | LightDM |
| Browser | Firefox ESR |
| Terminal | Alacritty |
| File manager | PCManFM |

Performa bergantung pada perangkat keras, driver grafis, dan konfigurasi sistem. Hasil pengujian akan ditambahkan jika sudah tersedia pengujian yang dapat diulang.

## Memulai Pengembangan

### Persyaratan

Paket berikut ditujukan untuk lingkungan pengembangan berbasis Debian atau Ubuntu.

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

### Build Desktop Shell

Clone repository dan masuk ke direktori panel:

```bash
git clone https://github.com/toriqayataalmukhorobin-del/telaga-os.git
cd telaga-os/desktop/panel
```

Buat Makefile dan kompilasi proyek:

```bash
qmake6 panel.pro
make -j"$(nproc)"
```

Jika kompilasi berhasil dan menghasilkan executable `telaga-panel`, coba jalankan:

```bash
./telaga-panel
```

Perintah ini menjalankan desktop shell di sesi yang sedang aktif. Dependensi atau konfigurasi tambahan mungkin diperlukan, tergantung kode sumber dan lingkungan yang digunakan.

### Membuat Paket Debian

Jika skrip packaging tersedia dan sudah dikonfigurasi, jalankan dari direktori utama repository:

```bash
chmod +x distro-builder/build-deb.sh
./distro-builder/build-deb.sh
```

Periksa keluaran skrip untuk mengetahui lokasi paket yang dihasilkan.

### Membuat Live ISO

Pasang utilitas yang diperlukan untuk pembuatan ISO:

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

Kemudian jalankan skrip dari direktori utama repository:

```bash
chmod +x distro-builder/build-iso.sh
sudo ./distro-builder/build-iso.sh
```

Periksa isi skrip sebelum menjalankannya dengan hak akses root. Proses pembuatan ISO bergantung pada implementasi skrip, dependensi, koneksi internet, dan konfigurasi boot.

### Pengujian dengan QEMU

Jika ISO dan skrip pengujian tersedia, jalankan:

```bash
chmod +x distro-builder/run-live.sh
./distro-builder/run-live.sh
```

Pastikan lokasi ISO sesuai dengan yang diharapkan skrip. Akselerasi KVM memerlukan perangkat keras dan konfigurasi host yang mendukung.

## Pintasan Keyboard

Pintasan berikut menggambarkan interaksi yang direncanakan. Pastikan setiap pintasan sudah diterapkan dan dikonfigurasi pada versi yang digunakan.

| Pintasan | Fungsi |
| --- | --- |
| `Ctrl + Space` | Membuka atau menutup pencarian aplikasi |
| `F3` | Membuka Mission Control |
| `F11` | Beralih ke mode layar penuh, jika didukung |
| `Ctrl + Cmd + Q` | Pintasan penguncian sesi yang direncanakan; mungkin memerlukan konfigurasi |

Aksi lain mungkin tersedia melalui panel atas, Dock, dan Control Center, tergantung implementasinya.

## Roadmap

- [x] Fondasi desktop shell Qt 6 / QML.
- [x] Efek pembesaran ikon Dock.
- [x] Animasi jendela dan aplikasi, sesuai implementasi yang tersedia.
- [ ] Menyempurnakan otomatisasi paket Debian.
- [ ] Menyempurnakan pembuatan Live ISO untuk BIOS dan UEFI.
- [ ] Menjelajahi dukungan Wayland native.
- [ ] Mengembangkan integrasi menu aplikasi global.
- [ ] Menambahkan tema terang dan gelap otomatis.
- [ ] Menjajaki instalasi grafis menggunakan Calamares.

Status roadmap harus sesuai dengan kondisi kode sebenarnya. Tandai fitur selesai setelah implementasinya diperiksa.

## Kontribusi

Kami terbuka terhadap kontribusi dari siapa saja! Kamu bisa membantu melalui kode, desain, pengujian, dokumentasi, laporan bug, maupun ide fitur.

Kamu tidak harus menjadi ahli untuk ikut berkontribusi. Mulailah dengan mempelajari repository, memeriksa issue yang tersedia, atau mengusulkan perbaikan.

Alur kontribusi yang umum:

1. Fork repository.
2. Buat branch untuk fitur atau perbaikan.
3. Lakukan perubahan dan pengujian.
4. Commit perubahan.
5. Ajukan Pull Request disertai penjelasan yang jelas.

Contoh:

```bash
git checkout -b feature/perbaikan-saya
git add .
git commit -m "Memperbaiki antarmuka desktop"
git push origin feature/perbaikan-saya
```

Jelaskan perubahan yang dibuat dan sertakan informasi pengujian yang relevan saat mengirim Pull Request.

## Lisensi

Telaga OS direncanakan menggunakan lisensi **GNU General Public License v3.0 (GPL-3.0)**, sesuai dengan berkas lisensi yang disertakan di repository.

macOS dan Apple merupakan merek dagang milik pemegang hak masing-masing. Telaga OS adalah proyek independen dan tidak berafiliasi dengan Apple.

---

## Repository

GitHub: https://github.com/toriqayataalmukhorobin-del/telaga-os

**Interested in contributing? Contributions, suggestions, and constructive feedback are welcome.**

**Tertarik untuk berkontribusi? Kontribusi, saran, dan masukan yang membangun sangat kami harapkan.** 🌊
