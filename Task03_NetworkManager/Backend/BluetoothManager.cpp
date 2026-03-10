#include "BluetoothManager.hpp"
#include <QDBusReply>
#include <QDBusMetaType>
#include <QDBusArgument>
#include <QTimer>

// ─── D-Bus custom type registration ─────────────────────────────────────────
// a{sa{sv}}
typedef QMap<QString, QVariantMap> DBusInterfaceMap;
Q_DECLARE_METATYPE(DBusInterfaceMap)

// a{oa{sa{sv}}}
typedef QMap<QDBusObjectPath, DBusInterfaceMap> DBusManagedObjects;
Q_DECLARE_METATYPE(DBusManagedObjects)

QDBusArgument &operator<<(QDBusArgument &arg, const DBusInterfaceMap &map) {
    arg.beginMap(QMetaType::QString, qMetaTypeId<QVariantMap>());
    for (auto it = map.begin(); it != map.end(); ++it) {
        arg.beginMapEntry();
        arg << it.key() << it.value();
        arg.endMapEntry();
    }
    arg.endMap();
    return arg;
}

const QDBusArgument &operator>>(const QDBusArgument &arg, DBusInterfaceMap &map) {
    arg.beginMap();
    while (!arg.atEnd()) {
        QString key;
        QVariantMap val;
        arg.beginMapEntry();
        arg >> key >> val;
        arg.endMapEntry();
        map[key] = val;
    }
    arg.endMap();
    return arg;
}

QDBusArgument &operator<<(QDBusArgument &arg, const DBusManagedObjects &map) {
    arg.beginMap(qMetaTypeId<QDBusObjectPath>(), qMetaTypeId<DBusInterfaceMap>());
    for (auto it = map.begin(); it != map.end(); ++it) {
        arg.beginMapEntry();
        arg << it.key() << it.value();
        arg.endMapEntry();
    }
    arg.endMap();
    return arg;
}

const QDBusArgument &operator>>(const QDBusArgument &arg, DBusManagedObjects &map) {
    arg.beginMap();
    while (!arg.atEnd()) {
        QDBusObjectPath path;
        DBusInterfaceMap ifaces;
        arg.beginMapEntry();
        arg >> path >> ifaces;
        arg.endMapEntry();
        map[path] = ifaces;
    }
    arg.endMap();
    return arg;
}

// ─── BlueZ D-Bus constants ───────────────────────────────────────────────────
static const QString BZ_SERVICE = "org.bluez";
static const QString BZ_ADAPTER = "org.bluez.Adapter1";
static const QString BZ_DEVICE  = "org.bluez.Device1";
static const QString BZ_OBJ_MGR = "org.freedesktop.DBus.ObjectManager";
static const QString BZ_PROPS   = "org.freedesktop.DBus.Properties";
static const QString BZ_ROOT    = "/";

// Helper: get all managed objects
static DBusManagedObjects getManagedObjects() {
    qDBusRegisterMetaType<DBusInterfaceMap>();
    qDBusRegisterMetaType<DBusManagedObjects>();

    QDBusMessage msg = QDBusMessage::createMethodCall(
        BZ_SERVICE, BZ_ROOT, BZ_OBJ_MGR, "GetManagedObjects"
    );
    QDBusMessage resp = QDBusConnection::systemBus().call(msg);
    DBusManagedObjects result;
    if (resp.type() != QDBusMessage::ErrorMessage)
        resp.arguments().at(0).value<QDBusArgument>() >> result;
    return result;
}

BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent)
{
    qDBusRegisterMetaType<DBusInterfaceMap>();
    qDBusRegisterMetaType<DBusManagedObjects>();

    QString adapterPath = getAdapterPath();
    if (adapterPath.isEmpty()) {
        qWarning() << "BluetoothManager: No Bluetooth adapter found";
        return;
    }

    m_adapterPath = adapterPath;

    m_adapterIface = new QDBusInterface(
        BZ_SERVICE, adapterPath, BZ_ADAPTER,
        QDBusConnection::systemBus(), this
    );

    if (m_adapterIface->isValid()) {
        QVariant val = m_adapterIface->property("Powered");
        if (val.isValid())
            m_bluetoothEnabled = val.toBool();
    }

    bool connected = QDBusConnection::systemBus().connect(
        BZ_SERVICE,
        adapterPath,
        BZ_PROPS,
        "PropertiesChanged",
        this,
        SLOT(onAdapterPropertiesChanged(QString, QVariantMap, QStringList))
    );
    qDebug() << "BT PropertiesChanged connected:" << connected;
}

// Helper: find the first Bluetooth adapter path
QString BluetoothManager::getAdapterPath()
{
    for (const QString &path : { QString("/org/bluez/hci0"),
                                  QString("/org/bluez/hci1") }) {
        QDBusInterface iface(BZ_SERVICE, path, BZ_ADAPTER,
                             QDBusConnection::systemBus());
        if (iface.isValid())
            return path;
    }
    return {};
}

