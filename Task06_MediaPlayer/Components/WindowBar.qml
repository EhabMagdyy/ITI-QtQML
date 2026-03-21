import QtQuick
import QtQuick.Window

Rectangle {
    id: titleBar
    width: parent.width - 20
    height: parent.height / 20
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    color: '#002a31'
    opacity: 0.7
    anchors.topMargin: 10
    anchors.rightMargin: 10
    anchors.leftMargin: 10
    topLeftRadius: 15
    topRightRadius: 15
    bottomLeftRadius: 15
    bottomRightRadius: 15

    required property var window

    Behavior on opacity {NumberAnimation {duration: 120}}

    MouseArea {
        anchors.fill: parent
        onPressed: titleBar.window.startSystemMove()
        hoverEnabled: true
        onEntered: titleBar.opacity = 1
        onExited: titleBar.opacity = 0.7
    }

    Text {
        anchors.centerIn: parent
        text: "Media Player"
        color: "white"
        font.bold: true
        font.family: "Arial"
        font.pointSize: titleBar.height / 2.2
    }

    Text {
        text: "−"
        color: "white"
        font.bold: true
        font.family: "Arial"
        font.pointSize: titleBar.height / 2.5
        anchors { right: maximizeBtn.left; rightMargin: titleBar.width / 70; verticalCenter: parent.verticalCenter }
        MouseArea {
            anchors.fill: parent
            onClicked: titleBar.window.showMinimized()
            hoverEnabled: true
            onEntered: parent.scale = 1.1
            onExited: parent.scale = 1.0
        }
    }

    Text {
        id: maximizeBtn
        text: titleBar.window.visibility === Window.Maximized ? "❐" : "□"
        color: "white"
        font.bold: true
        font.family: "Arial"
        font.pointSize: titleBar.height / 2.5
        anchors { right: closeBtn.left; rightMargin: titleBar.width / 70; verticalCenter: parent.verticalCenter }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (titleBar.window.visibility === Window.Maximized)
                    titleBar.window.showNormal()
                else
                    titleBar.window.showMaximized()
            }
            hoverEnabled: true
            onEntered: parent.scale = 1.1
            onExited: parent.scale = 1.0
        }
    }

    Text {
        id: closeBtn
        text: "x"
        color: "white"
        font.bold: true
        font.family: "Arial"
        font.pointSize: titleBar.height / 2.5
        anchors { right: parent.right; rightMargin: titleBar.width / 55; verticalCenter: parent.verticalCenter }
        MouseArea {
            anchors.fill: parent
            onClicked: titleBar.window.close()
            hoverEnabled: true
            onEntered: parent.scale = 1.1
            onExited: parent.scale = 1.0
        }
    }
}