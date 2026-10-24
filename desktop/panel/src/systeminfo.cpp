#include "systeminfo.h"
#include <QRegularExpression>
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <QHostInfo>
#include <QDir>
#include <QDebug>

SystemInfo::SystemInfo(QObject *parent)
    : QObject(parent)
{
    m_username = qEnvironmentVariable("USER", "telaga");
    m_hostname = QHostInfo::localHostName();

    updateStats();

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

void SystemInfo::powerOff()
{
    qDebug() << "[Telaga Desktop] System poweroff requested";
    QProcess::startDetached("systemctl", QStringList() << "poweroff");
}

void SystemInfo::reboot()
{
    qDebug() << "[Telaga Desktop] System reboot requested";
    QProcess::startDetached("systemctl", QStringList() << "reboot");
}

void SystemInfo::lock()
{
    qDebug() << "[Telaga Desktop] System lock requested";
    QProcess::startDetached("loginctl", QStringList() << "lock-session");
}
