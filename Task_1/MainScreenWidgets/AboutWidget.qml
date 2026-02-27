import QtQuick
import QtQuick.Controls

Rectangle {
    id: aboutWidget
    property Popup aboutPopup

    width: parent.width / 2
    height: 40
    anchors.horizontalCenter: parent.horizontalCenter
    radius: 10
    color: '#d3ffffff'
    opacity: 0.5
    border.width: 2
    Row{
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "about"
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 22
            color: "white"
            font.bold: true
        }
        Image {
            source: "qrc:/images/aboutIcon.png"
            width: 40
            height: 40
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: aboutWidget.aboutPopup.open()
    }
}