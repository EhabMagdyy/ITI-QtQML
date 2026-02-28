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
        color: "#f5dddddd"
        border.color: "#2a2a2a"
    }

    // Background ring
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 5
        border.color: "#2a2a2a"
    }

    // Foreground ring (progress)
    Rectangle {
        width: parent.width
        height: parent.height
        radius: width / 2
        color: "transparent"
        border.width: 6
        border.color: '#eaff8383'
        opacity: tempWidget.temperature / 50.0
    }

    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: Math.round(tempWidget.temperature) + "°C"
            font.pixelSize: 28
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            color: "#000000"
        }

        Text {
            text: "Temperature"
            font.pixelSize: 15
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            color: "#000000"
        }
    }
}