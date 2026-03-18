#pragma once
#include <QObject>

class LedController : public QObject
{
    Q_OBJECT
public:
    explicit LedController(QObject *parent = nullptr);
    ~LedController();

public slots:
    void turnOn();
    void turnOff();
    void toggle();

private:
    bool m_state = false;
    int m_gpioFd = -1;
};