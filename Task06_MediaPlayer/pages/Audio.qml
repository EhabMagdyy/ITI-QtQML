import QtQuick
import QtQuick.Controls
pragma ComponentBehavior: Bound
import QtQuick.Dialogs
import QtMultimedia

Rectangle {
    id: audioPage
    required property StackView stackView
    anchors.fill: parent
    color: "transparent"

    MediaPlayer {
        id: audioPlayer
        audioOutput: AudioOutput { id: audioOut; volume: 0.7 }
        property bool audioSelected: false
        property string errorMessage: ""
        property int currentFileIndex: -1

        onErrorOccurred: function(error, errorString) {
            audioSelected = false
            switch(error) {
                case MediaPlayer.NetworkError:
                    errorMessage = "⚠  Cannot reach the server — check your internet connection"
                    break
                case MediaPlayer.FormatError:
                    errorMessage = "⚠  Unsupported audio format"
                    break
                case MediaPlayer.AccessDeniedError:
                    errorMessage = "⚠  Access denied — the server rejected the request"
                    break
                case MediaPlayer.ResourceError:
                    errorMessage = "⚠  Invalid URL or resource not found"
                    break
                default:
                    errorMessage = "⚠  " + errorString
            }
        }

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState)
                errorMessage = ""   // clear error when playing successfully
        }
    }

    // ========================================== Left Panel (Source Selection) =========================================
    Rectangle {
        id: leftPanel
        width: audioPage.width / 5
        height: parent.height
        color: '#041c20'

        Column {
            anchors.top: parent.top
            anchors.topMargin: audioPage.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: audioPage.height / 40
            // ========================================= Audio Sources ===================================================
            Repeater {
                model: [
                    { label: "🗂️  Local",    idx: 0 },
                    { label: "🌐  Internet", idx: 1 },
                    { label: "🔵  Bluetooth",idx: 2 },
                    { label: "💾  USB",      idx: 3 }
                ]

                delegate: Rectangle {
                    id: optionRect
                    required property var modelData
                    width: leftPanel.width * 0.8
                    height: audioPage.height / 14
                    radius: height / 5
                    color: rightPanel.currentIndex === modelData.idx ? '#0d4a52'
                            : (srcArea.containsMouse ? '#072830' : 'transparent')
                    border.color: rightPanel.currentIndex === modelData.idx ? '#00ffaa' : 'transparent'
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        text: optionRect.modelData.label
                        color: rightPanel.currentIndex === optionRect.modelData.idx ? '#00ffaa' : '#557a70'
                        font.pixelSize: audioPage.width / 60
                        font.family: "Arial"
                        font.bold: rightPanel.currentIndex === optionRect.modelData.idx
                        horizontalAlignment: Text.AlignLeft
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: optionRect.left
                        anchors.leftMargin: optionRect.width / 8
                    }

                    MouseArea {
                        id: srcArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: rightPanel.currentIndex = optionRect.modelData.idx
                    }
                }
            }
            // =============== Spacer ===================
            Rectangle{
                width: 1
                height: audioPage.height / 3
                color: "transparent"
            }

            // ============================================ Back button ===============================================
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: backText.width * 2.5
                height: backText.height + backText.height * 0.6
                radius: height / 1.5
                color: backArea.containsMouse ? "#1a3a40" : '#204d55'
                border.color: "#00ffaa44"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: backText
                    anchors.centerIn: parent
                    text: "Back"
                    color: '#e7f1ef'
                    font.pixelSize: audioPage.width / 55
                    font.family: "Arial"
                    font.bold: true
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        audioPage.stackView.pop()
                    }
                }
            }
        }
    }

    // ========================================== Right Panel (Content & Controls) =========================================
    Rectangle {
        id: rightPanel
        width: audioPage.width - leftPanel.width - audioPage.width / 10
        height: audioPage.height - audioPage.height / 6
        anchors.top: parent.top
        anchors.topMargin: audioPage.height / 10
        anchors.left: leftPanel.right
        anchors.leftMargin: audioPage.width / 20
        color: 'transparent'
        border.color: '#0c6e56'
        border.width: 2
        radius: height / 20

        property int currentIndex: 0
        property var browseIcon: "📂"

        // ================================================ Local audio ===============================================
        Rectangle {
            anchors.fill: parent
            visible: rightPanel.currentIndex === 0
            color: 'transparent'

            onVisibleChanged: {
                if (visible) rightPanel.browseIcon = "📂"
            }

            FileDialog {
                id: fileDialog
                title: "Choose Audio File"
                nameFilters: ["Audio files (*.mp3 *.wav *.aac *.flac *.ogg *.m4a)", "All files (*)"]
                onAccepted: {
                    audioPlayer.source = fileDialog.selectedFile
                    audioPlayer.audioSelected = true
                    audioPlayer.play()
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: audioPage.width / 40
                anchors.verticalCenterOffset: -audioController.height / 2

                // Audio image
                Image {
                    source: "qrc:/icons/audio.png"
                    width: audioPage.height / 3
                    height: width
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                    visible: audioPlayer.audioSelected
                }

                Text {
                    text: audioPlayer.audioSelected ? audioPlayer.source.toString().split("/").pop().replace(/\.[^.]+$/, "") : "Select an audio file"
                    color: audioPlayer.audioSelected ? '#ffffff' : '#557a70'
                    font.bold: audioPlayer.audioSelected
                    font.pixelSize: audioPlayer.audioSelected? audioPage.width / 60 : audioPage.width / 35
                    font.family: "Arial"
                    width: audioPlayer.audioSelected? audioPage.width / 3 : audioPage.width / 4.1
                    wrapMode: Text.WordWrap
                    anchors.top: parent.top
                    anchors.topMargin: audioPlayer.audioSelected? audioPage.height / 15 : 0
                }
            }
        }

        // ================================================ Internet audio ============================================
        Rectangle {
            id: internetAudio
            anchors.fill: parent 
            visible: rightPanel.currentIndex === 1
            color: 'transparent'

            onVisibleChanged: {
                if (visible) rightPanel.browseIcon = "🌐"
            }

            Dialog {
                id: urlDialog
                title: "Enter Audio URL"
                anchors.centerIn: parent
                width: audioPage.width / 2.5
                contentHeight: audioPage.height / 10
                modal: true
                standardButtons: Dialog.Ok | Dialog.Cancel

                background: Rectangle {
                    color: '#041c20'
                    radius: 5
                    border.color: '#00ffaa44'
                    border.width: 1
                }

                header: Rectangle {
                    color: 'transparent'
                    height: audioPage.height / 20
                    Text {
                        anchors.centerIn: parent
                        text: "Enter Audio URL"
                        color: '#00ffaa'
                        font.pixelSize: audioPage.width / 70
                        font.bold: true
                        font.family: "Arial"
                    }
                }

                // Styles the Ok/Cancel buttons
                palette {
                    buttonText: "#00ffaa"
                    button: "#041c20"
                    dark: "#00ffaa"
                    highlight: "#0d4a52"
                    window: "#041c20"
                    windowText: "#ffffff"
                    base: "#05262c"
                    text: "#ffffff"
                }

                onAccepted: {
                    if(urlField.text !== "") {
                        audioPlayer.source = urlField.text
                        audioPlayer.audioSelected = true
                        audioPlayer.play()
                    }
                }
                onOpened: urlField.forceActiveFocus()


                TextField {
                    id: urlField
                    width: urlDialog.width - urlDialog.width * 0.1
                    height: urlDialog.height / 3.3
                    placeholderText: "https://..."
                    placeholderTextColor: '#335a55'
                    color: '#daf3f1'
                    font.pixelSize: audioPage.width / 90
                    font.family: "Arial"
                    leftPadding: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    Keys.onReturnPressed: urlDialog.accept()    // allow Enter key to submit

                    background: Rectangle {
                        color: '#05262c'
                        radius: 8
                        border.color: urlField.activeFocus ? '#00ffaa' : '#00ffaa44'
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                }
            }

            Row {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -audioController.height / 2
                spacing: audioPage.width / 40

                Item {
                    id: loadingItem
                    width: audioPage.height / 3
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    visible: audioPlayer.audioSelected && audioPlayer.errorMessage === ""

                    property bool isLoading: audioPlayer.mediaStatus === MediaPlayer.BufferingMedia ||
                                            audioPlayer.mediaStatus === MediaPlayer.LoadingMedia   ||
                                            audioPlayer.mediaStatus === MediaPlayer.StalledMedia

                    Image {
                        anchors.fill: parent
                        source: "qrc:/icons/audio.png"
                        fillMode: Image.PreserveAspectFit
                        visible: !parent.isLoading
                        opacity: visible ? 1 : 0
                    }

                    // Spinner - shown only while loading
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: parent.isLoading    // show only when loading

                        Rectangle {
                            width: audioPage.width / 30
                            height: width
                            radius: width / 2
                            color: 'transparent'
                            border.color: '#00ffaa'
                            border.width: 3
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                width: parent.border.width + 2
                                height: parent.border.width + 2
                                color: '#041c20'
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            RotationAnimation on rotation {
                                running: loadingItem.isLoading
                                loops: Animation.Infinite
                                duration: 900
                                from: 0; to: 360
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: audioPlayer.mediaStatus === MediaPlayer.StalledMedia ? "⚠  Stalled" : "Loading..."
                            color: '#00ffaa'
                            font.pixelSize: audioPage.width / 85
                            font.family: "Arial"
                        }
                    }
                }

                // Text beside image
                Text {
                    text: audioPlayer.errorMessage !== "" ? audioPlayer.errorMessage : audioPlayer.audioSelected ? 
                            audioPlayer.source.toString().split("/").pop().replace(/\.[^.]+$/, "") : "Enter audio URL to stream"
                    color: audioPlayer.errorMessage !== "" ? '#ff4444' : audioPlayer.audioSelected  ? '#ffffff' : '#557a70'
                    font.family: "Arial"
                    font.bold: audioPlayer.audioSelected
                    font.pixelSize: audioPlayer.errorMessage !== "" ? audioPage.width / 75
                                : audioPlayer.audioSelected       ? audioPage.width / 60
                                : audioPage.width / 35
                    wrapMode: Text.WordWrap
                    width: audioPage.width / 3
                    anchors.top: parent.top
                    anchors.topMargin: audioPlayer.audioSelected? audioPage.height / 15 : 0
                }
            }
        }

        // =============================================== Bluetooth audio ===========================================
        Rectangle {
            anchors.fill: parent
            visible: rightPanel.currentIndex === 2
            color: 'transparent'

            onVisibleChanged: {
                if (visible) rightPanel.browseIcon = "🔵"
            }

            Connections {
                target: btManager

                function onTrackInfoChanged() {
                    console.log("Track changed:", btManager.trackTitle)
                }
                function onPlayerStatusChanged() {
                    console.log("Status:", btManager.playerStatus)
                }
                function onConnectedChanged() {
                    console.log("Connected:", btManager.connected)
                }
            }

            Row {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -audioController.height / 2
                spacing: audioPage.width / 40

                // Bluetooth image
                Image {
                    source: "qrc:/icons/audio.png"
                    width: audioPage.height / 3
                    height: width
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                    visible: btManager && btManager.connected
                    opacity: btManager && btManager.playerStatus === "playing" ? 1.0 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                // Info column
                Column {
                    anchors.top: parent.top
                    anchors.topMargin: parent.height / 10
                    spacing: audioPage.height / 40

                    // No device placeholder
                    Text {
                        visible: !btManager || !btManager.connected
                        text: "No device connected"
                        color: '#557a70'
                        font.family: "Arial"
                        font.pixelSize: audioPage.width / 35
                    }

                    // Device name chip
                    Rectangle {
                        visible: btManager && btManager.connected
                        width: deviceNameText.width + 24
                        height: deviceNameText.height + 10
                        radius: height / 2
                        color: '#0d4a52'
                        border.color: '#00ffaa44'
                        border.width: 1

                        Text {
                            id: deviceNameText
                            anchors.centerIn: parent
                            text: btManager ? "🔵  " + btManager.deviceName : ""
                            color: '#00ffaa'
                            font.pixelSize: audioPage.width / 90
                            font.family: "Arial"
                        }
                    }

                    // Track title
                    Text {
                        visible: btManager && btManager.connected
                        text: btManager && btManager.trackTitle !== ""
                            ? btManager.trackTitle
                            : "Play music on your phone"
                        color: btManager && btManager.trackTitle !== "" ? '#ffffff' : '#557a70'
                        font.family: "Arial"
                        font.bold: btManager && btManager.trackTitle !== ""
                        font.pixelSize: audioPage.width / 55
                        wrapMode: Text.WordWrap
                        width: audioPage.width / 3
                    }

                    // Artist - Album
                    Text {
                        visible: btManager && btManager.connected && btManager.trackArtist !== ""
                        text: {
                            if (!btManager) return ""
                            if (btManager.trackArtist !== "" && btManager.trackAlbum !== "")
                                return btManager.trackArtist + "  ·  " + btManager.trackAlbum
                            return btManager.trackArtist
                        }
                        color: '#557a70'
                        font.family: "Arial"
                        font.pixelSize: audioPage.width / 80
                        wrapMode: Text.WordWrap
                        width: audioPage.width / 3
                    }

                    // Player status chip
                    Rectangle {
                        visible: btManager && btManager.connected && btManager.playerStatus !== ""
                        width: statusText.width + 24
                        height: statusText.height + 10
                        radius: height / 2
                        color: btManager && btManager.playerStatus === "playing" ? '#0d4a52' : '#1a1a1a'
                        border.color: btManager && btManager.playerStatus === "playing" ? '#00ffaa44' : '#ffffff22'
                        border.width: 1

                        // Pulsing dot
                        Rectangle {
                            width: 6; height: 6; radius: 3
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            color: btManager && btManager.playerStatus === "playing" ? '#00ffaa' : '#557a70'

                            SequentialAnimation on opacity {
                                running: btManager && btManager.playerStatus === "playing"
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.2; duration: 600; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                            }
                        }

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            leftPadding: 8
                            text: btManager ? btManager.playerStatus.charAt(0).toUpperCase()
                                            + btManager.playerStatus.slice(1) : ""
                            color: btManager && btManager.playerStatus === "playing" ? '#00ffaa' : '#557a70'
                            font.pixelSize: audioPage.width / 95
                            font.family: "Arial"
                        }
                    }
                }
            }
        }

        // ================================================== USB audio ==============================================
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: audioPage.width / 20
            radius: audioPage.width / 20
            visible: rightPanel.currentIndex === 3
            color: 'transparent'

            onVisibleChanged: {
                if (visible) rightPanel.browseIcon = "💾"
            }

            // No USB connected
            Text {
                anchors.centerIn: parent
                visible: !usbManager.connected
                text: "Plug in a USB device"
                color: '#557a70'
                font.pixelSize: audioPage.width / 35
                font.family: "Arial"
            }

            // Loading indicator
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: audioPage.width / 65
                anchors.rightMargin: audioPage.width / 65
                anchors.leftMargin: audioPage.width / 65
                anchors.bottomMargin: audioPage.width / 18
                color: '#041c20'
                visible: usbManager.scanning
                z: 5
                radius: audioPage.width / 60

                Column {
                    anchors.centerIn: parent
                    spacing: 20

                    // Spinner
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: 'transparent'
                        border.color: '#00ffaa'
                        border.width: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: 6; height: 6
                            color: '#041c20'
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: -2
                        }

                        RotationAnimation on rotation {
                            running: parent.visible
                            loops: Animation.Infinite
                            duration: 900
                            from: 0; to: 360
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Scanning " + usbManager.driveName + "..."
                        color: '#00ffaa'
                        font.pixelSize: audioPage.width / 60
                        font.family: "Arial"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "This may take a moment for phones (MTP)"
                        color: '#557a70'
                        font.pixelSize: audioPage.width / 80
                        font.family: "Arial"
                    }

                    // Cancel Scanning button
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: cancelText.width * 2.5
                        height: cancelText.height + 16
                        radius: height / 2
                        color: cancelArea.containsMouse ? "#ff4444" : "#aa2222"
                        
                        Text {
                            id: cancelText
                            anchors.centerIn: parent
                            text: "Cancel Scan"
                            color: "#ffffff"
                            font.pixelSize: audioPage.width / 60
                            font.family: "Arial"
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: cancelArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: usbManager.disconnectDevice()
                        }
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Found: " + usbManager.audioFiles.length + " audio files"
                        color: '#557a70'
                        font.pixelSize: audioPage.width / 80
                        visible: usbManager.audioFiles.length > 0
                    }
                }
            }

            // File list (List the audio files found on the USB after scanning)
            Column {
                anchors.fill: parent
                anchors.margins: audioPage.height / 20
                anchors.bottomMargin: audioController.height + audioPage.height / 20
                spacing: audioPage.height / 30
                visible: usbManager.connected && !usbManager.scanning

                // Drive name header
                Row {
                    id: driveHeader
                    spacing: 10
                    Text {
                        text: "💾  " + usbManager.driveName
                        color: '#00ffaa'
                        font.pixelSize: audioPage.width / 55
                        font.bold: true
                        font.family: "Arial"
                    }
                    Text {
                        text: usbManager.audioFiles.length + " files"
                        color: '#557a70'
                        font.pixelSize: audioPage.width / 75
                        font.family: "Arial"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // List Files
                ListView {
                    width: parent.width
                    height: parent.height - parent.spacing - driveHeader.height
                    clip: true
                    model: usbManager.audioFiles
                    spacing: 4

                    ScrollBar.vertical: ScrollBar {
                        id: listScrollBar
                        width: audioPage.width / 100
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        
                        contentItem: Rectangle {
                            implicitWidth: parent.width
                            radius: width / 2
                            color: listScrollBar.pressed ? '#00ffaa' : listScrollBar.hovered ? '#00cc88' : '#0d4a52'
                            opacity: listScrollBar.hovered || listScrollBar.pressed ? 1.0 : 0.6
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                        
                        background: Rectangle {
                            implicitWidth: parent.width
                            color: '#05262c'
                            radius: width / 2
                            opacity: 0.3
                        }
                        
                        // Minimum size for thumb when list is long
                        minimumSize: 0.1
                    }

                    delegate: Rectangle {
                        id: fileRow
                        required property string modelData
                        required property int index
                        width: ListView.view.width - listScrollBar.width * 2 
                        height: audioPage.height / 14
                        radius: height / 5
                        color: audioPlayer.source.toString() === ("file://" + modelData)
                            ? '#0d4a52'
                            : rowArea.containsMouse ? '#072830' : 'transparent'
                        border.color: audioPlayer.source.toString() === ("file://" + modelData)
                                    ? '#00ffaa' : 'transparent'
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width / 20
                            spacing: parent.width / 30

                            Text {
                                text: "🎵"
                                font.pixelSize: audioPage.width / 70
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: usbManager.fileName(fileRow.modelData)
                                color: audioPlayer.source.toString() === ("file://" + fileRow.modelData)
                                    ? '#00ffaa' : '#d0e8e4'
                                font.pixelSize: audioPage.width / 70
                                font.family: "Arial"
                                elide: Text.ElideRight
                                width: parent.parent.width * 0.7
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                audioPlayer.source = "file://" + fileRow.modelData
                                audioPlayer.audioSelected = true
                                audioPlayer.currentFileIndex = fileRow.index
                                audioPlayer.play()
                            }
                        }
                    }
                }
            }
        }

        // ======================================== Audio Controls (Shared) ==========================================
        // ========================================== Progress Slider ================================================
        Rectangle {
            id: audioProgress
            visible: rightPanel.currentIndex !== 2
            anchors.bottom: audioController.top
            anchors.left: audioController.left
            anchors.right: audioController.right
            anchors.bottomMargin: audioController.height / 100
            anchors.leftMargin: audioPage.width / 30
            anchors.rightMargin: audioPage.width / 30
            height: audioPage.height / 30
            radius: height / 2
            color: 'transparent'

            Slider {
                id: progressSlider
                anchors.bottom: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: -height / 2
                height: audioController.height / 4
                from: 0
                to: audioPlayer.duration > 0 ? audioPlayer.duration : 1
                value: audioPlayer.position

                onMoved: audioPlayer.position = value

                background: Rectangle {
                    x: progressSlider.leftPadding
                    y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                    width: progressSlider.availableWidth
                    height: 3
                    radius: 2
                    color: '#05262c'

                    Rectangle {
                        width: progressSlider.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: '#00ffaa' }
                            GradientStop { position: 1.0; color: '#00cc88' }
                        }
                    }
                }

                handle: Rectangle {
                    x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                    y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                    width: 10; height: 10; radius: 5
                    color: progressSlider.pressed ? '#00ffaa' : '#ffffff'
                    border.color: '#00ffaa'
                    border.width: 2
                    visible: audioPlayer.duration > 0
                }
            }

            // Time labels
            Row {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: audioController.height / 30
                anchors.leftMargin: audioController.width / 120
                anchors.rightMargin: audioController.width / 120

                Text {
                    id: currentTimeText 
                    text: audioPage.formatTime(audioPlayer.position)
                    color: '#557a70'
                    font.pixelSize: audioController.height / 5
                    font.family: "Arial"
                }

                Item { width: parent.width - currentTimeText.width - totalTimeText.width - 20; height: 1 }

                Text {
                    id: totalTimeText
                    text: audioPage.formatTime(audioPlayer.duration)
                    color: '#557a70'
                    font.pixelSize: audioController.height / 5
                    font.family: "Arial"
                }
            }
        }
        // ========================================== Playback Controls ================================================
        Rectangle {
            id: audioController
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: audioPage.height / 30
            height: audioPage.height / 11
            radius: height / 2
            color: '#041c20'
            border.color: '#00ffaa33'
            border.width: 1

            // Mute
            ControlBtn {
                id: volumeBtn
                property bool muted: false
                visible: rightPanel.currentIndex !== 2
                icon: audioOut.muted ? "🔇" : volumeSlider.value < 0.5 ? "🔉" : "🔊"
                onClicked: audioOut.muted = !audioOut.muted
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: audioController.width / 20
            }

            // Volume Slider
            Slider {
                id: volumeSlider
                anchors.verticalCenter: parent.verticalCenter
                visible: rightPanel.currentIndex !== 2
                anchors.left: volumeBtn.right
                anchors.leftMargin: audioController.width / 80
                width: audioController.width / 8
                from: 0; to: 1; value: 0.6
                
                onValueChanged: {
                    audioOut.volume = value
                    volumeBtn.muted = false      // unmute when slider moves
                    audioOut.muted = false       // unmute the actual output too
                }

                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    width: volumeSlider.availableWidth
                    height: 6
                    radius: 3
                    color: '#05262c'

                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: '#37c596' }
                            GradientStop { position: 1.0; color: '#15966b' }
                        }
                    }
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: audioController.width / 45
                // Prev
                ControlBtn {
                    icon: "◀◀"
                    onClicked: {
                        // navigate files in Bluetooth or USB mode
                        if (rightPanel.currentIndex === 2 && btManager && btManager.connected)
                            btManager.previous()
                        else if (rightPanel.currentIndex === 3 && usbManager.connected && usbManager.audioFiles.length > 0) {
                            var newIndex = audioPlayer.currentFileIndex - 1
                            if(newIndex < 0) newIndex = usbManager.audioFiles.length - 1  // Wrap to end
                            audioPlayer.currentFileIndex = newIndex
                            audioPlayer.source = "file://" + usbManager.audioFiles[newIndex]
                            audioPlayer.audioSelected = true
                            audioPlayer.play()
                        }
                        else
                            audioPlayer.position = 0
                    }
                }

                // Play / Pause
                Rectangle {
                    width: audioController.height * 0.72
                    height: width
                    radius: width / 2
                    color: playMainArea.containsMouse ? '#00ffaa' : '#00cc88'
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: playPauseText
                        anchors.centerIn: parent
                        text:   if(rightPanel.currentIndex === 2 && btManager && btManager.connected){
                                    btManager.playerStatus === "playing" ? "❚❚" : "▶"
                                } 
                                else {
                                    audioPlayer.playbackState === MediaPlayer.PlayingState ? "❚❚" : "▶"
                                }
                        font.pixelSize: if(rightPanel.currentIndex === 2 && btManager && btManager.connected){
                                            btManager.playerStatus === "playing" ? parent.width / 2.4 : parent.width / 2
                                        } 
                                        else {
                                            audioPlayer.playbackState === MediaPlayer.PlayingState ? parent.width / 2.4 : parent.width / 2
                                        }
                        color: '#002a31'
                        font.bold: true
                    }

                    MouseArea {
                        id: playMainArea
                        anchors.fill: parent
                        hoverEnabled: true
                         onClicked: {
                            if(rightPanel.currentIndex === 2 && btManager && btManager.connected) {
                                if(btManager.playerStatus === "playing") {
                                    btManager.pause();
                                } 
                                else {
                                    btManager.play();
                                }
                            } 
                            else {
                                audioPlayer.playbackState === MediaPlayer.PlayingState ? audioPlayer.pause() : audioPlayer.play()
                            }
                        }
                    }
                }

                // Next
                ControlBtn {
                    icon: "▶▶"
                    onClicked: {
                        if (rightPanel.currentIndex === 2 && btManager && btManager.connected)
                            btManager.next()
                        else if (rightPanel.currentIndex === 3 && usbManager.connected && usbManager.audioFiles.length > 0) {
                            var newIndex = audioPlayer.currentFileIndex + 1
                            if(newIndex >= usbManager.audioFiles.length) newIndex = 0  // Wrap to beginning
                            audioPlayer.currentFileIndex = newIndex
                            audioPlayer.source = "file://" + usbManager.audioFiles[newIndex]
                            audioPlayer.audioSelected = true
                            audioPlayer.play()
                        }
                        else
                            audioPlayer.position = audioPlayer.duration
                    }
                }
            }

            // Speed Indicator
            ControlBtn {
                id: speedIndicator
                icon: "1.0x"
                visible: rightPanel.currentIndex !== 2
                onClicked: speedSlider.value = 1
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: speedSlider.left
                anchors.rightMargin: audioController.width / 80
                fontPixel: audioController.width / 55
            }

            // Speed Slider
            Slider {
                id: speedSlider
                anchors.verticalCenter: parent.verticalCenter
                visible: rightPanel.currentIndex !== 2
                anchors.right: browseBtn.left
                anchors.rightMargin: audioController.width / 20
                width: audioController.width / 8
                from: 0.5; to: 8; value: 1
                
                onValueChanged: {
                    audioPlayer.playbackRate = value
                    speedIndicator.icon = value.toFixed(1) + "x"
                }

                background: Rectangle {
                    x: speedSlider.leftPadding
                    y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                    width: speedSlider.availableWidth
                    height: 6
                    radius: 3
                    color: '#05262c'

                    Rectangle {
                        width: speedSlider.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: '#37c596' }
                            GradientStop { position: 1.0; color: '#15966b' }
                        }
                    }
                }
            }

            // Browse
            ControlBtn {
                id: browseBtn
                icon: rightPanel.browseIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: audioController.width / 20
                onClicked: rightPanel.currentIndex === 0 ? fileDialog.open() : 
                            rightPanel.currentIndex === 1 ? urlDialog.open() : console.log("Browse action for other sources coming soon")
            }
        }
    }

    component ControlBtn: Rectangle {
        id: controlBtn
        property string icon: ""
        property var fontPixel: audioController.width / 35
        signal clicked()

        anchors.verticalCenter: parent.verticalCenter
        width: iconText.width + iconText.width * 0.5
        height: iconText.height + iconText.height * 0.3
        radius: height / 2
        color: 'transparent'
        scale: btnArea.containsMouse ? 1.15 : 1
        Behavior on scale { NumberAnimation { duration: 150 } }

        Text {
            id: iconText
            anchors.centerIn: parent
            text: parent.icon
            color: '#ffffff'
            font.pixelSize: controlBtn.fontPixel
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }

    function formatTime(ms) {
        if (ms <= 0) return "0:00"
        var totalSec = Math.floor(ms / 1000)
        var min = Math.floor(totalSec / 60)
        var sec = totalSec % 60
        return min + ":" + (sec < 10 ? "0" + sec : sec)
    }
}