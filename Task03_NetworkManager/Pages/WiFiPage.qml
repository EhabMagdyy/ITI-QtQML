import QtQuick
import QtQuick.Controls

Rectangle {
    id: wifiPage
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    color: "transparent"
    required property StackView stackView
    
    // Backend Connections
    Connections {
        target: WifiManager

        function onWifiEnabledChanged(enabled) {
            wifiSwitch.checked = enabled
        }
        function onScanStarted() {
            console.log("Scanning for networks...")
        }
        function onScanFinished(networks) {
            networkListModel.clear()
            for (var i = 0; i < networks.length; i++)
                networkListModel.append({ "name": networks[i] })
            scanResultsPopup.open()
        }
        function onScanFailed(reason) {
            showToast("Scan failed: " + reason, true)
        }
        function onConnectSuccess(ssid) {
            showToast("Connected to " + ssid, false)
        }
        function onConnectFailed(reason) {
            showToast(reason, true)
        }
    }

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
                    checked: WifiManager.wifiEnabled
                    onCheckedChanged: WifiManager.wifiEnabled = checked 
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
                    WifiManager.scanNetworks()
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
                    text: qsTr("Connect to Hidden Networks")
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

                        Keys.onPressed: (event) => {
                            if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                console.log('Enter pressed > Connecting')
                                if(ssidField.text !== "" && passField.text !== "" && passField.text.length >= 8) {
                                    console.log("Connecting to network:", ssidField.text)
                                    WifiManager.connectToNetwork(ssidField.text, passField.text)
                                } 
                                else {
                                    console.log("Please enter a valid SSID and password!")
                                }
                                event.accepted = true   // prevent default behavior (like adding a newline)
                            }
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
                        onClicked: parent.onConnectHandler()
                    }
                    function onConnectHandler(){
                        if(ssidField.text !== "" && passField.text !== "" && passField.text.length >= 8) {
                            // Pass ssidField.text + passField.text to backend
                            console.log("Connecting to network:", ssidField.text)
                            console.log("Password:", passField.text)
                            WifiManager.connectToNetwork(ssidField.text, passField.text)
                        } 
                        else {
                            console.log("Please enter a valid SSID and password!")
                        }
                    }
                }
            }
        }
    }

    ListModel { id: networkListModel }

    Popup {
        id: scanResultsPopup
        width: parent.width * 0.8
        height: parent.height * 0.7
        anchors.centerIn: parent
        modal: true // prevents interaction with the background
        focus: true // ensures it receives key events
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside    // closed when ESC Clicked & ckicking outside

        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: '#1e0604' }
                GradientStop { position: 1.0; color: '#120302' }
            }
            radius: 10
            border.color: '#ff5f46'
            border.width: 2
        }

        Column {
            anchors.fill: parent
            anchors.margins: scanResultsPopup.width * 0.05
            spacing: scanResultsPopup.height * 0.015

            // Title Row
            Row {
                width: parent.width
                height: scanResultsPopup.height * 0.1

                Text {
                    text: qsTr("Available Networks")
                    font.pixelSize: scanResultsPopup.height * 0.05
                    color: '#ffedea'
                    font.bold: true
                    font.family: "Arial"
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - closeBtn.width
                }

                Rectangle {
                    id: closeBtn
                    width: scanResultsPopup.height * 0.08
                    height: width
                    radius: width / 2
                    color: closeBtnArea.containsMouse ? '#ff4422' : '#5a2a25'
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: parent.height * 0.5
                        color: '#ffedea'
                        font.family: "Arial"
                    }
                    MouseArea {
                        id: closeBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: scanResultsPopup.close()
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: '#ff5f46'
                opacity: 0.5
            }

            // Network count
            Text {
                text: networkListModel.count + qsTr(" networks found")
                font.pixelSize: scanResultsPopup.height * 0.032
                color: '#ff8a7a'
                font.family: "Arial"
            }

            // Scrollable list
            ListView {
                id: networkListView
                width: parent.width
                height: scanResultsPopup.height
                        - scanResultsPopup.height * 0.1     // title row
                        - 1                                  // divider
                        - scanResultsPopup.height * 0.032    // count text
                        - scanResultsPopup.width * 0.1       // top+bottom margins
                        - scanResultsPopup.height * 0.015 * 3 // spacings
                clip: true      // ensures content doesn't overflow
                model: networkListModel // input data for the list
                spacing: scanResultsPopup.height * 0.015

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: '#ff6c55'
                        opacity: 0.8
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: networkListView.count === 0
                    text: qsTr("No networks found.\nTry scanning again.")
                    font.pixelSize: scanResultsPopup.height * 0.04
                    color: '#7a4a45'
                    font.family: "Arial"
                    horizontalAlignment: Text.AlignHCenter
                }

                // Delegate > one card per network
                delegate: Rectangle {
                    width: networkListView.width - 8
                    height: scanResultsPopup.height * 0.11
                    radius: height / 4
                    color: rowHover.containsMouse ? '#3a1008' : '#200805'
                    border.color: rowHover.containsMouse ? '#ff6c55' : '#3a1a15'
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on border.color { ColorAnimation { duration: 100 } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: parent.width * 0.04
                        anchors.rightMargin: parent.width * 0.04
                        spacing: parent.width * 0.03

                        // Icon
                        Text {
                            text: "▲"
                            font.pixelSize: parent.parent.height * 0.4
                            color: '#ff8a7a'
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // SSID
                        Text {
                            text: model.name
                            font.pixelSize: parent.parent.height * 0.4
                            color: '#ffedea'
                            font.bold: true
                            font.family: "Arial"
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                                - selectBtn.width
                                - parent.parent.height * 0.36
                                - parent.spacing * 2
                            elide: Text.ElideRight
                        }

                        // Select button
                        Rectangle {
                            id: selectBtn
                            width: scanResultsPopup.width * 0.22
                            height: parent.parent.height * 0.58
                            radius: height / 3
                            anchors.verticalCenter: parent.verticalCenter
                            color: selectArea.containsMouse ? '#aa2211' : '#ff6c55'
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Select")
                                font.pixelSize: parent.height * 0.5
                                color: '#fff5f3'
                                font.bold: true
                                font.family: "Arial"
                            }

                            MouseArea {
                                id: selectArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    scanResultsPopup.close()
                                    console.log("Selected network:", model.name)
                                    WifiManager.connectToNetwork(model.name, "")
                                }
                            }
                        }
                    }

                    // Hover detection for the whole row
                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onClicked: (mouse) => mouse.accepted = false
                    }
                }
            }
        }
    }

    // Status
    Rectangle {
        id: statusToast
        width: parent.width * 0.5
        height: parent.height * 0.08
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
        radius: height / 2
        color: statusToast.isError ? '#3d0a00' : '#0a2e0a'
        border.color: statusToast.isError ? '#ff4422' : '#44bb44'
        border.width: 1
        opacity: 0
        visible: opacity > 0
        z: 20   // ensure it appears above all other content

        property bool isError: false

        Behavior on opacity { NumberAnimation { duration: 400 } }

        Text {
            id: toastText
            anchors.centerIn: parent
            font.pixelSize: parent.height * 0.35
            color: statusToast.isError ? '#ff8a7a' : '#88ff88'
            font.family: "Arial"
            font.bold: true
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: statusToast.opacity = 0
        }
    }

    // Helper to show toast
    function showToast(message, isError) {
        toastText.text = message
        statusToast.isError = isError
        statusToast.opacity = 1
        toastTimer.restart()
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