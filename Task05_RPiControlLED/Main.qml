import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: mainWindow
    width: 640
    height: 480
    visible: true
    title: qsTr("LED Control")

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: '#ffefd7' }
            GradientStop { position: 1.0; color: '#ff9797' }
        }

        Column {
            spacing: mainWindow.height * 0.05
            anchors.centerIn: parent

            Text {
                text: "Control LED State"
                font.pointSize: (mainWindow.height + mainWindow.width) / 40
                color: "#333333"
                font.bold: true
                font.family: "Arial"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: mainWindow.width * 0.8
                height: mainWindow.height * 0.3
                radius: mainWindow.width * 0.05
                color: "#ffffff"
                opacity: 0.8
                border.color: "#cccccc"
                border.width: 3
                anchors.horizontalCenter: parent.horizontalCenter

                Row{
                    spacing: mainWindow.width * 0.05
                    anchors.centerIn: parent

                    Button {
                        text: "Turn ON"
                        width: mainWindow.width * 0.2
                        height: mainWindow.height * 0.1
                        font.pointSize: (width + height) / 11
                        font.bold: true
                            font.family: "Arial"
                            anchors.verticalCenter: parent.verticalCenter
                        background: Rectangle {
                            color: '#44eb02'
                            radius: 10
                        }
                        onClicked: {
                            console.log("LED turned ON")
                            ledController.turnOn()
                        }
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (hovered) {
                                scale = 1.1
                            } else {
                                scale = 1.0
                            }
                        }
                    }
                    Button {
                        text: "Turn OFF"
                        width: mainWindow.width * 0.2
                        height: mainWindow.height * 0.1
                        font.pointSize: (width + height) / 11
                        font.bold: true
                        font.family: "Arial"
                        anchors.verticalCenter: parent.verticalCenter
                        background: Rectangle {
                            color: '#ff0000'
                            radius: 10
                        }
                        onClicked: {
                            console.log("LED turned OFF")
                            ledController.turnOff()
                        }
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (hovered) {
                                scale = 1.1
                            } else {
                                scale = 1.0
                            }
                        }
                    }
                    Button {
                        text: "Toggle"
                        width: mainWindow.width * 0.2
                        height: mainWindow.height * 0.1
                        font.pointSize: (width + height) / 11
                        font.bold: true
                        font.family: "Arial"
                        anchors.verticalCenter: parent.verticalCenter
                        background: Rectangle {
                            color: '#0066ff'
                            radius: 10
                        }
                        onClicked: {
                            console.log("LED toggled")
                            ledController.toggle()
                        }
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (hovered) {
                                scale = 1.1
                            } else {
                                scale = 1.0
                            }
                        }
                    }
                }
            }
        }
    }
}
