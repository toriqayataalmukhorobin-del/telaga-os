#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>
#include <QTimer>
#include <QString>

class SystemInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int ramUsagePercent READ ramUsagePercent NOTIFY statsUpdated)
    Q_PROPERTY(QString ramText READ ramText NOTIFY statsUpdated)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY statsUpdated)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY statsUpdated)
    Q_PROPERTY(bool isCharging READ isCharging NOTIFY statsUpdated)
    Q_PROPERTY(QString hostname READ hostname CONSTANT)
    Q_PROPERTY(QString username READ username CONSTANT)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    int ramUsagePercent() const { return m_ramUsagePercent; }
    QString ramText() const { return m_ramText; }
    int batteryPercent() const { return m_batteryPercent; }
    bool hasBattery() const { return m_hasBattery; }
    bool isCharging() const { return m_isCharging; }
    QString hostname() const { return m_hostname; }
    QString username() const { return m_username; }

    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void lock();

signals:
    void statsUpdated();

private slots:
    void updateStats();

private:
    void readMemInfo();
    void readBatteryInfo();

    QTimer m_timer;
    int m_ramUsagePercent = 0;
    QString m_ramText = "0 / 0 GB";
    int m_batteryPercent = 100;
    bool m_hasBattery = false;
    bool m_isCharging = false;
    QString m_hostname;
    QString m_username;
};

#endif // SYSTEMINFO_H
