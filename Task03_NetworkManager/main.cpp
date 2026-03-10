#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Backend/WifiManager.hpp"
#include "Backend/BluetoothManager.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    WifiManager wifiManager;
    BluetoothManager bluetoothManager;
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    // Register the backend to let QML access it via the context property "WifiManager" & "BluetoothManager"
    engine.rootContext()->setContextProperty("WifiManager", &wifiManager);
    engine.rootContext()->setContextProperty("BluetoothManager", &bluetoothManager);

    engine.loadFromModule("Task03_NetworkManager", "Main");

    return app.exec();
}
