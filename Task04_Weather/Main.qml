import QtQuick
import QtQuick.Controls
import QtQuick.Window

pragma ComponentBehavior: Bound

ApplicationWindow {
    id: mainWindow
    width: Screen.width
    height: Screen.height
    visible: true
    title: qsTr("Weather")
    flags: Qt.FramelessWindowHint | Qt.Window

    // app background image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/images/weatherbackground.jpg"
    }
    // my custom app window bar
    WindowBar {
        id: titleBar
        z: 1
        window: mainWindow
    }
    // Handle window resizing
    WindowResize {
        z: 2
        window: mainWindow
    }

    // =============================== Weather code > emoji helper ===============================
    function weatherEmoji(code, isDay) {
        if (code === 0)                    return isDay ? "☀️"  : "🌙"
        if (code <= 2)                     return isDay ? "🌤️" : "🌙"
        if (code === 3)                    return "☁️"
        if (code <= 48)                    return "🌫️"
        if (code <= 55)                    return "🌦️"
        if (code <= 57)                    return "🌧️"
        if (code <= 65)                    return "🌧️"
        if (code <= 67)                    return "🌨️"
        if (code <= 75)                    return "❄️"
        if (code <= 77)                    return "🌨️"
        if (code <= 82)                    return "🌦️"
        if (code <= 86)                    return "❄️"
        if (code <= 99)                    return "⛈️"
        return "🌡️"
    }

    // =========================================== Models ===========================================

    ListModel {
        id: weatherInfoModel
        ListElement { label: "Wind Speed";     emoji: "💨"; value: "12 km/h"  }
        ListElement { label: "Humidity";       emoji: "💧"; value: "65%"      }
        ListElement { label: "Wind Direction"; emoji: "🧭"; value: "270°"     }
        ListElement { label: "Pressure";       emoji: "🔵"; value: "1013 hPa" }
    }

    ListModel {
        id: hourlyWeatherModel
        ListElement { time: "12 AM"; temp: "19°C" }
        ListElement { time: "1 AM";  temp: "18°C" }
        ListElement { time: "2 AM";  temp: "18°C" }
        ListElement { time: "3 AM";  temp: "17°C" }
        ListElement { time: "4 AM";  temp: "17°C" }
        ListElement { time: "5 AM";  temp: "17°C" }
        ListElement { time: "6 AM";  temp: "18°C" }
        ListElement { time: "7 AM";  temp: "19°C" }
        ListElement { time: "8 AM";  temp: "21°C" }
        ListElement { time: "9 AM";  temp: "23°C" }
        ListElement { time: "10 AM"; temp: "25°C" }
        ListElement { time: "11 AM"; temp: "27°C" }
        ListElement { time: "12 PM"; temp: "29°C" }
        ListElement { time: "1 PM";  temp: "30°C" }
        ListElement { time: "2 PM";  temp: "31°C" }
        ListElement { time: "3 PM";  temp: "31°C" }
        ListElement { time: "4 PM";  temp: "30°C" }
        ListElement { time: "5 PM";  temp: "28°C" }
        ListElement { time: "6 PM";  temp: "26°C" }
        ListElement { time: "7 PM";  temp: "24°C" }
        ListElement { time: "8 PM";  temp: "23°C" }
        ListElement { time: "9 PM";  temp: "22°C" }
        ListElement { time: "10 PM"; temp: "21°C" }
        ListElement { time: "11 PM"; temp: "20°C" }
    }

    ListModel {
        id: dailyWeatherModel
        ListElement { day: "Sunday";    uvIndex: 2.1; maxTemp: "26°C"; minTemp: "15°C" }
        ListElement { day: "Monday";    uvIndex: 2.5; maxTemp: "27°C"; minTemp: "17°C" }
        ListElement { day: "Tuesday";   uvIndex: 4.0; maxTemp: "28°C"; minTemp: "17°C" }
        ListElement { day: "Wednesday"; uvIndex: 4.6; maxTemp: "27°C"; minTemp: "17°C" }
        ListElement { day: "Thursday";  uvIndex: 5.9; maxTemp: "29°C"; minTemp: "18°C" }
        ListElement { day: "Friday";    uvIndex: 7.1; maxTemp: "32°C"; minTemp: "20°C" }
        ListElement { day: "Saturday";  uvIndex: 8.5; maxTemp: "33°C"; minTemp: "21°C" }
    }

    // ===================================== Main Layout =====================================

    Column {
        width: parent.width
        anchors.top: titleBar.bottom
        anchors.topMargin: mainWindow.height * 0.028
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: mainWindow.height * 0.03

        // ===================================== Search field =====================================
        TextField {
            id: cityInput
            width: mainWindow.width * 0.22
            height: mainWindow.height * 0.055
            placeholderText: "🔍 Enter city name..."
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: mainWindow.height * 0.016
            font.family: "Arial"
            color: "white"
            placeholderTextColor: "#aaaaaa"
            leftPadding: mainWindow.width * 0.012
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true

            background: Rectangle {
                color: "#1a1a2e"
                radius: mainWindow.height * 0.027
                border.color: cityInput.activeFocus ? "#4fc3f7" : "#444466"
                border.width: cityInput.activeFocus ? 2 : 1
                layer.enabled: cityInput.activeFocus
                layer.effect: null
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on border.width { NumberAnimation { duration: 200 } }
            }

            onActiveFocusChanged: {
                if (activeFocus && text === "")
                    placeholderText = ""
                else if (!activeFocus && text === "")
                    placeholderText = "🔍  Enter city name..."
            }
            // when user presses Enter, trigger the API call to fetch weather data for the entered city
            Keys.onReturnPressed: weatherAPI.fetch(cityInput.text)
        }

        // ===================================== Main weather info ──────=====================================───────────────────────────────────────────
        Rectangle {
            id: mainInfoContainer
            width: mainWindow.width * 0.8
            height: mainWindow.height * 0.13
            color: '#12495f'
            opacity: 0.8
            radius: mainWindow.height * 0.025
            anchors.horizontalCenter: parent.horizontalCenter

            // Main weather info layout
            Row {
                anchors.centerIn: parent
                spacing: mainWindow.width * 0.03

                // Weather emoji
                Text {
                    id: weatherEmoji
                    text: "🌤️"
                    font.pointSize: mainWindow.height * 0.065
                    anchors.verticalCenter: parent.verticalCenter
                }

                // line Separator
                Rectangle {
                    width: 1
                    height: mainWindow.height * 0.09
                    color: "#ffffff"
                    opacity: 0.3
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Description + temp
                Column {
                    spacing: mainWindow.height * 0.005
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: weatherDescription
                        text: "Partly Cloudy"
                        color: "white"
                        font.pointSize: mainWindow.height * 0.020
                        font.family: "Arial"
                    }
                    Text {
                        id: temperature
                        text: "21°C"
                        color: "white"
                        font.pointSize: mainWindow.height * 0.040
                        font.family: "Arial"
                        font.bold: true
                    }
                }

                // Spacer
                Item {
                    width: mainWindow.width * 0.28
                    height: 1
                }

                // City + feels like
                Column {
                    spacing: mainWindow.height * 0.014
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: cityName
                        text: "El Mazarita, Egypt"
                        color: "white"
                        font.pointSize: mainWindow.height * 0.028
                        font.family: "Arial"
                        font.bold: true
                    }
                    Text {
                        id: feelsLike
                        text: "Feels like: 19°C"
                        color: '#ffffff'
                        font.pointSize: mainWindow.height * 0.02
                        font.family: "Arial"
                    }
                }
            }
        }

        // ===================================== Hourly forecast =====================================
        Rectangle {
            id: hourlyContainer
            width: mainWindow.width * 0.8
            height: mainWindow.height * 0.18
            color: '#12495f'
            opacity: 0.8
            radius: mainWindow.height * 0.025
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true

            Flickable {
                id: hourlyFlickable
                anchors.fill: parent
                anchors.margins: mainWindow.height * 0.02
                contentWidth: hourlyRow.width
                flickableDirection: Flickable.HorizontalFlick
                clip: true

                Row {
                    id: hourlyRow
                    spacing: mainWindow.width * 0.02
                    height: hourlyFlickable.height

                    Repeater {
                        id: hourlyRepeater
                        model: hourlyWeatherModel

                        delegate: Rectangle {
                            id: hourlyDelegate
                            required property string time
                            required property string temp
                            required property int    index

                            width: mainWindow.width * 0.08
                            height: hourlyRow.height
                            color: '#ffffff'
                            radius: mainWindow.height * 0.01
                            opacity: 0.5

                            Column {
                                anchors.horizontalCenter: parent.horizontalCenter
                                topPadding: parent.height * 0.1
                                spacing: mainWindow.height * 0.01

                                Text {
                                    text: hourlyDelegate.time
                                    color: "white"
                                    font.pointSize: mainWindow.height * 0.025
                                    font.family: "Arial"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: hourlyDelegate.temp
                                    color: "white"
                                    font.pointSize: mainWindow.height * 0.035
                                    font.bold: true
                                    font.family: "Arial"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }
        }

        // ===================================== Weekly forecast + weather details =====================================
        Row {
            id: weatherDetailsRow
            spacing: mainWindow.width * 0.05
            anchors.horizontalCenter: parent.horizontalCenter

            // ===================================== Weekly forecast =====================================
            Rectangle {
                id: weeklyContainer
                width: mainWindow.width * 0.4
                height: mainWindow.height * 0.45
                color: '#12495f'
                opacity: 0.8
                radius: mainWindow.height * 0.025

                Column {
                    anchors.centerIn: parent
                    spacing: mainWindow.height * 0.015
                    width: weeklyContainer.width - mainWindow.height * 0.04

                    // Header row
                    Row {
                        width: parent.width

                        Text {
                            text: "Day"
                            color: "#aaaaaa"
                            font.pointSize: mainWindow.height * 0.018
                            font.family: "Arial"
                            font.bold: true
                            width: parent.width * 0.25
                        }
                        Text {
                            text: "UV"
                            color: "#aaaaaa"
                            font.pointSize: mainWindow.height * 0.018
                            font.family: "Arial"
                            font.bold: true
                            width: parent.width * 0.3
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            text: "Max / Min"
                            color: "#aaaaaa"
                            font.pointSize: mainWindow.height * 0.018
                            font.family: "Arial"
                            font.bold: true
                            width: parent.width * 0.45
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // Separator
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#ffffff"
                        opacity: 0.25
                    }

                    // Day rows
                    Repeater {
                        model: dailyWeatherModel

                        delegate: Row {
                            id: dailyRow
                            required property string day
                            required property string maxTemp
                            required property string minTemp
                            required property var    uvIndex

                            width: weeklyContainer.width - mainWindow.height * 0.04

                            Text {
                                text: dailyRow.day
                                color: "white"
                                font.pointSize: mainWindow.height * 0.022
                                font.family: "Arial"
                                font.bold: true
                                width: parent.width * 0.25
                            }
                            Text {
                                text: {
                                    var uv = Math.round(dailyRow.uvIndex)
                                    if      (uv <= 2)  return "🌤 " + dailyRow.uvIndex
                                    else if (uv <= 5)  return "☀️ " + dailyRow.uvIndex
                                    else if (uv <= 7)  return "🌞 " + dailyRow.uvIndex
                                    else if (uv <= 10) return "🔆 " + dailyRow.uvIndex
                                    else               return "🔥 " + dailyRow.uvIndex
                                }
                                color: {
                                    var uv = Math.round(dailyRow.uvIndex)
                                    if      (uv <= 2)  return "#a8d8a8"
                                    else if (uv <= 5)  return "#f9e07a"
                                    else if (uv <= 7)  return "#f4a445"
                                    else if (uv <= 10) return "#e05a5a"
                                    else               return "#c060c0"
                                }
                                font.pointSize: mainWindow.height * 0.020
                                font.family: "Arial"
                                font.bold: true
                                width: parent.width * 0.3
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: dailyRow.maxTemp + " / " + dailyRow.minTemp
                                color: "white"
                                font.pointSize: mainWindow.height * 0.020
                                font.family: "Arial"
                                horizontalAlignment: Text.AlignRight
                                width: parent.width * 0.45
                            }
                        }
                    }
                }
            }

            // ===================================== Weather details grid =====================================
            Grid {
                columns: 2
                width: mainWindow.width * 0.35
                height: mainWindow.height * 0.45
                rowSpacing: mainWindow.height * 0.02
                columnSpacing: mainWindow.width * 0.02

                Repeater {
                    model: weatherInfoModel

                    delegate: Rectangle {
                        id: infoDelegate
                        required property var modelData
                        width: (mainWindow.width * 0.35 - mainWindow.width * 0.02) / 2
                        height: (mainWindow.height * 0.45 - mainWindow.height * 0.02) / 2
                        color: '#12495f'
                        opacity: 0.8
                        radius: mainWindow.height * 0.015

                        Column {
                            anchors.centerIn: parent
                            spacing: mainWindow.height * 0.008

                            // Emoji
                            Text {
                                text: infoDelegate.modelData.emoji
                                font.pointSize: mainWindow.height * 0.030
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            // Label
                            Text {
                                text: infoDelegate.modelData.label
                                color: "#aaaaaa"
                                font.pointSize: mainWindow.height * 0.016
                                font.family: "Arial"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            // Value
                            Text {
                                text: infoDelegate.modelData.value
                                color: "white"
                                font.pointSize: mainWindow.height * 0.022
                                font.family: "Arial"
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // ===================================== API =====================================

    WeatherAPI {
        id: weatherAPI

        onWeatherReceived: function(current, daily, hourly, location) {
            cityName.text        = location.name + ", " + location.country
            temperature.text     = Math.round(current.temperature_2m) + "°C"
            feelsLike.text       = "Feels like: " + Math.round(current.apparent_temperature) + "°C"
            weatherEmoji.text    = mainWindow.weatherEmoji(current.weather_code, current.is_day)

            // Update description from weather code
            var code = current.weather_code
            if      (code === 0)          weatherDescription.text = current.is_day ? "Clear Sky" : "Clear Night"
            else if (code <= 2)           weatherDescription.text = "Partly Cloudy"
            else if (code === 3)          weatherDescription.text = "Overcast"
            else if (code <= 48)          weatherDescription.text = "Foggy"
            else if (code <= 55)          weatherDescription.text = "Drizzle"
            else if (code <= 65)          weatherDescription.text = "Rainy"
            else if (code <= 75)          weatherDescription.text = "Snowy"
            else if (code <= 82)          weatherDescription.text = "Rain Showers"
            else if (code <= 99)          weatherDescription.text = "Thunderstorm"

            weatherInfoModel.setProperty(0, "value", Math.round(current.wind_speed_10m)   + " km/h")
            weatherInfoModel.setProperty(1, "value", current.relative_humidity_2m         + "%")
            weatherInfoModel.setProperty(2, "value", current.wind_direction_10m           + "°")
            weatherInfoModel.setProperty(3, "value", Math.round(current.surface_pressure) + " hPa")

            // Hourly
            hourlyWeatherModel.clear()
            for (var i = 0; i < 24; i++) {
                var amPm = i < 12 ? "AM" : "PM"
                var hour = i % 12 === 0 ? "12" : (i % 12).toString()
                hourlyWeatherModel.append({
                    "time": hour + " " + amPm,
                    "temp": Math.round(hourly.temperature_2m[i]) + "°C"
                })
            }

            // Daily
            var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            dailyWeatherModel.clear()
            for (var j = 0; j < daily.time.length; j++) {
                var date = new Date(daily.time[j])
                dailyWeatherModel.append({
                    "day":     j === 0 ? "Today" : j === 1 ? "Tomorrow" : dayNames[date.getDay()],
                    "maxTemp": Math.round(daily.temperature_2m_max[j]) + "°C",
                    "minTemp": Math.round(daily.temperature_2m_min[j]) + "°C",
                    "uvIndex": daily.uv_index_max[j]
                })
            }
        }

        onCityNotFound: function(city) {
            cityName.text           = "⚠️ \"" + city + "\" not found"
        }

        onNetworkError: function(message) {
            cityName.text           = "⚠️ Network error"
        }
    }
}