import QtQuick

Rectangle {
    id: bluetoothPage
    anchors.fill: parent
    color: "transparent"

    Column {
        id: bluetoothColumn
        spacing: parent.height / 30
        anchors.horizontalCenter: parent.horizontalCenter
        padding: parent.height * 0.08

        Text {
            text: qsTr("Bluetooth Devices")
            font.pixelSize: bluetoothPage.width / 15
            color: '#ffedea'
            font.bold: true
            font.family: "Arial"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}