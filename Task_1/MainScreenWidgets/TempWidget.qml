import QtQuick
import QtQuick.Controls

Item {
    id: tempWidget
    width: 150
    height: 150
    anchors.verticalCenter: parent.verticalCenter

    property real temperature: 28   // change this from backend

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#121212"
        border.color: "#2a2a2a"
    }

    // Background ring
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 6
        border.color: "#2a2a2a"
    }

    // Foreground ring (progress)
    Rectangle {
        width: parent.width
        height: parent.height
        radius: width / 2
        color: "transparent"
        border.width: 6
        border.color: "#d60f0f"
        opacity: tempWidget.temperature / 50.0   // max temp = 50°C (adjust)
    }

    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: Math.round(tempWidget.temperature) + "°C"
            font.pixelSize: 28
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            color: "white"
        }

        Text {
            text: "Temperature"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            color: "#c9c9c9"
        }
    }
}