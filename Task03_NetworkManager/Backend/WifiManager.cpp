// wifimanager.cpp
#include "WifiManager.hpp"
#include <QDBusReply>
#include <QDBusMetaType>

WifiManager::WifiManager(QObject *parent) : QObject(parent) {

    // Connect to NetworkManager on the SYSTEM bus
    m_nmInterface = new QDBusInterface(
        "org.freedesktop.NetworkManager",          // service
        "/org/freedesktop/NetworkManager",         // object path
        "org.freedesktop.NetworkManager",          // interface
        QDBusConnection::systemBus(),
        this
    );
    qDBusRegisterMetaType<NMConnectionSettings>();

    // 1. Read initial state on startup
    QVariant val = m_nmInterface->property("WirelessEnabled");
    if (val.isValid())
        m_wifiEnabled = val.toBool();

    // 2. Subscribe to PropertiesChanged signal
    //    so we react when wifi is toggled OUTSIDE our app
    QDBusConnection::systemBus().connect(
        "org.freedesktop.NetworkManager",
        "/org/freedesktop/NetworkManager",
        "org.freedesktop.DBus.Properties",
        "PropertiesChanged",
        this,
        // slot to handle the signal and update m_wifiEnabled + notify QML
        SLOT(onPropertiesChanged(QString, QVariantMap, QStringList))
    );
}

bool WifiManager::wifiEnabled() const {
    return m_wifiEnabled;
}

void WifiManager::setWifiEnabled(bool enabled) {
    if (m_wifiEnabled == enabled) return;

    // Write WirelessEnabled property via D-Bus
    m_nmInterface->setProperty("WirelessEnabled", QVariant::fromValue(enabled));
}

void WifiManager::onPropertiesChanged(QString interface,
                                      QVariantMap changedProps,
                                      QStringList invalidatedProps) {
    Q_UNUSED(interface)
    Q_UNUSED(invalidatedProps)

    if (changedProps.contains("WirelessEnabled")) {
        m_wifiEnabled = changedProps["WirelessEnabled"].toBool();
        emit wifiEnabledChanged(m_wifiEnabled); // QML switch updates here
    }
}

void WifiManager::scanNetworks() {
    emit scanStarted();

    // Get ALL devices, find the wireless one dynamically
    QDBusReply<QList<QDBusObjectPath>> devicesReply =
        m_nmInterface->call("GetDevices");

    if (!devicesReply.isValid()) {
        emit scanFailed("Cannot get devices: " + devicesReply.error().message());
        return;
    }

    QString wirelessDevicePath;
    for (const QDBusObjectPath &path : devicesReply.value()) {
        QDBusInterface devIface(
            "org.freedesktop.NetworkManager",
            path.path(),
            "org.freedesktop.NetworkManager.Device",
            QDBusConnection::systemBus()
        );
        // Device type 2 = NM_DEVICE_TYPE_WIFI
        if (devIface.property("DeviceType").toUInt() == 2) {
            wirelessDevicePath = path.path();
            break;
        }
    }

    if (wirelessDevicePath.isEmpty()) {
        emit scanFailed("No wireless device found on this machine");
        return;
    }

    QDBusInterface deviceIface(
        "org.freedesktop.NetworkManager",
        wirelessDevicePath,
        "org.freedesktop.NetworkManager.Device.Wireless",
        QDBusConnection::systemBus()
    );

    QDBusReply<void> scanReply = deviceIface.call("RequestScan", QVariantMap());
    if (!scanReply.isValid()) {
        emit scanFailed(scanReply.error().message());
        return;
    }

    QDBusReply<QList<QDBusObjectPath>> apReply =
        deviceIface.call("GetAllAccessPoints");

    QStringList networks;
    if (apReply.isValid()) {
        for (const QDBusObjectPath &apPath : apReply.value()) {
            QDBusInterface apIface(
                "org.freedesktop.NetworkManager",
                apPath.path(),
                "org.freedesktop.NetworkManager.AccessPoint",
                QDBusConnection::systemBus()
            );
            QString ssid = QString::fromUtf8(
                apIface.property("Ssid").toByteArray()
            );
            if (!ssid.isEmpty())
                networks << ssid;
        }
    }

    emit scanFinished(networks);
}

