import QtQuick
import QtQuick.Controls

Item {
    id: humWidget
    width: 130
    height: 160

    property real humidity: info.humidity
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#f5dddddd"
        border.color: "#2a2a2a"
        border.width: 5
    }

    // Bar container
    Rectangle {
        width: 24
        height: parent.height - 80
        radius: 12
        color: "#1f1f1f"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20

        // Fill
        Rectangle {
            width: parent.width
            height: parent.height * (humWidget.humidity / 100)
            radius: 12
            color: '#0073c5'
            anchors.bottom: parent.bottom
        }
    }

    Column {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 12
        spacing: 4

        Text {
            text: Math.round(humWidget.humidity) + "%"
            font.pixelSize: 22
            font.bold: true
            color: "#440000"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Humidity"
            font.pixelSize: 15
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            color: "#000000"
        }
    }
}