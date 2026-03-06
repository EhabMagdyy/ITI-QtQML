import QtQuick
import QtQuick.Controls

Popup {
    id: aboutPopup
    modal: true
    focus: true
    anchors.centerIn: parent
    width: 500
    height: 400

    opacity: 0
    scale: 0.75

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.75; to: 1.0; duration: 300; easing.type: Easing.OutBack }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 220; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.75; duration: 220; easing.type: Easing.InBack }
        }
    }

    background: Rectangle {
        color: "#f5dddddd"
        radius: 16
        border.color: "#8f4e4d00"
        border.width: 2
    }

    Column {
        anchors.centerIn: parent
        spacing: 16
        width: parent.width * 0.9
        height: parent.height * 0.9

        Text {
            id: titleTextItem
            text: "about this app"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 26
            font.bold: true
            color: "#440000"
        }

        Rectangle {
            width: titleTextItem.width + 10
            height: 2
            opacity: 0.3
            color: '#440000'
            anchors.horizontalCenter: titleTextItem.horizontalCenter
        }

        Text {
            text: "Ferrari is an Italian luxury sports car manufacturer founded by Enzo Ferrari in 1939\nFamous for performance, Formula 1, and iconic cars\nThis app is dedicated to showcasing the iconic Ferrari brand, featuring a curated collection of Ferrari models along with detailed specifications and history. Our goal is to provide enthusiasts and collectors with an informative and visually engaging experience. Stay updated with the latest models and developments from the world of Ferrari."
            width: parent.width * 0.9
            font.pixelSize: 16
            font.family: "Arial"
            wrapMode: Text.WordWrap
            color: "#85333200"
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: "Author: Ehab Magdy"
            width: parent.width * 0.9
            font.pixelSize: 16
            font.family: "Arial"
            font.bold: true
            wrapMode: Text.WordWrap
            color: "#440000"
            anchors.leftMargin: 20
            horizontalAlignment: Text.AlignLeft
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
                color: '#85333200'
                radius: 6
                opacity: 0.8
            }
            onClicked: aboutPopup.close()

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.background.color = '#a22b0000'
                onExited: parent.background.color = '#85333200'
                onClicked: aboutPopup.close()
            }
        }
    }
}