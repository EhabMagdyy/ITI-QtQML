#pragma once
#include <QObject>
#include <QDBusInterface>
#include <QDBusConnection>
#include <QVariantMap>

class BluetoothManager : public QObject {
private:
    QString         getAdapterPath();
    QString         findDevicePath(const QString &address);
    QDBusInterface *m_adapterIface = nullptr;
    bool            m_bluetoothEnabled = false;
    QString         m_adapterPath;

    Q_OBJECT
    Q_PROPERTY(bool bluetoothEnabled
               READ bluetoothEnabled
               WRITE setBluetoothEnabled
               NOTIFY bluetoothEnabledChanged)

public:
    explicit BluetoothManager(QObject *parent = nullptr);

    bool bluetoothEnabled() const;
    void setBluetoothEnabled(bool enabled);

    Q_INVOKABLE void scanDevices();
    Q_INVOKABLE void pairDevice(const QString &address);
    Q_INVOKABLE void connectDevice(const QString &address);

signals:
    void bluetoothEnabledChanged(bool enabled);

    void scanStarted();
    void scanFinished(QStringList devices);   // list of "Name|Address" strings
    void scanFailed(const QString &reason);

    void pairSuccess(const QString &name);
    void pairFailed(const QString &reason);

    void connectSuccess(const QString &name);
    void connectFailed(const QString &reason);

private slots:
    void onAdapterPropertiesChanged(QString interface,
                                    QVariantMap changedProps,
                                    QStringList invalidatedProps);

    void onInterfacesAdded(const QDBusObjectPath &path,
                           const QVariantMap &interfaces);

};