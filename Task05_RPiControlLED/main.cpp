#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "LedControl/led.hpp"

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
    
    LedController led;
    engine.rootContext()->setContextProperty("ledController", &led);

    engine.loadFromModule("Task05_RPiControlLED", "Main");

    return app.exec();
}
