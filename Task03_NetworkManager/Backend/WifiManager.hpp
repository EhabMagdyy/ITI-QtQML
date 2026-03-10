// wifimanager.h
#pragma once
#include <QObject>
#include <QDBusInterface>
#include <QDBusConnection>

// a{sa{sv}} — the type NetworkManager expects for connection settings
typedef QMap<QString, QVariantMap> NMConnectionSettings;
Q_DECLARE_METATYPE(NMConnectionSettings)

class WifiManager : public QObject {
private:
    QDBusInterface *m_nmInterface;
    bool m_wifiEnabled = false;
    private:
    void watchActiveConnection(const QString &activeConnPath, const QString &ssid);
    QString m_pendingSsid;
    QString m_activeConnPath;
    
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
    void scanStarted();                          // scan triggered
    void scanFinished(QStringList networks);     // scan done, returns network list
    void scanFailed(const QString &reason);      // scan failed
    void connectSuccess(const QString &ssid);    // connection succeeded
    void connectFailed(const QString &reason);   // connection failed

private slots:
    // connected to the system's NetworkManager's D-Bus
    void onPropertiesChanged(QString interface,
                             QVariantMap changedProps,
                             QStringList invalidatedProps);
                             
    void onActiveConnPropertiesChanged(QString interface,
                                       QVariantMap changedProps,
                                       QStringList invalidatedProps);
};