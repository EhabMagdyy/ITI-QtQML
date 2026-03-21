import QtQuick
import QtQuick.Controls
import QtMultimedia

Rectangle {
    id: radioPage
    required property StackView stackView
    anchors.fill: parent
    color: "transparent"

    // ── Player ────────────────────────────────────────────────
    MediaPlayer {
        id: radioPlayer
        source: "https://stream.radioparadise.com/aac-320"
        audioOutput: AudioOutput { id: audioOut; volume: volumeSlider.value }

        // onMetaDataChanged: {
        //     var md = radioPlayer.metaData
        //     stationName.text   = md.value(MediaMetaData.AlbumArtist)  || "Unknown"
        //     nowPlaying.text    = md.value(MediaMetaData.Title)         || "—"
        //     genreText.text     = md.value(MediaMetaData.Genre)         || "Unknown"
        //     bitrateText.text   = (md.value(MediaMetaData.AudioBitRate) || "320") + " kbps"
        // }

        // onMediaStatusChanged: {
        //     if      (mediaStatus === MediaPlayer.BufferingMedia) statusDot.color = "#ffaa00"
        //     else if (mediaStatus === MediaPlayer.BufferedMedia)  statusDot.color = "#00ffaa"
        //     else if (mediaStatus === MediaPlayer.StalledMedia)   statusDot.color = "#ff4444"
        //     else if (mediaStatus === MediaPlayer.NoMedia)        statusDot.color = "#555555"
        // }
    }
    // ====================================== Audio Control Container =======================================
    Rectangle{
        id: audioContainer
        anchors.centerIn: parent
        width: radioPage.width / 1.5
        height: radioPage.height / 18
        radius: height / 2
        color: '#368e91'

        Row{
            id: audioContRow
            anchors.centerIn: parent
            spacing: audioContainer.width / 80
            Rectangle {
                id: playBtn
                anchors.verticalCenter: parent.verticalCenter
                width: audioContainer.width / 30
                height: audioContainer.height / 1.4
                radius: height / 10
                color: playArea.containsMouse ? '#021418' : '#072a30'
                border.color: '#00e4ffff'
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: playText
                    anchors.centerIn: parent
                    text: radioPlayer.playbackState === MediaPlayer.PlayingState ? "❚❚" : "▶"
                    color: '#ffffff'
                    font.pixelSize: radioPlayer.playbackState === MediaPlayer.PlayingState ? (parent.width + parent.height) / 5 : (parent.width + parent.height) / 4
                    font.family: "Arial"
                    font.bold: true
                }

                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        radioPlayer.playbackState === MediaPlayer.PlayingState ? radioPlayer.pause() : radioPlayer.play()
                    }
                }
            }

            Rectangle{
                height: 1
                width: audioContainer.width / 100
                color: "transparent"
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: audioContainer.width / 1.6
                height: 4
                radius: 2
                color: '#106372'

                // Blue filled portion
                Rectangle {
                    width: parent.width * radioPlayer.bufferProgress
                    height: parent.height
                    radius: parent.radius
                    color: '#002a31'
                    Behavior on width { NumberAnimation { duration: 300 } }
                }

                // White dot handle at the end
                Rectangle {
                    x: (parent.width * radioPlayer.bufferProgress) - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 10
                    height: 10
                    radius: 5
                    color: '#1a1b1b'
                    Behavior on x { NumberAnimation { duration: 300 } }
                }
            }

            Rectangle{
                height: 1
                width: audioContainer.width / 80
                color: "transparent"
            }

            Rectangle {
                id: volumeBtn
                anchors.verticalCenter: parent.verticalCenter
                width: audioContainer.width / 30
                height: audioContainer.height / 1.4
                radius: height / 10
                color: muteArea.containsMouse ? '#021316' : '#042929'
                border.color: '#00e4ffff'
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                property bool muted: false

                Text {
                    anchors.centerIn: parent
                    text: volumeBtn.muted ? "🔈" : volumeSlider.value < 0.5 ? "🔉" : "🔊"
                    font.pixelSize: (parent.width + parent.height) / 4
                    font.family: "Arial"
                }

                MouseArea {
                    id: muteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        volumeBtn.muted = !volumeBtn.muted
                        audioOut.muted = volumeBtn.muted
                    }
                }
            }

            Slider {
                id: volumeSlider
                anchors.verticalCenter: parent.verticalCenter
                width: audioContainer.width / 7
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
                    height: 4
                    radius: 2
                    color: '#05262c'

                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: '#50dbad' }
                            GradientStop { position: 1.0; color: '#22d499' }
                        }
                    }
                }
            }
        }
    }

    // ============================================ Back button ===============================================
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: radioPage.height / 15
        anchors.leftMargin: radioPage.width / 25
        width: backText.width + 40
        height: backText.height + 18
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
            font.pixelSize: radioPage.width / 60
            font.family: "Arial"
            font.bold: true
        }

        MouseArea {
            id: backArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                radioPlayer.stop()
                radioPage.stackView.pop()
            }
        }
    }
}