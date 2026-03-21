import QtQuick
import QtQuick.Controls

Rectangle {
    id: audioPage
    required property StackView stackView
    anchors.fill: parent
    color: "transparent"

    // ============================================ Back button ===============================================
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: audioPage.height / 15
        anchors.leftMargin: audioPage.width / 25
        width: backText.width + 40
        height: backText.height + 18
        radius: height / 1.5
        color: backArea.containsMouse ? "#1a3a40" : '#204d55'
        border.color: "#00ffaa44"
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            id: backText
            anchors.centerIn: parent
            text: "Back"
            color: '#e7f1ef'
            font.pixelSize: audioPage.width / 60
            font.family: "Arial"
            font.bold: true
        }

        MouseArea {
            id: backArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                audioPage.stackView.pop()
            }
        }
    }
}