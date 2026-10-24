#include "systeminfo.h"
#include <QRegularExpression>
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <QHostInfo>
#include <QDir>
#include <QStandardPaths>
#include <QDateTime>
#include <QDebug>

SystemInfo::SystemInfo(QObject *parent)
    : QObject(parent)
{
    m_username = qEnvironmentVariable("USER", "telaga");
    m_hostname = QHostInfo::localHostName();

    updateStats();
    readVolumeInfo();
    readBrightnessInfo();
    readWifiInfo();
    readBluetoothInfo();

    connect(&m_timer, &QTimer::timeout, this, &SystemInfo::updateStats);
    m_timer.start(2500); // update every 2.5s
}

void SystemInfo::updateStats()
{
    readMemInfo();
    readBatteryInfo();
    emit statsUpdated();
}

void SystemInfo::readMemInfo()
{
    QFile file("/proc/meminfo");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    quint64 totalMemKb = 0;
    quint64 availMemKb = 0;

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (line.startsWith("MemTotal:")) {
            totalMemKb = line.split(QRegularExpression("\\s+")).value(1).toULongLong();
        } else if (line.startsWith("MemAvailable:")) {
            availMemKb = line.split(QRegularExpression("\\s+")).value(1).toULongLong();
        }
        if (totalMemKb > 0 && availMemKb > 0)
            break;
    }

    if (totalMemKb > 0) {
        quint64 usedMemKb = totalMemKb - availMemKb;
        m_ramUsagePercent = static_cast<int>((usedMemKb * 100) / totalMemKb);

        double usedGb = usedMemKb / (1024.0 * 1024.0);
        double totalGb = totalMemKb / (1024.0 * 1024.0);
        m_ramText = QString("%1 / %2 GB").arg(usedGb, 0, 'f', 1).arg(totalGb, 0, 'f', 1);
    }
}

void SystemInfo::readBatteryInfo()
{
    QDir powerDir("/sys/class/power_supply");
    if (!powerDir.exists()) {
        m_hasBattery = false;
        return;
    }

    QStringList bats = powerDir.entryList(QStringList() << "BAT*", QDir::Dirs);
    if (bats.isEmpty()) {
        m_hasBattery = false;
        return;
    }

    QString batPath = powerDir.absoluteFilePath(bats.first());
    QFile capFile(batPath + "/capacity");
    if (capFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_hasBattery = true;
        m_batteryPercent = capFile.readLine().trimmed().toInt();
    }

    QFile statFile(batPath + "/status");
    if (statFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString stat = statFile.readLine().trimmed();
        m_isCharging = (stat == "Charging");
    }
}

void SystemInfo::readVolumeInfo()
{
    // Check pactl first
    QProcess proc;
    proc.start("pactl", QStringList() << "get-sink-volume" << "@DEFAULT_SINK@");
    if (proc.waitForFinished(400)) {
        QString out = proc.readAllStandardOutput();
        // Regex match / ([0-9]+)% /
        QRegularExpression re("/\\s*(\\d+)%\\s*/");
        QRegularExpressionMatch match = re.match(out);
        if (match.hasMatch()) {
            m_volume = match.captured(1).toInt();
            emit volumeChanged(m_volume);
            return;
        }
    }
}

void SystemInfo::setVolume(int percent)
{
    m_volume = qBound(0, percent, 100);
    emit volumeChanged(m_volume);

    QString cmd = QString("pactl set-sink-volume @DEFAULT_SINK@ %1% 2>/dev/null || amixer set Master %1% 2>/dev/null").arg(m_volume);
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
}

void SystemInfo::readBrightnessInfo()
{
    QDir backlightDir("/sys/class/backlight");
    if (backlightDir.exists()) {
        QStringList entries = backlightDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        if (!entries.isEmpty()) {
            QString devPath = backlightDir.absoluteFilePath(entries.first());
            QFile curFile(devPath + "/actual_brightness");
            QFile maxFile(devPath + "/max_brightness");
            if (curFile.open(QIODevice::ReadOnly) && maxFile.open(QIODevice::ReadOnly)) {
                int cur = curFile.readLine().trimmed().toInt();
                int max = maxFile.readLine().trimmed().toInt();
                if (max > 0) {
                    m_brightness = qBound(10, (cur * 100) / max, 100);
                    emit brightnessChanged(m_brightness);
                    return;
                }
            }
        }
    }
}