// Helper: find device D-Bus path by MAC address
QString BluetoothManager::findDevicePath(const QString &address){
    DBusManagedObjects objects = getManagedObjects();
    for (auto it = objects.begin(); it != objects.end(); ++it) {
        const DBusInterfaceMap &ifaces = it.value();
        if (ifaces.contains(BZ_DEVICE)) {
            const QVariantMap &props = ifaces[BZ_DEVICE];
            if (props.value("Address").toString() == address)
                return it.key().path();
        }
    }
    return {};
}

// Getter
bool BluetoothManager::bluetoothEnabled() const{
    return m_bluetoothEnabled;
}

// Setter — toggles Bluetooth hardware
void BluetoothManager::setBluetoothEnabled(bool enabled)
{
    if (!m_adapterIface || !m_adapterIface->isValid()) {
        qWarning() << "BluetoothManager: No adapter to toggle";
        return;
    }
    if (m_bluetoothEnabled == enabled) return;

    // BlueZ requires explicit Properties.Set call — setProperty() silently fails
    QDBusInterface propsIface(
        BZ_SERVICE,
        m_adapterPath,
        "org.freedesktop.DBus.Properties",
        QDBusConnection::systemBus()
    );

    QDBusMessage reply = propsIface.call(
        "Set",
        BZ_ADAPTER,                              // interface name
        "Powered",                               // property name
        QVariant::fromValue(QDBusVariant(enabled)) // value
    );

    if (reply.type() == QDBusMessage::ErrorMessage)
        qWarning() << "BT Set Powered failed:" << reply.errorMessage();

}

// Slot: adapter property changed from outside
void BluetoothManager::onAdapterPropertiesChanged(QString interface,
                                                   QVariantMap changedProps,
                                                   QStringList invalidatedProps)
{
    Q_UNUSED(interface)
    Q_UNUSED(invalidatedProps)
    qDebug() << "BT props changed:" << changedProps;

    if (changedProps.contains("Powered")) {
        m_bluetoothEnabled = changedProps["Powered"].toBool();
        emit bluetoothEnabledChanged(m_bluetoothEnabled);
    }
}

// Scan for nearby devices
void BluetoothManager::scanDevices()
{
    if (!m_adapterIface || !m_adapterIface->isValid()) {
        emit scanFailed("No Bluetooth adapter available");
        return;
    }
    if (!m_bluetoothEnabled) {
        emit scanFailed("Bluetooth is turned off");
        return;
    }

    emit scanStarted();

    QDBusReply<void> reply = m_adapterIface->call("StartDiscovery");
    if (!reply.isValid()) {
        emit scanFailed(reply.error().message());
        return;
    }

    // Stop after 8 seconds and collect all found devices
    QTimer::singleShot(8000, this, [this]() {
        m_adapterIface->call("StopDiscovery");

        DBusManagedObjects objects = getManagedObjects();
        QStringList devices;

        for (auto it = objects.begin(); it != objects.end(); ++it) {
            const DBusInterfaceMap &ifaces = it.value();
            if (ifaces.contains(BZ_DEVICE)) {
                const QVariantMap &props = ifaces[BZ_DEVICE];
                QString name    = props.value("Name", "Unknown").toString();
                QString address = props.value("Address", "").toString();
                if (!address.isEmpty())
                    devices << name + "|" + address;
            }
        }

        emit scanFinished(devices);
    });
}

// Slot: new device appeared during scan
void BluetoothManager::onInterfacesAdded(const QDBusObjectPath &path,
                                          const QVariantMap &interfaces)
{
    Q_UNUSED(path)
    Q_UNUSED(interfaces)
    // reserved for future live-update support
}

// Pair with a device by MAC address
void BluetoothManager::pairDevice(const QString &address)
{
    QString path = findDevicePath(address);
    if (path.isEmpty()) {
        emit pairFailed("Device not found: " + address);
        return;
    }

    QDBusInterface devIface(BZ_SERVICE, path, BZ_DEVICE,
                            QDBusConnection::systemBus());

    QString name = devIface.property("Name").toString();

    if (devIface.property("Paired").toBool()) {
        emit pairSuccess(name + " (already paired)");
        return;
    }

    QDBusReply<void> reply = devIface.call("Pair");
    if (!reply.isValid()) {
        emit pairFailed(reply.error().message());
        return;
    }

    emit pairSuccess(name);
}

// Connect to a paired device
void BluetoothManager::connectDevice(const QString &address)
{
    QString path = findDevicePath(address);
    if (path.isEmpty()) {
        emit connectFailed("Device not found: " + address);
        return;
    }

    QDBusInterface devIface(BZ_SERVICE, path, BZ_DEVICE,
                            QDBusConnection::systemBus());

    QString name = devIface.property("Name").toString();

    QDBusReply<void> reply = devIface.call("Connect");
    if (!reply.isValid()) {
        emit connectFailed(reply.error().message());
        return;
    }

    emit connectSuccess(name);
}