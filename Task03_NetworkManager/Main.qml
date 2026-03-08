import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: mainWindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Network Manager")

    property real fontSize: (width + height) / 60
    
    Rectangle {
        id: background
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: '#530000' }
            GradientStop { position: 0.5; color: '#ff3c00' }
            GradientStop { position: 1.0; color: '#ff8615' }
        }

        Column{
            id: app
            spacing: parent.height / 48
            anchors.horizontalCenter: parent.horizontalCenter
            padding: parent.height * 0.08
            Text {
                text: qsTr("Network Manager")
                font.pixelSize: mainWindow.fontSize * 1.8
                color: '#ffedea'
                font.bold: true
                font.family: "Arial"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: qsTr("Manage your Wi-Fi & Bluetooth connections with ease")
                font.pixelSize: mainWindow.fontSize * 0.7
                color: '#ffd0be'
                font.italic: true
                font.family: "Arial"
                verticalAlignment: Text.AlignBottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                height: mainWindow.height / 9
                width: 1
                color: "transparent"
            }

            Row {
                id: cardRow
                spacing: mainWindow.width / 15
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle{
                    id: wifiContainer
                    width: mainWindow.width / 4
                    height: mainWindow.height / 2.5

                    property color first: '#ffa845'
                    property color second: '#ff7654'
                    property color third: '#ff4545'

                    gradient: Gradient {
                        GradientStop {position: 0.0; color: wifiContainer.first }
                        GradientStop {position: 0.5; color: wifiContainer.second }
                        GradientStop {position: 1.0; color: wifiContainer.third }
                    }
                    radius: cardRow.spacing / 3
                    border.color: '#ffac7c'
                    border.width: 3
                    opacity: 0.8
                    Column{
                        anchors.centerIn: parent
                        spacing: parent.height / 20
                        Image{
                            source: "qrc:/images/wifi.png"
                            width: wifiContainer.width / 1.8
                            height: wifiContainer.width / 1.8
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                        Text{
                            text: qsTr("Wi-Fi")
                            font.pixelSize: mainWindow.fontSize * 1.2
                            color: '#252525'
                            font.bold: true
                            font.family: "Arial"
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            console.log("Wi-Fi card clicked")
                        }
                        onEntered: {
                            wifiContainer.first = Qt.lighter(wifiContainer.first, 1.2)
                            wifiContainer.second = Qt.lighter(wifiContainer.second, 1.2)
                            wifiContainer.third = Qt.lighter(wifiContainer.third, 1.2)
                        }
                        onExited: {
                            wifiContainer.first = '#ffa845'
                            wifiContainer.second = '#ff7654'
                            wifiContainer.third = '#ff4545'
                        }
                    }
                }
                
                Rectangle{
                    id: btContainer
                    width: mainWindow.width / 4
                    height: mainWindow.height / 2.5
                    property color first: '#ffa845'
                    property color second: '#ff7654'
                    property color third: '#ff4545'

                    gradient: Gradient {
                        GradientStop {position: 0.0; color: btContainer.first }
                        GradientStop {position: 0.5; color: btContainer.second }
                        GradientStop {position: 1.0; color: btContainer.third }
                    }
                    radius: cardRow.spacing / 3
                    border.color: '#ffac7c'
                    border.width: 3
                    opacity: 0.8
                    Column{
                        anchors.centerIn: parent
                        spacing: parent.height / 20
                        Image{
                            source: "qrc:/images/bt.png"
                            width: btContainer.width / 2.2
                            height: btContainer.width / 2.2
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                        Rectangle{
                            width: parent.width
                            height: btContainer.height / 24
                            color: "transparent"
                        }
                        Text{
                            text: qsTr("Bluetooth")
                            font.pixelSize: mainWindow.fontSize * 1.1
                            color: '#252525'
                            font.bold: true
                            font.family: "Arial"
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            console.log("Bluetooth card clicked")
                        }
                        onEntered: {
                            btContainer.first = Qt.lighter(btContainer.first, 1.2)
                            btContainer.second = Qt.lighter(btContainer.second, 1.2)
                            btContainer.third = Qt.lighter(btContainer.third, 1.2)
                        }
                        onExited: {
                            btContainer.first = '#ffa845'
                            btContainer.second = '#ff7654'
                            btContainer.third = '#ff4545'
                        }
                    }
                }
            }
        }
    }
}