void SystemInfo::setBrightness(int percent)
{
    m_brightness = qBound(10, percent, 100);
    emit brightnessChanged(m_brightness);

    QString cmd = QString(
        "brightnessctl set %1% 2>/dev/null || "
        "xrandr --output $(xrandr 2>/dev/null | grep ' connected' | awk '{print $1}' | head -n1) --brightness $(awk 'BEGIN {print %1/100}') 2>/dev/null"
    ).arg(m_brightness);

    QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
}

void SystemInfo::readWifiInfo()
{
    QProcess proc;
    proc.start("nmcli", QStringList() << "radio" << "wifi");
    if (proc.waitForFinished(400)) {
        QString out = proc.readAllStandardOutput().trimmed().toLower();
        m_wifiEnabled = (out == "enabled");
        emit wifiChanged(m_wifiEnabled);
    }
}

void SystemInfo::setWifiEnabled(bool enable)
{
    m_wifiEnabled = enable;
    emit wifiChanged(m_wifiEnabled);

    QString arg = enable ? "on" : "off";
    QProcess::startDetached("nmcli", QStringList() << "radio" << "wifi" << arg);
}

void SystemInfo::readBluetoothInfo()
{
    QProcess proc;
    proc.start("/bin/sh", QStringList() << "-c" << "rfkill list bluetooth | grep -i 'soft blocked: yes'");
    if (proc.waitForFinished(400)) {
        QString out = proc.readAllStandardOutput().trimmed();
        m_bluetoothEnabled = out.isEmpty();
        emit bluetoothChanged(m_bluetoothEnabled);
    }
}

void SystemInfo::setBluetoothEnabled(bool enable)
{
    m_bluetoothEnabled = enable;
    emit bluetoothChanged(m_bluetoothEnabled);

    QString cmd = enable ? "rfkill unblock bluetooth 2>/dev/null || bluetoothctl power on 2>/dev/null"
                         : "rfkill block bluetooth 2>/dev/null || bluetoothctl power off 2>/dev/null";
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
}

void SystemInfo::powerOff()
{
    qDebug() << "[Telaga Desktop] System poweroff requested";
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << "systemctl poweroff 2>/dev/null || poweroff 2>/dev/null || shutdown -h now");
}

void SystemInfo::reboot()
{
    qDebug() << "[Telaga Desktop] System reboot requested";
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << "systemctl reboot 2>/dev/null || reboot 2>/dev/null || shutdown -r now");
}

void SystemInfo::lock()
{
    qDebug() << "[Telaga Desktop] System lock requested";
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << "loginctl lock-session 2>/dev/null || xscreensaver-command -lock 2>/dev/null || light-locker-command -l 2>/dev/null || slock 2>/dev/null");
}

void SystemInfo::logout()
{
    qDebug() << "[Telaga Desktop] User logout requested";
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << "loginctl terminate-session ${XDG_SESSION_ID:-} 2>/dev/null || openbox --exit 2>/dev/null || pkill -u $USER telaga-session || pkill telaga-panel");
}

void SystemInfo::launchCommand(const QString &command)
{
    if (command.isEmpty()) return;

    qDebug() << "[Telaga SystemInfo] Launching command:" << command;

    if (command == "settings") {
        QString cmd = "gnome-control-center 2>/dev/null || xfce4-settings-manager 2>/dev/null || pavucontrol 2>/dev/null || lxappearance 2>/dev/null || openbox --reconfigure";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "software") {
        QString cmd = "gnome-software 2>/dev/null || synaptic 2>/dev/null || software-properties-gtk 2>/dev/null || x-terminal-emulator -e 'sudo apt update && sudo apt upgrade' 2>/dev/null";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "terminal") {
        QString cmd = "alacritty 2>/dev/null || x-terminal-emulator 2>/dev/null || xterm";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "safari" || command == "browser") {
        QString cmd = "x-www-browser 2>/dev/null || firefox-esr 2>/dev/null || firefox 2>/dev/null || chromium 2>/dev/null || google-chrome";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "finder") {
        QString cmd = "pcmanfm 2>/dev/null || nautilus 2>/dev/null || thunar 2>/dev/null || xdg-open ~";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "trash") {
        QString cmd = "pcmanfm ~/.local/share/Trash/files 2>/dev/null || xdg-open ~/.local/share/Trash 2>/dev/null || xdg-open ~";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    // Default: run detached shell command
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << command);
}

