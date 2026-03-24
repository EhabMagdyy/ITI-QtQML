#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Backend/BluetoothManager.hpp"
#include "Backend/USBManager.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
        
    BluetoothManager btManager;
    UsbManager usbManager;
    engine.rootContext()->setContextProperty("btManager", &btManager);
    engine.rootContext()->setContextProperty("usbManager", &usbManager);

    engine.loadFromModule("Task06_MediaPlayer", "Main");

    return app.exec();
}
