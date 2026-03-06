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
    Q_PROPERTY(QString condition READ condition NOTIFY conditionChanged)
    Q_PROPERTY(int humidity READ humidity NOTIFY humidityChanged)
    Q_PROPERTY(double windSpeed READ windSpeed NOTIFY windSpeedChanged)
    Q_PROPERTY(QString windDir READ windDir NOTIFY windDirChanged)

public:
    explicit Info(QObject *parent = nullptr);
    ~Info() override;

    double temperature() const;
    QString condition() const;
    int humidity() const;
    double windSpeed() const;
    QString windDir() const;

signals:
    void temperatureChanged();
    void conditionChanged();
    void humidityChanged();
    void windSpeedChanged();
    void windDirChanged();

private slots:
    void updateTemperature();

private:
    double m_temperature;
    QString m_condition;
    int m_humidity;
    double m_windSpeed;
    QString m_windDir;
    QTimer m_timer;
    QNetworkAccessManager *manager;
};

#endif // INFO_HPP