import QtQuick
import QtQuick.Controls

Item {
    id: windWidget
    width: 160
    height: 160

    property real windSpeed: info.windSpeed
    property string windDir: info.windDir
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#f5dddddd"
        border.color: '#a8c7ba00'
        border.width: 5

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: "Wind Speed"
                    font.pixelSize: 17
                    font.bold: true
                    color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: Math.round(windWidget.windSpeed) + " kph"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#440000"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle{
                    width: 1
                    height: 10
                    color: "transparent"
                }

                Text {
                    text: "Wind Direction"
                    font.pixelSize: 17
                    font.bold: true
                    color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: windWidget.windDir
                    font.pixelSize: 22
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: true
                    color: "#440000"
                }
            }
    }
}