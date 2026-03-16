import QtQuick
import QtQuick.Window

Rectangle {
    id: titleBar
    width: parent.width - 20
    height: 35
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    color: '#ffffff'
    opacity: 0.5
    anchors.topMargin: 10
    anchors.rightMargin: 10
    anchors.leftMargin: 10
    topLeftRadius: 15
    topRightRadius: 15
    bottomLeftRadius: 15
    bottomRightRadius: 15

    required property var window

    MouseArea {
        anchors.fill: parent
        onPressed: titleBar.window.startSystemMove()
    }

    Text {
        anchors.centerIn: parent
        text: "Weather"
        color: "black"
        font.bold: true
        font.family: "Arial"
        font.pointSize: 14
    }

    Text {
        text: "−"
        color: "black"
        font.bold: true
        font.family: "Arial"
        font.pointSize: 16
        anchors { right: maximizeBtn.left; rightMargin: 14; verticalCenter: parent.verticalCenter }
        MouseArea {
            anchors.fill: parent
            onClicked: titleBar.window.showMinimized()
        }
    }

    Text {
        id: maximizeBtn
        text: titleBar.window.visibility === Window.Maximized ? "❐" : "□"
        color: "black"
        font.bold: true
        font.family: "Arial"
        font.pointSize: 14
        anchors { right: closeBtn.left; rightMargin: 14; verticalCenter: parent.verticalCenter }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (titleBar.window.visibility === Window.Maximized)
                    titleBar.window.showNormal()
                else
                    titleBar.window.showMaximized()
            }
        }
    }

    Text {
        id: closeBtn
        text: "x"
        color: "black"
        font.bold: true
        font.family: "Arial"
        font.pointSize: 16
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        MouseArea {
            anchors.fill: parent
            onClicked: titleBar.window.close()
        }
    }
}