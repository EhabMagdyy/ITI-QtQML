// info.hpp
#ifndef INFO_HPP
#define INFO_HPP

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>

class Info : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(int humidity READ humidity NOTIFY humidityChanged)

public:
    explicit Info(QObject *parent = nullptr);
    ~Info() override;

    double temperature() const;
    int humidity() const;

signals:
    void temperatureChanged();
    void humidityChanged();

private slots:
    void updateTemperature();

private:
    double m_temperature;
    int m_humidity;
    QTimer m_timer;
    QNetworkAccessManager *manager;
};

#endif // INFO_HPP