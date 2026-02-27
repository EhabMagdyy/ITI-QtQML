import QtQuick
import QtQuick.Controls

Popup {
    id: imagePopup

    property int imageIndex: -1
    property string titleText: ""
    property string description: ""
    property string color: ""
    property string price: ""
    property string year: ""

    modal: true
    focus: true
    anchors.centerIn: parent
    width: 450
    height: 350

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
        color: '#f5dddddd'
        radius: 16
        border.color: '#8f4e4d00'
        border.width: 2
    }

    Column {
        anchors.centerIn: parent
        spacing: 12
        width: parent.width * 0.9
        height: parent.height * 0.9

        Text {
            id: titleTextItem
            text: imagePopup.titleText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            font.bold: true
            color: '#440000'
        }

        Rectangle {
            width: titleTextItem.width + 10
            height: 2
            opacity: 0.3
            color: '#440000'
            anchors.horizontalCenter: titleTextItem.horizontalCenter
        }

        Text {
            text: imagePopup.description
            width: parent.width * 0.9
            font.pixelSize: 18
            font.family: "Arial"
            wrapMode: Text.WordWrap
            color: '#85333200'
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: "Color: " + imagePopup.color
            width: parent.width * 0.9
            font.pixelSize: 19
            font.family: "Arial"
            color: "#440000"
            anchors.leftMargin: 20
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            text: "Price: " + imagePopup.price
            width: parent.width * 0.9
            font.pixelSize: 19
            font.family: "Arial"
            color: "#440000"
            anchors.leftMargin: 20
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            text: "Year: " + imagePopup.year
            width: parent.width * 0.9
            font.pixelSize: 19
            font.family: "Arial"
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
                color: '#853f3e00'
                radius: 6
                opacity: 0.8
            }
            onClicked: imagePopup.close()

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.background.color = '#a22b0000'
                onExited: parent.background.color = '#853f3e00'
                onClicked: imagePopup.close()
            }
        }
    }
}