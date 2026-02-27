import QtQuick
import QtQuick.Controls

Popup {
    id: aboutPopup
    modal: true
    focus: true
    anchors.centerIn: parent
    width: 500
    height: 350

    background: Rectangle {
        color: "#111"
        radius: 16
        border.color: "#d60f0f"
        border.width: 2
    }

    Column {
        anchors.centerIn: parent
        spacing: 16
        width: parent.width * 0.9
        height: parent.height * 0.9

        Text {
            text: "about this app"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 26
            font.bold: true
            color: "#d60f0f"
        }

        Text {
            text: "Ferrari is an Italian luxury sports car manufacturer founded by Enzo Ferrari in 1939\nFamous for performance, Formula 1, and iconic cars\nThis app is dedicated to showcasing the iconic Ferrari brand, featuring a curated collection of Ferrari models along with detailed specifications and history. Our goal is to provide enthusiasts and collectors with an informative and visually engaging experience. Stay updated with the latest models and developments from the world of Ferrari."
            width: parent.width * 0.9
            font.pixelSize: 16
            font.family: "Arial"
            wrapMode: Text.WordWrap
            color: "white"
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            width: parent.width
            height: 10
            color: "transparent"
        }

        Button {
            text: "Close"
            font.pixelSize: 18
            width: 70
            anchors.horizontalCenter: parent.horizontalCenter
            background: Rectangle {
                color: '#e8fffb00'
                radius: 6
                opacity: 0.8
            }
            onClicked: aboutPopup.close()
        }
    }
}