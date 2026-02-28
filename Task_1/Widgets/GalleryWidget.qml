import QtQuick
import QtQuick.Controls

Rectangle {
    id: galleryWidget
    property StackView stackView
    property Component galleryPage

    width: parent.width / 1.6
    height: 60
    anchors.horizontalCenter: parent.horizontalCenter
    color: '#e8fffb00'
    radius: 10
    border.color: '#ffffff'
    border.width: 2

    Row {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Gallery"
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 25
            color: "black"
            font.bold: true
        }
        Image {
            source: "qrc:/images/galleryIcon.png"
            width: 60
            height: 60
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: galleryWidget.color = '#fdff8b'
        onExited: galleryWidget.color = '#e8fffb00'
        onClicked: {
            galleryWidget.stackView.push(galleryWidget.galleryPage)
        }
    }
}