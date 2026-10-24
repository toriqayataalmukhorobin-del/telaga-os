#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>
#include <QTimer>
#include <QString>
#include <QVariantList>

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

    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged)
    Q_PROPERTY(bool wifiEnabled READ isWifiEnabled WRITE setWifiEnabled NOTIFY wifiChanged)
    Q_PROPERTY(bool bluetoothEnabled READ isBluetoothEnabled WRITE setBluetoothEnabled NOTIFY bluetoothChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    int ramUsagePercent() const { return m_ramUsagePercent; }
    QString ramText() const { return m_ramText; }
    int batteryPercent() const { return m_batteryPercent; }
    bool hasBattery() const { return m_hasBattery; }
    bool isCharging() const { return m_isCharging; }
    QString hostname() const { return m_hostname; }
    QString username() const { return m_username; }

    int volume() const { return m_volume; }
    int brightness() const { return m_brightness; }
    bool isWifiEnabled() const { return m_wifiEnabled; }
    bool isBluetoothEnabled() const { return m_bluetoothEnabled; }

    Q_INVOKABLE void setVolume(int percent);
    Q_INVOKABLE void setBrightness(int percent);
    Q_INVOKABLE void setWifiEnabled(bool enable);
    Q_INVOKABLE void setBluetoothEnabled(bool enable);

    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void lock();
    Q_INVOKABLE void logout();

    Q_INVOKABLE void launchCommand(const QString &command);

    // Notes persistence
    Q_INVOKABLE QString loadNotes();
    Q_INVOKABLE void saveNotes(const QString &text);

    // File manager helper for Finder
    Q_INVOKABLE QVariantList listFiles(const QString &categoryOrPath);
    Q_INVOKABLE void openFile(const QString &path);

signals:
    void statsUpdated();
    void volumeChanged(int volume);
    void brightnessChanged(int brightness);
    void wifiChanged(bool enabled);
    void bluetoothChanged(bool enabled);

private slots:
    void updateStats();

private:
    void readMemInfo();
    void readBatteryInfo();
    void readVolumeInfo();
    void readBrightnessInfo();
    void readWifiInfo();
    void readBluetoothInfo();

    QTimer m_timer;
    int m_ramUsagePercent = 0;
    QString m_ramText = "0 / 0 GB";
    int m_batteryPercent = 100;
    bool m_hasBattery = false;
    bool m_isCharging = false;
    QString m_hostname;
    QString m_username;

    int m_volume = 70;
    int m_brightness = 85;
    bool m_wifiEnabled = true;
    bool m_bluetoothEnabled = true;
};

#endif // SYSTEMINFO_H
