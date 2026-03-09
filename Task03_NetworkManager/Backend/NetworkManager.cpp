// wifimanager.cpp
#include "NetworkManager.hpp"
#include <QDBusReply>

WifiManager::WifiManager(QObject *parent) : QObject(parent) {

    // Connect to NetworkManager on the SYSTEM bus
    m_nmInterface = new QDBusInterface(
        "org.freedesktop.NetworkManager",          // service
        "/org/freedesktop/NetworkManager",         // object path
        "org.freedesktop.NetworkManager",          // interface
        QDBusConnection::systemBus(),
        this
    );

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
    // Get the first wireless device path
    QDBusReply<QDBusObjectPath> deviceReply = 
        m_nmInterface->call("GetDeviceByIpIface", "wlan0");

    if (!deviceReply.isValid()) return;

    // Call RequestScan on that device
    QDBusInterface deviceIface(
        "org.freedesktop.NetworkManager",
        deviceReply.value().path(),
        "org.freedesktop.NetworkManager.Device.Wireless",
        QDBusConnection::systemBus()
    );
    deviceIface.call("RequestScan", QVariantMap());
}

void WifiManager::connectToNetwork(const QString &ssid, 
                                   const QString &password) {
    // Build the connection settings map NetworkManager expects
    QVariantMap connectionSettings;
    connectionSettings["type"] = "802-11-wireless";
    connectionSettings["id"] = ssid;

    QVariantMap wirelessSettings;
    wirelessSettings["ssid"] = ssid.toUtf8();
    wirelessSettings["mode"] = "infrastructure";

    QVariantMap securitySettings;
    securitySettings["key-mgmt"] = "wpa-psk";
    securitySettings["psk"] = password;

    QVariantMap allSettings;
    allSettings["connection"] = connectionSettings;
    allSettings["802-11-wireless"] = wirelessSettings;
    allSettings["802-11-wireless-security"] = securitySettings;

    // Call AddAndActivateConnection on NetworkManager
    QDBusInterface nmIface(
        "org.freedesktop.NetworkManager",
        "/org/freedesktop/NetworkManager",
        "org.freedesktop.NetworkManager",
        QDBusConnection::systemBus()
    );
    nmIface.call("AddAndActivateConnection",
                 QVariant::fromValue(allSettings),
                 QVariant::fromValue(QDBusObjectPath("/")),
                 QVariant::fromValue(QDBusObjectPath("/")));
}