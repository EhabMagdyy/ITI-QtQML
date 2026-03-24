import QtQuick
import QtQuick.Controls
pragma ComponentBehavior: Bound
import QtQuick.Dialogs
import QtMultimedia

Rectangle {
    id: videoPage
    required property StackView stackView
    anchors.fill: parent
    color: "transparent"

    MediaPlayer {
        id: videoPlayer
        audioOutput: AudioOutput { id: audioOut; volume: 0.7; }
        videoOutput: videoOut
        property bool videoSelected: false
        property string errorMessage: ""

        onErrorOccurred: function(error, errorString) {
            videoSelected = false
            switch(error) {
                case MediaPlayer.NetworkError:
                    errorMessage = "⚠  Cannot reach the server — check your internet connection"
                    break
                case MediaPlayer.FormatError:
                    errorMessage = "⚠  Unsupported video format"
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
        width: videoPage.width / 5
        height: parent.height
        color: '#041c20'

        Column {
            anchors.top: parent.top
            anchors.topMargin: videoPage.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: videoPage.height / 40
            // ========================================= Video Sources ===================================================
            Repeater {
                model: [
                    { label: "🗂️  Local",    idx: 0 },
                    { label: "🌐  Internet", idx: 1 },
                    { label: "💾  USB",      idx: 2 }
                ]

                delegate: Rectangle {
                    id: optionRect
                    required property var modelData
                    width: leftPanel.width * 0.8
                    height: videoPage.height / 14
                    radius: height / 5
                    color: rightPanel.currentIndex === modelData.idx ? '#0d4a52'
                            : (srcArea.containsMouse ? '#072830' : 'transparent')
                    border.color: rightPanel.currentIndex === modelData.idx ? '#00ffaa' : 'transparent'
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        text: optionRect.modelData.label
                        color: rightPanel.currentIndex === optionRect.modelData.idx ? '#00ffaa' : '#557a70'
                        font.pixelSize: videoPage.width / 60
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
                height: videoPage.height / 2.3
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
                    font.pixelSize: videoPage.width / 55
                    font.family: "Arial"
                    font.bold: true
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        videoPage.stackView.pop()
                    }
                }
            }
        }
    }

    // ========================================== Right Panel (Content & Controls) =========================================
    Rectangle {
        id: rightPanel
        width: videoPage.width - leftPanel.width - videoPage.width / 10
        height: videoPage.height - videoPage.height / 6
        anchors.top: parent.top
        anchors.topMargin: videoPage.height / 10
        anchors.left: leftPanel.right
        anchors.leftMargin: videoPage.width / 20
        color: 'transparent'
        border.color: '#0c6e56'
        border.width: 2
        radius: height / 20

        property int currentIndex: 0
        property var browseIcon: "📂"

        VideoOutput {
            id: videoOut
            z:1
            anchors.fill: parent
            anchors.bottomMargin: videoController.height + videoProgress.height + videoPage.height / 16
            anchors.margins: videoPage.height / 50
        }

        // ================================================ Local video ===============================================
        Rectangle {
            anchors.fill: parent
            visible: rightPanel.currentIndex === 0
            color: 'transparent'

            onVisibleChanged: {
                if (visible) rightPanel.browseIcon = "📂"
            }

            FileDialog {
                id: fileDialog
                title: "Choose Video File"
                nameFilters: ["Video files (*.mp4 *.mkv *.avi *.mov *.wmv *.webm)", "All files (*)"]
                onAccepted: {
                    videoPlayer.source = fileDialog.selectedFile
                    videoPlayer.videoSelected = true
                    videoPlayer.play()
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: videoController.height + videoProgress.height + videoPage.height / 16
                anchors.margins: videoPage.height / 50
                color: '#49177566'
                radius: height / 50

                // Show placeholder when nothing selected
                Text {
                    anchors.centerIn: parent
                    visible: !videoPlayer.videoSelected
                    text: "Select a video file"
                    color: '#557a70'
                    font.pixelSize: videoPage.width / 35
                    font.family: "Arial"
                }
            }
        }

        // ================================================ Internet video ============================================
        Rectangle {
            anchors.fill: parent
            visible: rightPanel.currentIndex === 1
            color: 'transparent'

            onVisibleChanged: {
                if (visible) rightPanel.browseIcon = "🌐"
            }

            // URL Dialog
            Dialog {
                id: urlDialog
                title: "Enter Video URL"
                anchors.centerIn: parent
                width: videoPage.width / 2.5
                contentHeight: videoPage.height / 10
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
                    height: videoPage.height / 20
                    Text {
                        anchors.centerIn: parent
                        text: "Enter Video URL"
                        color: '#00ffaa'
                        font.pixelSize: videoPage.width / 70
                        font.bold: true
                        font.family: "Arial"
                    }
                }

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
                    if (urlField.text !== "") {
                        videoPlayer.source = urlField.text
                        videoPlayer.videoSelected = true
                        videoPlayer.play()
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
                    font.pixelSize: videoPage.width / 90
                    font.family: "Arial"
                    leftPadding: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    Keys.onReturnPressed: urlDialog.accept()

                    background: Rectangle {
                        color: '#05262c'
                        radius: 8
                        border.color: urlField.activeFocus ? '#00ffaa' : '#00ffaa44'
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                }
            }

            // Video display
            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: videoController.height + videoProgress.height + videoPage.height / 16
                anchors.margins: videoPage.height / 50
                color: '#49177566'
                radius: height / 50

                // Placeholder
                Text {
                    anchors.centerIn: parent
                    visible: !videoPlayer.videoSelected
                    text: "Enter a video URL to stream"
                    color: '#557a70'
                    font.pixelSize: videoPage.width / 35
                    font.family: "Arial"
                }

                // Status overlay
                Rectangle {
                    id: loadingOverlay
                    anchors.fill: parent
                    color: '#80000000'  // semi-transparent black
                    visible: videoPlayer.mediaStatus === MediaPlayer.BufferingMedia ||
                            videoPlayer.mediaStatus === MediaPlayer.LoadingMedia   ||
                            videoPlayer.mediaStatus === MediaPlayer.StalledMedia
                    radius: parent.radius

                    Column {
                        anchors.centerIn: parent
                        spacing: videoPage.height / 30

                        // Spinning circle
                        Rectangle {
                            id: spinner
                            width: videoPage.width / 30
                            height: width
                            radius: width / 2
                            color: 'transparent'
                            border.color: '#00ffaa'
                            border.width: 3
                            anchors.horizontalCenter: parent.horizontalCenter

                            // Missing quarter to look like a spinner
                            Rectangle {
                                width: parent.border.width + 2
                                height: parent.border.width + 2
                                color: '#80000000'
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            RotationAnimation on rotation {
                                running: loadingOverlay.visible
                                loops: Animation.Infinite
                                duration: 900
                                from: 0; to: 360
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: videoPlayer.mediaStatus === MediaPlayer.BufferingMedia ? "Loading..."
                                : videoPlayer.mediaStatus === MediaPlayer.LoadingMedia   ? "Loading..."
                                : videoPlayer.mediaStatus === MediaPlayer.StalledMedia   ? "⚠  Stream stalled"
                                : ""
                            color: '#00ffaa'
                            font.pixelSize: videoPage.width / 70
                            font.family: "Arial"
                        }
                    }
                }
            }
        }

        // ================================================== USB video ==============================================
        Rectangle {
            anchors.fill: parent 
            visible: rightPanel.currentIndex === 2 
            color: 'transparent'

            onVisibleChanged: {
                if (visible) {
                    rightPanel.browseIcon = "💾"
                    // Auto-scan if connected but no files yet
                    if (usbManager.connected && usbManager.videoFiles.length === 0 && !usbManager.scanning) {
                        usbManager.scanFiles()
                    }
                }
            }

            // No USB connected
            Text {
                anchors.centerIn: parent
                visible: !usbManager.connected
                text: "Plug in a USB device"
                color: '#557a70'
                font.pixelSize: videoPage.width / 35
                font.family: "Arial"
            }

            // Loading indicator (same style as audio)
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: videoPage.width / 65
                anchors.rightMargin: videoPage.width / 65
                anchors.leftMargin: videoPage.width / 65
                anchors.bottomMargin: videoPage.width / 18
                color: '#041c20'
                visible: usbManager.scanning
                z: 5
                radius: videoPage.width / 60

                Column {
                    anchors.centerIn: parent
                    spacing: 20

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
                        font.pixelSize: videoPage.width / 60
                        font.family: "Arial"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "This may take a moment for phones (MTP)"
                        color: '#557a70'
                        font.pixelSize: videoPage.width / 80
                        font.family: "Arial"
                    }

                    // Cancel button
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
                            font.pixelSize: videoPage.width / 60
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
                        text: "Found: " + usbManager.videoFiles.length + " video files"
                        color: '#557a70'
                        font.pixelSize: videoPage.width / 80
                        visible: usbManager.videoFiles.length > 0
                    }
                }
            }

            // Video display area (when video selected)
            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: videoController.height + videoProgress.height + videoPage.height / 16
                anchors.margins: videoPage.height / 50
                color: '#49177566'
                radius: height / 50
                visible: usbManager.connected && !usbManager.scanning && !videoPlayer.videoSelected

                Text {
                    anchors.centerIn: parent
                    text: "Select a video from the list below"
                    color: '#557a70'
                    font.pixelSize: videoPage.width / 35
                    font.family: "Arial"
                }
            }

            // File list
            Column {
                anchors.fill: parent
                anchors.margins: videoPage.height / 20
                anchors.bottomMargin: videoController.height + videoPage.height / 20
                spacing: videoPage.height / 30
                visible: usbManager.connected && !usbManager.scanning

                // Drive name header
                Row {
                    id: videoDriveHeader
                    spacing: 10
                    Text {
                        text: "🔌  " + usbManager.driveName
                        color: '#00ffaa'
                        font.pixelSize: videoPage.width / 55
                        font.bold: true
                        font.family: "Arial"
                    }
                    Text {
                        text: usbManager.videoFiles.length + " files"
                        color: '#557a70'
                        font.pixelSize: videoPage.width / 75
                        font.family: "Arial"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Video List
                ListView {
                    id: videoFileList
                    width: parent.width
                    height: parent.height - parent.spacing - videoDriveHeader.height
                    clip: true
                    model: usbManager.videoFiles
                    spacing: 4

                    ScrollBar.vertical: ScrollBar {
                        id: videoScrollBar
                        width: videoPage.width / 100
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        
                        contentItem: Rectangle {
                            implicitWidth: parent.width
                            radius: width / 2
                            color: videoScrollBar.pressed ? '#00ffaa' : videoScrollBar.hovered ? '#00cc88' : '#0d4a52'
                            opacity: videoScrollBar.hovered || videoScrollBar.pressed ? 1.0 : 0.6
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                        
                        background: Rectangle {
                            implicitWidth: parent.width
                            color: '#05262c'
                            radius: width / 2
                            opacity: 0.3
                        }
                        minimumSize: 0.1
                    }

                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        width: ListView.view.width - videoScrollBar.width * 2
                        height: videoPage.height / 14
                        radius: height / 5
                        color: videoPlayer.source.toString() === ("file://" + modelData)
                            ? '#0d4a52'
                            : videoRowArea.containsMouse ? '#072830' : 'transparent'
                        border.color: videoPlayer.source.toString() === ("file://" + modelData)
                                    ? '#00ffaa' : 'transparent'
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width / 20
                            spacing: parent.width / 30

                            Text {
                                text: "🎬"
                                font.pixelSize: videoPage.width / 70
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: usbManager.fileName(modelData)
                                color: videoPlayer.source.toString() === ("file://" + modelData)
                                    ? '#00ffaa' : '#d0e8e4'
                                font.pixelSize: videoPage.width / 70
                                font.family: "Arial"
                                elide: Text.ElideRight
                                width: parent.parent.width * 0.7
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: videoRowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                videoPlayer.source = "file://" + modelData
                                videoPlayer.videoSelected = true
                                videoPlayer.play()
                            }
                        }
                    }
                }
            }
        }

        // ======================================== Video Controls (Shared) ==========================================
        // ========================================== Progress Slider ================================================
        Rectangle {
            id: videoProgress
            anchors.bottom: videoController.top
            anchors.left: videoController.left
            anchors.right: videoController.right
            anchors.bottomMargin: videoController.height / 100
            anchors.leftMargin: videoPage.width / 30
            anchors.rightMargin: videoPage.width / 30
            height: videoPage.height / 30
            radius: height / 2
            color: 'transparent'

            Slider {
                id: progressSlider
                anchors.bottom: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: -height / 2
                height: videoController.height / 4
                from: 0
                to: videoPlayer.duration > 0 ? videoPlayer.duration : 1
                value: videoPlayer.position

                onMoved: videoPlayer.position = value

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
                    visible: videoPlayer.duration > 0
                }
            }

            // Time Labels & Filename
            Text {
                id: currentTimeText
                anchors.top: videoProgress.top
                anchors.left: videoProgress.left
                anchors.leftMargin: videoController.width / 120
                text: videoPage.formatTime(videoPlayer.position)
                color: '#557a70'
                font.pixelSize: videoController.height / 5
                font.family: "Arial"
            }

            // Show filename overlay at top
            Text {
                visible: videoPlayer.videoSelected
                anchors.top: videoProgress.top
                anchors.left: currentTimeText.right
                anchors.leftMargin: videoController.width / 20
                anchors.right: totalTimeText.left
                anchors.rightMargin: videoController.width / 20
                text: videoPlayer.videoSelected
                    ? videoPlayer.source.toString().split("/").pop().replace(/\.[^.]+$/, "")
                    : ""
                color: '#ffffff'
                font.pixelSize: videoController.height / 5
                font.family: "Arial"
                horizontalAlignment: Text.AlignHCenter 
                elide: Text.ElideMiddle                       // clips as: "long fi...name"
            }

            Text {
                id: totalTimeText
                anchors.top: videoProgress.top
                anchors.right: videoProgress.right
                anchors.rightMargin: videoController.width / 120
                text: videoPage.formatTime(videoPlayer.duration)
                color: '#557a70'
                font.pixelSize: videoController.height / 5
                font.family: "Arial"
            }
        }
        // ========================================== Playback Controls ================================================
        Rectangle {
            id: videoController
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: videoPage.height / 30
            height: videoPage.height / 11
            radius: height / 2
            color: '#041c20'
            border.color: '#00ffaa33'
            border.width: 1

            // Mute
            ControlBtn {
                id: volumeBtn
                property bool muted: false
                icon: audioOut.muted ? "🔇" : volumeSlider.value < 0.5 ? "🔉" : "🔊"
                onClicked: audioOut.muted = !audioOut.muted
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: videoController.width / 20
            }

            // Volume Slider
            Slider {
                id: volumeSlider
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: volumeBtn.right
                anchors.leftMargin: videoController.width / 80
                width: videoController.width / 8
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
            Row{
                anchors.centerIn: parent
                spacing: videoController.width / 45
                // Prev
                ControlBtn {
                    icon: "◀◀"
                    onClicked: { videoPlayer.position = 0 }
                }

                // Play / Pause
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: videoController.height * 0.72
                    height: width
                    radius: width / 2
                    color: playMainArea.containsMouse ? '#00ffaa' : '#00cc88'
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: videoPlayer.playbackState === MediaPlayer.PlayingState ? "❚❚" : "▶"
                        font.pixelSize: videoPlayer.playbackState === MediaPlayer.PlayingState ? parent.width / 2.4 : parent.width / 2
                        color: '#002a31'
                        font.bold: true
                    }

                    MouseArea {
                        id: playMainArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: videoPlayer.playbackState === MediaPlayer.PlayingState
                                ? videoPlayer.pause() : videoPlayer.play()
                    }
                }

                // Next
                ControlBtn {
                    icon: "▶▶"
                    onClicked: { videoPlayer.position = videoPlayer.duration }
                }
            }

            // Speed Indicator
            ControlBtn {
                id: speedIndicator
                icon: "1.0x"
                onClicked: speedSlider.value = 1
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: speedSlider.left
                anchors.rightMargin: videoController.width / 80
                fontPixel: videoController.width / 55
            }

            // Speed Slider
            Slider {
                id: speedSlider
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: browseBtn.left
                anchors.rightMargin: videoController.width / 20
                width: videoController.width / 8
                from: 0.5; to: 8; value: 1
                
                onValueChanged: {
                    videoPlayer.playbackRate = value
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
                anchors.rightMargin: videoController.width / 20
                onClicked: rightPanel.currentIndex === 0 ? fileDialog.open() : 
                            rightPanel.currentIndex === 1 ? urlDialog.open() :
                            console.log("Browse action for other sources coming soon")
            }
        }
    }

    component ControlBtn: Rectangle {
        id: controlBtn
        property string icon: ""
        property var fontPixel: videoController.width / 35
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