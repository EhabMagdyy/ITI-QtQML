import QtQuick
import QtQuick.Controls

Rectangle{
    id: btPage
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    color: "transparent"
    required property StackView stackView
    property bool updatingFromBackend: false

    property string connectingAddress:    ""
    property string disconnectingAddress: ""        // ← track disconnect in progress
    property var    connectedAddresses:   []

    Connections{
        target: BluetoothManager

        function onBluetoothEnabledChanged(enabled){
            btPage.updatingFromBackend = true
            btSwitch.checked = enabled
            btPage.updatingFromBackend = false
        }
        function onScanStarted(){
            showToast("Scanning for devices...", false)
        }
        function onScanFinished(devices){
            deviceListModel.clear()
            var newConnected = btPage.connectedAddresses.slice()
            for (var i = 0; i < devices.length; i++){
                var parts  = devices[i].split("|")
                var isConn = parts[2] === "1"
                deviceListModel.append({ "name": parts[0], "address": parts[1] })
                if (isConn && newConnected.indexOf(parts[1]) === -1)
                    newConnected.push(parts[1])
            }
            btPage.connectedAddresses = newConnected
        }
        function onScanFailed(reason){ showToast(reason, true) }
        function onPairSuccess(name) { showToast("Paired with " + name, false) }
        function onPairFailed(reason){ showToast("Pair failed: " + reason, true) }

        function onDeviceConnectionChanged(address, connected){
            var list = btPage.connectedAddresses.slice()
            var idx  = list.indexOf(address)
            if (connected && idx === -1)
                list.push(address)
            else if (!connected && idx !== -1)
                list.splice(idx, 1)
            btPage.connectedAddresses = list

            if (address === btPage.connectingAddress)
                btPage.connectingAddress = ""
            if (address === btPage.disconnectingAddress)
                btPage.disconnectingAddress = ""
        }

        function onConnectSuccess(name){
            var list = btPage.connectedAddresses.slice()
            if (list.indexOf(btPage.connectingAddress) === -1)
                list.push(btPage.connectingAddress)
            btPage.connectedAddresses = list
            btPage.connectingAddress  = ""
            showToast("Connected to " + name, false)
        }
        function onConnectFailed(reason){
            btPage.connectingAddress = ""
            showToast(reason, true)
        }

        // Disconnect handlers
        function onDisconnectSuccess(name){
            btPage.disconnectingAddress = ""
            showToast("Disconnected from " + name, false)
        }
        function onDisconnectFailed(reason){
            btPage.disconnectingAddress = ""
            showToast("Disconnect failed: " + reason, true)
        }
    }

    // Main Content Column
    Column{
        id: btPageCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: btPage.width * 0.06
        anchors.topMargin: btPage.height * 0.05
        anchors.bottomMargin: btPage.height * 0.05
        spacing: btPage.height * 0.02

        Text{
            text: qsTr("Bluetooth Settings")
            font.pixelSize: btPage.width / 22
            color: '#ffedea'
            font.bold: true
            font.family: "Arial"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle{
            width: parent.width
            height: 1
            color: '#ff6c55'
            opacity: 0.5
        }

        // Bluetooth Toggle Card
        Rectangle{
            width: parent.width
            height: btPage.height / 10
            radius: height / 4
            gradient: Gradient{
                GradientStop{ position: 0.0; color: '#2a0a08' }
                GradientStop{ position: 1.0; color: '#1a0504' }
            }
            border.color: btSwitch.checked ? '#ff6c55' : '#5a2a25'
            border.width: 2

            Row{
                anchors.fill: parent
                anchors.leftMargin: parent.width * 0.05
                anchors.rightMargin: parent.width * 0.05

                Column{
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - btSwitch.width - parent.anchors.leftMargin - parent.anchors.rightMargin
                    spacing: 2
                    Text{
                        text: qsTr("Bluetooth")
                        font.pixelSize: btPage.height * 0.025
                        color: '#ffedea'
                        font.bold: true
                        font.family: "Arial"
                    }
                    Text{
                        text: btSwitch.checked ? qsTr("ON") : qsTr("OFF")
                        font.pixelSize: btPage.height * 0.022
                        color: btSwitch.checked ? '#ff8a7a' : '#7a4a45'
                        font.family: "Arial"
                    }
                }

                Switch{
                    id: btSwitch
                    anchors.verticalCenter: parent.verticalCenter
                    Component.onCompleted: {
                        btPage.updatingFromBackend = true
                        btSwitch.checked = BluetoothManager.bluetoothEnabled
                        btPage.updatingFromBackend = false
                    }
                    onCheckedChanged: {
                        if (!btPage.updatingFromBackend)
                            BluetoothManager.bluetoothEnabled = checked
                    }
                }
            }

            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                z: -1
                onClicked: (mouse) => mouse.accepted = false
            }
        }

        // Scan Button
        Rectangle{
            width: parent.width
            height: btPage.height / 12
            radius: height / 4
            opacity: btSwitch.checked ? 1.0 : 0.4
            gradient: Gradient{
                GradientStop{ id: stop11; position: 0.0; color: '#ff8a7a' }
                GradientStop{ id: stop12; position: 1.0; color: '#e95441' }
            }
            border.color: '#ffb3a9'
            border.width: 1

            Row{
                anchors.centerIn: parent
                spacing: parent.width * 0.03
                Text{
                    text: "⟳"
                    font.pixelSize: parent.parent.height * 0.45
                    color: '#fff5f3'
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text{
                    text: qsTr("Scan for Devices")
                    font.pixelSize: parent.parent.height * 0.38
                    color: '#fff5f3'
                    font.bold: true
                    font.family: "Arial"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea{
                id: scanArea
                anchors.fill: parent
                enabled: btSwitch.checked
                hoverEnabled: true
                onEntered:{ stop11.color = '#cc4433'; stop12.color = '#aa2211' }
                onExited: { stop11.color = '#ff8a7a'; stop12.color = '#e95441' }
                onClicked:  BluetoothManager.scanDevices()
            }
        }

        Rectangle{
            width: parent.width
            height: 1
            color: '#ff6c55'
            opacity: 0.3
        }

        // Device List Card
        Rectangle{
            width: parent.width
            height: deviceListModel.count > 0
                    ? deviceListView.contentHeight + btPage.height * 0.08
                    : btPage.height * 0.12
            radius: btPage.height * 0.02
            opacity: btSwitch.checked ? 1.0 : 0.4
            clip: true
            gradient: Gradient{
                GradientStop{ position: 0.0; color: '#2a0a08' }
                GradientStop{ position: 1.0; color: '#1a0504' }
            }
            border.color: '#5a2a25'
            border.width: 2

            Behavior on height{ NumberAnimation{ duration: 200; easing.type: Easing.OutCubic } }

            Text{
                anchors.centerIn: parent
                visible: deviceListModel.count === 0
                text: qsTr("No devices found.\nTap Scan to search.")
                font.pixelSize: btPage.height * 0.022
                color: '#7a4a45'
                font.family: "Arial"
                horizontalAlignment: Text.AlignHCenter
            }

            ListView{
                id: deviceListView
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: btPage.width * 0.03
                anchors.topMargin: btPage.height * 0.02
                height: Math.min(contentHeight, btPage.height * 0.45)
                clip: true
                model: deviceListModel
                spacing: btPage.height * 0.012
                visible: deviceListModel.count > 0

                ScrollBar.vertical: ScrollBar{
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle{
                        implicitWidth: 4
                        radius: 2
                        color: '#ff6c55'
                        opacity: 0.8
                    }
                }

                delegate: Rectangle{
                    width: deviceListView.width - 6
                    height: btPage.height * 0.11
                    radius: height / 4
                    color: rowHover.containsMouse ? '#3a1008' : '#200805'
                    border.color: rowHover.containsMouse ? '#ff6c55' : '#3a1a15'
                    border.width: 1
                    Behavior on color{ ColorAnimation{ duration: 100 } }
                    Behavior on border.color{ ColorAnimation{ duration: 100 } }

                    property bool isConnecting:    model.address === btPage.connectingAddress
                    property bool isDisconnecting: model.address === btPage.disconnectingAddress
                    property bool isConnected:     btPage.connectedAddresses.indexOf(model.address) !== -1

                    Row{
                        anchors.fill: parent
                        anchors.leftMargin: parent.width * 0.04
                        anchors.rightMargin: parent.width * 0.04
                        spacing: parent.width * 0.02

                        Text{
                            text: "⬡"
                            font.pixelSize: parent.parent.height * 0.38
                            color: parent.parent.isConnected ? '#88ff88' : '#ff8a7a'
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Column{
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                                   - connectBtn.width
                                   - parent.parent.height * 0.38
                                   - parent.spacing * 3
                            spacing: 2

                            Text{
                                text: model.name
                                font.pixelSize: btPage.height * 0.022
                                color: '#ffedea'
                                font.bold: true
                                font.family: "Arial"
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            Text{
                                text: model.address
                                font.pixelSize: btPage.height * 0.016
                                color: '#7a4a45'
                                font.family: "Arial"
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // Connect / Disconnect button
                        Rectangle{
                            id: connectBtn
                            width: btPage.width * 0.22
                            height: parent.parent.height * 0.58
                            radius: height / 3
                            anchors.verticalCenter: parent.verticalCenter

                            color: {
                                if (parent.parent.isDisconnecting) return '#664400'
                                if (parent.parent.isConnected)
                                    return connectBtnArea.containsMouse ? '#115511' : '#227722'
                                if (parent.parent.isConnecting)     return '#885500'
                                return connectBtnArea.containsMouse ? '#aa2211' : '#ff6c55'
                            }
                            Behavior on color{ ColorAnimation{ duration: 200 } }

                            Text{
                                anchors.centerIn: parent
                                text: {
                                    if (parent.parent.parent.isDisconnecting) return qsTr("Disconnecting..")
                                    if (parent.parent.parent.isConnected)     return qsTr("Disconnect")
                                    if (parent.parent.parent.isConnecting)    return qsTr("Connecting..")
                                    return qsTr("Connect")
                                }
                                font.pixelSize: parent.height * 0.30
                                color: '#fff5f3'
                                font.bold: true
                                font.family: "Arial"
                            }

                            MouseArea{
                                id: connectBtnArea
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !parent.parent.parent.isConnecting
                                         && !parent.parent.parent.isDisconnecting
                                onClicked: {
                                    if (parent.parent.parent.isConnected) {
                                        // Disconnect
                                        btPage.disconnectingAddress = model.address
                                        BluetoothManager.disconnectDevice(model.address)
                                    } else {
                                        // Connect
                                        btPage.connectingAddress = model.address
                                        BluetoothManager.connectDevice(model.address)
                                    }
                                }
                            }
                        }
                    }

                    MouseArea{
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        z: -1
                        onClicked: (mouse) => mouse.accepted = false
                    }
                }
            }
        }
    }

    ListModel{ id: deviceListModel }

    // Status Toast
    Rectangle{
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
        z: 20
        property bool isError: false
        Behavior on opacity{ NumberAnimation{ duration: 250 } }

        Text{
            id: toastText
            anchors.centerIn: parent
            font.pixelSize: parent.height * 0.28
            color: statusToast.isError ? '#ff8a7a' : '#88ff88'
            font.family: "Arial"
            font.bold: true
        }
        Timer{
            id: toastTimer
            interval: 3000
            onTriggered: statusToast.opacity = 0
        }
    }

    function showToast(message, isError){
        toastText.text = message
        statusToast.isError = isError
        statusToast.opacity = 1
        toastTimer.restart()
    }

    // Back Button
    Rectangle{
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

        Text{
            text: qsTr("Back")
            font.pixelSize: height * 0.8
            color: '#8a1000'
            font.bold: true
            font.family: "Arial"
            anchors.centerIn: parent
        }

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color = '#ffd4ce'
            onExited:  parent.color = '#fffaf8'
            onClicked: btPage.stackView.pop()
        }
    }
}