// temperatureprovider.cpp
#include "info.hpp"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>

Info::Info(QObject *parent)
    : QObject(parent), m_temperature(qQNaN()), m_humidity(-1)
{
    manager = new QNetworkAccessManager(this);
    connect(&m_timer, &QTimer::timeout, this, &Info::updateTemperature);
    m_timer.start(60000); // update every 60 sec

    updateTemperature(); // fetch immediately
}

Info::~Info(){}

double Info::temperature() const { return m_temperature; }
int Info::humidity() const { return m_humidity; }

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
                double newTemp = current["temp_c"].toDouble();
                int newHum = current["humidity"].toInt();

                if(newTemp != m_temperature){
                    m_temperature = newTemp;
                    emit temperatureChanged();
                }
                if(newHum != m_humidity){
                    m_humidity = newHum;
                    emit humidityChanged();
                }
            }
        } else {
            qWarning() << "Weather API error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}