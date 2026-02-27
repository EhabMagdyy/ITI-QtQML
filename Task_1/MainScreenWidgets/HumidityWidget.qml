import QtQuick
import QtQuick.Controls

Item {
    id: humWidget
    width: 140
    height: 200

    property real humidity: 62

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#121212"
        border.color: "#2a2a2a"
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
            color: "#3fa9f5"
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
            color: "white"
        }

        Text {
            text: "Humidity"
            font.pixelSize: 12
            color: "#c9c9c9"
        }
    }
}