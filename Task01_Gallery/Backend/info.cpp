// temperatureprovider.cpp
#include "info.hpp"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QDebug>

Info::Info(QObject *parent)
    : QObject(parent), m_temperature(qQNaN()), m_humidity(-1), m_windSpeed(0.0), m_windDir(""), m_condition(""), manager(nullptr)
{
    manager = new QNetworkAccessManager(this);
    connect(&m_timer, &QTimer::timeout, this, &Info::updateTemperature);
    m_timer.start(60000); // update every 60 sec

    updateTemperature(); // fetch immediately
}

Info::~Info(){}

double Info::temperature() const { return m_temperature; }
QString Info::condition() const { return m_condition; }
int Info::humidity() const { return m_humidity; }
double Info::windSpeed() const { return m_windSpeed; }
QString Info::windDir() const { return m_windDir; }

void Info::updateTemperature()
{
    QUrl url("https://api.weatherapi.com/v1/current.json?key=63067efcf634435587452013262802&q=Giza&aqi=no");
    QNetworkRequest request(url);

    QNetworkReply *reply = manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if(reply->error() == QNetworkReply::NoError){
            QJsonObject json = QJsonDocument::fromJson(reply->readAll()).object();
            if(json.contains("current")){
                QJsonObject current = json["current"].toObject();
                double newTemp   = current["temp_c"].toDouble(qQNaN());
                QString condition = current["condition"].toObject()["text"].toString("N/A");
                int newHum       = current["humidity"].toInt(-1);
                double windSpeed = current["wind_kph"].toDouble(0.0);
                QString windDir  = current["wind_dir"].toString("N/A");

                qDebug() << "Fetched weather data:"
                        << "temp =" << newTemp << "°C,"
                        << "condition =" << condition << ","
                        << "humidity =" << newHum << "%,"
                        << "windSpeed =" << windSpeed << "kph,"
                        << "windDir =" << windDir;

                if(newTemp != m_temperature){
                    m_temperature = newTemp;
                    emit temperatureChanged();
                }
                if(condition != m_condition){
                    m_condition = condition;
                    emit conditionChanged();
                }
                if(newHum != m_humidity){
                    m_humidity = newHum;
                    emit humidityChanged();
                }
                if(windSpeed != m_windSpeed){
                    m_windSpeed = windSpeed;
                    emit windSpeedChanged();
                }
                if(windDir != m_windDir){
                    m_windDir = windDir;
                    emit windDirChanged();
                }
            }
        } else {
            qWarning() << "Weather API error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}