void WifiManager::connectToNetwork(const QString &ssid, const QString &password) {
    if (ssid.isEmpty()) {
        emit connectFailed("SSID cannot be empty");
        return;
    }

    QVariantMap connectionSettings;
    connectionSettings["type"] = "802-11-wireless";
    connectionSettings["id"]   = ssid;

    QVariantMap wirelessSettings;
    wirelessSettings["ssid"] = ssid.toUtf8();
    wirelessSettings["mode"] = "infrastructure";

    QVariantMap securitySettings;
    securitySettings["key-mgmt"] = "wpa-psk";
    securitySettings["psk"]      = password;

    NMConnectionSettings allSettings;
    allSettings["connection"]               = connectionSettings;
    allSettings["802-11-wireless"]          = wirelessSettings;
    allSettings["802-11-wireless-security"] = securitySettings;

    QDBusInterface nmIface(
        "org.freedesktop.NetworkManager",
        "/org/freedesktop/NetworkManager",
        "org.freedesktop.NetworkManager",
        QDBusConnection::systemBus()
    );

    QDBusMessage reply = nmIface.call(
        "AddAndActivateConnection",
        QVariant::fromValue(allSettings),
        QVariant::fromValue(QDBusObjectPath("/")),
        QVariant::fromValue(QDBusObjectPath("/"))
    );

    if (reply.type() == QDBusMessage::ErrorMessage) {
        emit connectFailed(reply.errorMessage());
        return;
    }

    QDBusObjectPath activeConnPath = reply.arguments().at(1).value<QDBusObjectPath>();
    watchActiveConnection(activeConnPath.path(), ssid);
}

void WifiManager::watchActiveConnection(const QString &activeConnPath,
                                        const QString &ssid) {
    m_pendingSsid    = ssid;
    m_activeConnPath = activeConnPath;

    // Subscribe to state changes on the active connection object
    QDBusConnection::systemBus().connect(
        "org.freedesktop.NetworkManager",
        activeConnPath,
        "org.freedesktop.DBus.Properties",
        "PropertiesChanged",
        this,
        SLOT(onActiveConnPropertiesChanged(QString, QVariantMap, QStringList))
    );
}

void WifiManager::onActiveConnPropertiesChanged(QString interface,
                                                QVariantMap changedProps,
                                                QStringList invalidatedProps) {
    Q_UNUSED(interface)
    Q_UNUSED(invalidatedProps)

    if (!changedProps.contains("State")) return;

    uint state = changedProps["State"].toUInt();

    // NM Active Connection States:
    // 0 = Unknown, 1 = Activating, 2 = Activated, 3 = Deactivating, 4 = Deactivated
    switch (state) {
        case 2:
            emit connectSuccess(m_pendingSsid);
            // Unsubscribe — we got our answer
            QDBusConnection::systemBus().disconnect(
                "org.freedesktop.NetworkManager",
                m_activeConnPath,
                "org.freedesktop.DBus.Properties",
                "PropertiesChanged",
                this,
                SLOT(onActiveConnPropertiesChanged(QString, QVariantMap, QStringList))
            );
            break;
        case 4:
            emit connectFailed("Could not connect to: " + m_pendingSsid);
            QDBusConnection::systemBus().disconnect(
                "org.freedesktop.NetworkManager",
                m_activeConnPath,
                "org.freedesktop.DBus.Properties",
                "PropertiesChanged",
                this,
                SLOT(onActiveConnPropertiesChanged(QString, QVariantMap, QStringList))
            );
            break;
        default:
            break;
    }
}