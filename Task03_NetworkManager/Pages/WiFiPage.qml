import QtQuick
import QtQuick.Controls

Rectangle {
    id: wifiPage
    anchors.fill: parent
    color: "transparent"
    required property StackView stackView

    // Main Content Column
    Column {
        id: wifiPageCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: wifiPage.width * 0.06
        anchors.topMargin: wifiPage.height * 0.05
        anchors.bottomMargin: wifiPage.height * 0.05
        spacing: wifiPage.height * 0.02

        // Page Title
        Text {
            text: qsTr("Wi-Fi Settings")
            font.pixelSize: wifiPage.width / 22
            color: '#ffedea'
            font.bold: true
            font.family: "Arial"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: '#ff6c55'
            opacity: 0.5
        }

        // Wi-Fi Toggle Card
        Rectangle {
            width: parent.width
            height: wifiPage.height / 10
            radius: height / 4
            gradient: Gradient {
                GradientStop { position: 0.0; color: '#2a0a08' }
                GradientStop { position: 1.0; color: '#1a0504' }
            }
            border.color: wifiSwitch.checked ? '#ff6c55' : '#5a2a25'
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.leftMargin: parent.width * 0.05
                anchors.rightMargin: parent.width * 0.05

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - wifiSwitch.width - parent.anchors.leftMargin - parent.anchors.rightMargin
                    spacing: 2
                    Text {
                        text: qsTr("Wi-Fi")
                        font.pixelSize: wifiPage.height * 0.025
                        color: '#ffedea'
                        font.bold: true
                        font.family: "Arial"
                    }
                    Text {
                        text: wifiSwitch.checked ? qsTr("ON") : qsTr("OFF")
                        font.pixelSize: wifiPage.height * 0.022
                        color: wifiSwitch.checked ? '#ff8a7a' : '#7a4a45'
                        font.family: "Arial"
                    }
                }

                Switch {
                    id: wifiSwitch
                    anchors.verticalCenter: parent.verticalCenter
                    checked: false
                }
            }
        }

        // Scan Button
        Rectangle {
            width: parent.width
            height: wifiPage.height / 12
            radius: height / 4
            opacity: wifiSwitch.checked ? 1.0 : 0.4
            gradient: Gradient {
                GradientStop { id: stop11; position: 0.0; color: '#ff8a7a' }
                GradientStop { id: stop12; position: 1.0; color: '#e95441' }
            }
            border.color: '#ffb3a9'
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: parent.width * 0.03

                Text {
                    text: "⟳"
                    font.pixelSize: parent.parent.height * 0.45
                    color: '#fff5f3'
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: qsTr("Scan for Networks")
                    font.pixelSize: parent.parent.height * 0.38
                    color: '#fff5f3'
                    font.bold: true
                    font.family: "Arial"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: scanArea
                anchors.fill: parent
                enabled: wifiSwitch.checked
                hoverEnabled: true
                onEntered: {
                    stop11.color = '#cc4433'
                    stop12.color = '#aa2211'
                }
                onExited: {
                    stop11.color = '#ff8a7a'
                    stop12.color = '#e95441'
                }
                onClicked: {
                    // TODO: trigger backend network scan
                    // result in list of networks to display in popup page
                }
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: '#ff6c55'
            opacity: 0.3
        }

        // Connect Card
        Rectangle {
            width: parent.width
            height: connectCol.implicitHeight + wifiPage.height * 0.1
            radius: wifiPage.height * 0.02
            opacity: wifiSwitch.checked ? 1.0 : 0.4
            gradient: Gradient {
                GradientStop { position: 0.0; color: '#2a0a08' }
                GradientStop { position: 1.0; color: '#1a0504' }
            }
            border.color: '#5a2a25'
            border.width: 2

            Column {
                id: connectCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: wifiPage.width * 0.03
                spacing: wifiPage.height * 0.018

                Text {
                    text: qsTr("Connect to Network")
                    font.pixelSize: wifiPage.height * 0.03
                    color: '#ffedea'
                    font.bold: true
                    font.family: "Arial"
                }

                // SSID Field
                Rectangle {
                    width: parent.width
                    height: wifiPage.height / 13
                    radius: height / 4
                    color: '#0d0302'
                    border.color: ssidField.activeFocus ? '#ff6c55' : '#5a2a25'
                    border.width: ssidField.activeFocus ? 2 : 1

                    TextInput {
                        id: ssidField
                        anchors.fill: parent
                        anchors.leftMargin: parent.width * 0.05
                        anchors.rightMargin: parent.width * 0.05
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: parent.height * 0.38
                        color: '#ffedea'
                        font.family: "Arial"
                        enabled: wifiSwitch.checked
                        clip: true
                        // hint text
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Network Name (SSID)")
                            font.pixelSize: parent.height * 0.38
                            color: '#7a4a45'
                            font.family: "Arial"
                            visible: !ssidField.text && !ssidField.activeFocus
                        }
                    }
                }

                // Password Field
                Rectangle {
                    width: parent.width
                    height: wifiPage.height / 13
                    radius: height / 4
                    color: '#0d0302'
                    border.color: passField.activeFocus ? '#ff6c55' : '#5a2a25'
                    border.width: passField.activeFocus ? 2 : 1

                    TextInput {
                        id: passField
                        anchors.fill: parent
                        anchors.leftMargin: parent.width * 0.05
                        anchors.rightMargin: parent.width * 0.05
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: parent.height * 0.38
                        color: '#ffedea'
                        font.family: "Arial"
                        echoMode: TextInput.Password
                        enabled: wifiSwitch.checked
                        clip: true
                        // hint text
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Password")
                            font.pixelSize: parent.height * 0.38
                            color: '#7a4a45'
                            font.family: "Arial"
                            visible: !passField.text && !passField.activeFocus
                        }
                    }
                }

                // Connect Button
                Rectangle {
                    width: parent.width
                    height: wifiPage.height / 12
                    radius: height / 4
                    gradient: Gradient {
                        GradientStop { id: stop1; position: 0.0; color: connectArea.pressed ? '#cc4433' : '#ff6c55' }
                        GradientStop { id: stop2; position: 1.0; color: connectArea.pressed ? '#aa2211' : '#c94030' }
                    }
                    border.color: '#ffb3a9'
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Connect")
                        font.pixelSize: parent.height * 0.38
                        color: '#fff5f3'
                        font.bold: true
                        font.family: "Arial"
                    }

                    MouseArea {
                        id: connectArea
                        anchors.fill: parent
                        enabled: wifiSwitch.checked
                        hoverEnabled: true
                        onEntered: {
                            stop1.color = '#cc4433'
                            stop2.color = '#aa2211'
                        }
                        onExited: {
                            stop1.color = '#ff6c55'
                            stop2.color = '#c94030'
                        }
                        onClicked: {
                            if(ssidField.text !== "" && passField.text !== "" && passField.length >= 8) {
                                // Pass ssidField.text + passField.text to backend
                                console.log("Connecting to network:", ssidField.text)
                                console.log("Password:", passField.text)
                            } 
                            else {
                                console.log("Please enter a valid SSID and password!")
                            }
                        }
                    }
                }
            }
        }
    }

    // Return to Main Page Button
    Rectangle {
        width: parent.width / 6.5
        height: parent.height / 15
        color: '#fffaf8'
        radius: height / 4
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: parent.height * 0.05
        anchors.leftMargin: parent.width * 0.05
        border.color: '#f3614e'
        border.width: 2

        Text {
            text: qsTr("Back")
            font.pixelSize: height * 0.8
            color: '#8a1000'
            font.bold: true
            font.family: "Arial"
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color = '#ffd4ce'
            onExited: parent.color = '#fffaf8'
            onClicked: wifiPage.stackView.pop()
        }
    }
}