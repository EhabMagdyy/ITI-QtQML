import QtQuick
import QtQuick.Controls

Rectangle {
    id: aboutWidget
    property Popup aboutPopup

    width: parent.width / 2
    height: 40
    anchors.horizontalCenter: parent.horizontalCenter
    radius: 10
    color: '#ffffff'
    opacity: 0.8
    border.width: 2

    Row{
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "about"
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 22
            color: "#000000"
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
        hoverEnabled: true
        onEntered: aboutWidget.color = '#b4fff2f2'
        onExited: aboutWidget.color = '#ffffff'
        onClicked: aboutWidget.aboutPopup.open()
    }
}