QString SystemInfo::loadNotes()
{
    QString confDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/telaga";
    QFile file(confDir + "/quicknotes.txt");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QTextStream(&file).readAll();
    }
    return "Telaga OS: Rasakan kemewahan antarmuka macOS Sonoma & Sequoia langsung di PC & Laptop Anda.";
}

void SystemInfo::saveNotes(const QString &text)
{
    QString confDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/telaga";
    QDir().mkpath(confDir);

    QFile file(confDir + "/quicknotes.txt");
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << text;
    }
}

QVariantList SystemInfo::listFiles(const QString &categoryOrPath)
{
    QVariantList results;
    QString targetPath;

    QString home = QDir::homePath();
    if (categoryOrPath == "Dokumen" || categoryOrPath == "documents") {
        targetPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    } else if (categoryOrPath == "Unduhan" || categoryOrPath == "downloads") {
        targetPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    } else if (categoryOrPath == "Desktop" || categoryOrPath == "desktop") {
        targetPath = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    } else if (categoryOrPath == "Semua Berkas" || categoryOrPath == "all") {
        targetPath = home;
    } else if (QDir(categoryOrPath).exists()) {
        targetPath = categoryOrPath;
    } else {
        targetPath = home;
    }

    QDir dir(targetPath);
    if (!dir.exists()) {
        // Fallback default sample items if directory doesn't exist
        QVariantMap sample1;
        sample1["name"] = "Dokumen Penting";
        sample1["icon"] = "📁";
        sample1["isFolder"] = true;
        sample1["path"] = home;
        results.append(sample1);
        return results;
    }

    QFileInfoList entries = dir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot, QDir::DirsFirst | QDir::Name);

    // Limit to 40 items for smooth UI performance
    int count = 0;
    for (const QFileInfo &info : entries) {
        if (info.isHidden()) continue;
        if (count++ >= 40) break;

        QVariantMap item;
        item["name"] = info.fileName();
        item["path"] = info.absoluteFilePath();
        item["isFolder"] = info.isDir();

        if (info.isDir()) {
            item["icon"] = "📁";
        } else {
            QString suf = info.suffix().toLower();
            if (suf == "pdf") item["icon"] = "📕";
            else if (suf == "mp3" || suf == "flac" || suf == "wav") item["icon"] = "🎵";
            else if (suf == "mp4" || suf == "mkv" || suf == "mov") item["icon"] = "🎬";
            else if (suf == "png" || suf == "jpg" || suf == "jpeg" || suf == "webp") item["icon"] = "🖼️";
            else if (suf == "sh" || suf == "py" || suf == "cpp" || suf == "h") item["icon"] = "📜";
            else if (suf == "zip" || suf == "tar" || suf == "gz" || suf == "deb") item["icon"] = "📦";
            else item["icon"] = "📄";
        }
        results.append(item);
    }

    if (results.isEmpty()) {
        // Add a friendly placeholder if folder is empty
        QVariantMap emptyItem;
        emptyItem["name"] = "(Folder Kosong)";
        emptyItem["icon"] = "📂";
        emptyItem["isFolder"] = false;
        emptyItem["path"] = targetPath;
        results.append(emptyItem);
    }

    return results;
}

void SystemInfo::openFile(const QString &path)
{
    if (path.isEmpty()) return;
    qDebug() << "[Telaga Finder] Opening:" << path;

    QFileInfo info(path);
    if (info.isDir()) {
        QString cmd = QString("pcmanfm '%1' 2>/dev/null || xdg-open '%1' 2>/dev/null").arg(path);
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
    } else {
        QString cmd = QString("xdg-open '%1' 2>/dev/null").arg(path);
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
    }
}
