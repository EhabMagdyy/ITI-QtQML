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
        audioOutput: AudioOutput { id: audioOut; volume: 0.8 }
        property bool fileSelected: false
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
                    audioPlayer.fileSelected = true
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
                    visible: audioPlayer.fileSelected
                }

                Text {
                    text: audioPlayer.fileSelected ? audioPlayer.source.toString().split("/").pop().replace(/\.[^.]+$/, "") : "Select an audio file"
                    color: audioPlayer.fileSelected ? '#00ffaa' : '#557a70'
                    font.bold: audioPlayer.fileSelected
                    font.pixelSize: audioPlayer.fileSelected? audioPage.width / 60 : audioPage.width / 35
                    font.family: "Arial"
                    width: audioPlayer.fileSelected? audioPage.width / 3 : audioPage.width / 4
                    wrapMode: Text.WordWrap
                    anchors.top: parent.top
                    anchors.topMargin: audioPlayer.fileSelected? audioPage.height / 15 : 0
                }
            }
        }

        // ================================================ Internet audio ============================================
        Rectangle {
            anchors.fill: parent 
            visible: rightPanel.currentIndex === 1
            color: 'transparent'

            Text {
                anchors.centerIn: parent
                text: "🌐  Internet — Coming Soon"
                color: '#557a70'
                font.pixelSize: audioPage.width / 55
                font.family: "Arial"
            }
        }

        // =============================================== Bluetooth audio ===========================================
        Rectangle {
            anchors.fill: parent 
            visible: rightPanel.currentIndex === 2 
            color: 'transparent'

            Text {
                anchors.centerIn: parent
                text: "🔵  Bluetooth — Coming Soon"
                color: '#557a70'
                font.pixelSize: audioPage.width / 55
                font.family: "Arial"
            }
        }

        // ================================================== USB audio ==============================================
        Rectangle {
            anchors.fill: parent 
            visible: rightPanel.currentIndex === 3
            color: 'transparent'

            Text {
                anchors.centerIn: parent
                text: "🔌  USB — Coming Soon"
                color: '#557a70'
                font.pixelSize: audioPage.width / 55
                font.family: "Arial"
            }
        }

        // ======================================== Audio Controls (Shared) ==========================================
        // ========================================== Progress Slider ================================================
        Rectangle {
            id: audioProgress
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

            // ── Time labels ───────────────────────────────────────────
            Row {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: audioController.height / 30
                anchors.leftMargin: audioController.width / 120
                anchors.rightMargin: audioController.width / 120

                Text {
                    text: formatTime(audioPlayer.position)
                    color: '#557a70'
                    font.pixelSize: audioController.height / 5
                    font.family: "Arial"
                }

                Item { width: parent.width - currentTimeText.width - totalTimeText.width - 20; height: 1 }

                Text {
                    id: totalTimeText
                    text: formatTime(audioPlayer.duration)
                    color: '#557a70'
                    font.pixelSize: audioController.height / 5
                    font.family: "Arial"
                    anchors.right: parent.right  // won't work in Row, use Item spacer below
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

            Row {
                anchors.centerIn: parent
                anchors.leftMargin: parent.width / 30
                anchors.rightMargin: parent.width / 30
                spacing: parent.width / 50
                anchors.verticalCenter: parent.verticalCenter

                // Mute
                ControlBtn {
                    id: volumeBtn
                    property bool muted: false
                    icon: audioOut.muted ? "🔇" : volumeSlider.value < 0.5 ? "🔉" : "🔊"
                    onClicked: audioOut.muted = !audioOut.muted
                }

                // Volume Slider
                Slider {
                    id: volumeSlider
                    anchors.verticalCenter: parent.verticalCenter
                    width: audioController.width / 7
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

                // Divider
                Rectangle { width: audioController.width / 14; height: 1 * 0.5; color: 'transparent' }

                // Prev
                ControlBtn {
                    icon: "◀◀"
                    onClicked: { audioPlayer.position = 0 }
                }

                // Play / Pause
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: audioController.height * 0.72
                    height: width
                    radius: width / 2
                    color: playMainArea.containsMouse ? '#00ffaa' : '#00cc88'
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: audioPlayer.playbackState === MediaPlayer.PlayingState ? "❚❚" : "▶"
                        font.pixelSize: audioPlayer.playbackState === MediaPlayer.PlayingState ? parent.width / 2.4 : parent.width / 2
                        color: '#002a31'
                        font.bold: true
                    }

                    MouseArea {
                        id: playMainArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: audioPlayer.playbackState === MediaPlayer.PlayingState
                                ? audioPlayer.pause() : audioPlayer.play()
                    }
                }

                // Next
                ControlBtn {
                    icon: "▶▶"
                    onClicked: { audioPlayer.position = audioPlayer.duration }
                }

                // Divider
                Rectangle { width: audioController.width / 4; height: 1; color: 'transparent' }

                // Browse
                ControlBtn {
                    icon: rightPanel.browseIcon
                    onClicked: rightPanel.currentIndex === 0 ? fileDialog.open() : console.log("Browse action for other sources coming soon")
                }
            }
        }
    }

    component ControlBtn: Rectangle {
        property string icon: ""
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
            font.pixelSize: audioController.width / 35
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