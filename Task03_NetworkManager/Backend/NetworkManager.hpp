// wifimanager.h
#pragma once
#include <QObject>
#include <QDBusInterface>
#include <QDBusConnection>

class WifiManager : public QObject {
private:
    QDBusInterface *m_nmInterface;
    bool m_wifiEnabled = false;
    
    Q_OBJECT
    // This property is what QML binds to - This exposes the wifiEnabled state to QML to read, write, and notify.
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled 
                                WRITE setWifiEnabled 
                                NOTIFY wifiEnabledChanged)
public:
    explicit WifiManager(QObject *parent = nullptr);

    bool wifiEnabled() const;        // Getter for the wifiEnabled property
    void setWifiEnabled(bool enabled);  // Setter for the wifiEnabled property

    // Q_INVOKABLE > Makes the function callable directly from QML.
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password);
    Q_INVOKABLE void scanNetworks();

signals:
    void wifiEnabledChanged(bool enabled);

private slots:
    // connected to the system's NetworkManager's D-Bus
    void onPropertiesChanged(QString interface,
                             QVariantMap changedProps,
                             QStringList invalidatedProps);
};