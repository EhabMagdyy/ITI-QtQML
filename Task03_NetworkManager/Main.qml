import QtQuick
import QtQuick.Controls
import "Pages"
pragma ComponentBehavior: Bound

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

        StackView{
            id: stackView
            anchors.fill: parent
            initialItem: mainPageComponent

            Component {
                id: mainPageComponent
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
                        id: subtitle
                        text: qsTr("Manage your Wi-Fi & Bluetooth connections with ease")
                        font.pixelSize: mainWindow.fontSize * 0.7
                        color: '#ffd0be'
                        font.italic: true
                        font.family: "Arial"
                        verticalAlignment: Text.AlignBottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Divider
                    Rectangle {
                        width: subtitle.width * 1.2
                        height: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: '#ff6c55'
                        opacity: 0.5
                    }

                    Rectangle {
                        height: mainWindow.height / 10
                        width: 1
                        color: "transparent"
                    }

                    Row {
                        id: cardRow
                        spacing: mainWindow.width / 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        NetworkCard{
                            cardWidth: mainWindow.width / 4
                            cardHeight: mainWindow.height / 2.5
                            cardColSpacing: cardHeight / 20
                            first: '#ffa845'
                            second: '#ff7654'
                            third: '#ff4545'
                            cardRadius: cardRow.spacing / 3
                            cardBorderColor: '#ffac7c'
                            cardBorderWidth: 3
                            cardOpacity: 0.8
                            cardText: qsTr("Wi-Fi")
                            cardIcon: "qrc:/images/wifi.png"
                            cardTextFontSize: mainWindow.fontSize * 1.1
                            cardTextFontFamily: "Arial"
                            cardTextColor: '#252525'
                            cardIconWidth: cardWidth / 1.8
                            cardIconHeight: cardHeight / 1.8

                            onCardClicked: stackView.push(wifiPageComponent)
                            onCardEntred: {
                                first = Qt.lighter(first, 1.2)
                                second = Qt.lighter(second, 1.2)
                                third = Qt.lighter(third, 1.2)
                            }
                            onCardExited: {
                                first = '#ffa845'
                                second = '#ff7654'
                                third = '#ff4545'
                            }
                        }
                        
                        NetworkCard{
                            cardWidth: mainWindow.width / 4
                            cardHeight: mainWindow.height / 2.5
                            cardColSpacing: cardHeight / 10
                            first: '#ffa845'
                            second: '#ff7654'
                            third: '#ff4545'
                            cardRadius: cardRow.spacing / 3
                            cardBorderColor: '#ffac7c'
                            cardBorderWidth: 3
                            cardOpacity: 0.8
                            cardText: qsTr("Bluetooth")
                            cardIcon: "qrc:/images/bt.png"
                            cardTextFontSize: mainWindow.fontSize
                            cardTextFontFamily: "Arial"
                            cardTextColor: '#252525'
                            cardIconWidth: cardWidth / 2.2
                            cardIconHeight: cardHeight / 2.2

                            onCardClicked: stackView.push(bluetoothPageComponent)
                            onCardEntred: {
                                first = Qt.lighter(first, 1.2)
                                second = Qt.lighter(second, 1.2)
                                third = Qt.lighter(third, 1.2)
                            }
                            onCardExited: {
                                first = '#ffa845'
                                second = '#ff7654'
                                third = '#ff4545'
                            }
                        }
                    }
                }
            }
        }
        Component {
            id: wifiPageComponent
            WiFiPage {
                id: wifiPage
                stackView: stackView
            }
        }

        Component {
            id: bluetoothPageComponent
            BluetoothPage {
                id: btPage
                stackView: stackView
            }
        }
    }
}
