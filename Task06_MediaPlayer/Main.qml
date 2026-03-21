import QtQuick
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    id: mainWindow
    width: Screen.width
    height: Screen.height
    // Remove window frame and title bar
    flags: Qt.FramelessWindowHint
    visible: true

    property real fontSize: (width + height) / 60

    // ============================================ Window Background =============================================
    Rectangle {
        anchors.fill: parent
        radius: mainWindow.width / 60
        border.color: '#005045'
        border.width: 2
        gradient: Gradient {
            GradientStop {position: 0.0; color: '#00424b' }
            GradientStop {position: 0.5; color: '#002d35' }
            GradientStop {position: 1.0; color: '#000000' }
        }
    }
    // ======================================== Window Bar & Resize Handles =======================================
    WindowBar {
        id: titleBar
        window: mainWindow
    }

    WindowResize{
        window: mainWindow
    }

    // ============================================ Main Content ================================================
    Row {
        id: mainRow
        anchors.centerIn: parent
        spacing: mainWindow.width / 15
        MediaCard {
            cardWidth: mainWindow.width / 5.5
            cardHeight: mainWindow.height / 2.2
            cardColSpacing: cardHeight / 20
            first: '#55ffda'
            second: '#00bb92'
            third: '#00886a'
            cardRadius: mainRow.spacing / 3
            cardBorderColor: '#d0fff1'
            cardBorderWidth: 3
            cardOpacity: 0.8
            cardText: qsTr("Radio")
            cardIcon: "qrc:/icons/radio.png"
            cardTextFontSize: mainWindow.fontSize * 1.1
            cardTextFontFamily: "Arial"
            cardTextColor: '#f8ffff'
            cardIconWidth: cardWidth / 1.4
            cardIconHeight: cardHeight / 1.4

            onCardClicked: console.log("Radio card clicked")
            onCardEntred: {
                first = Qt.lighter(first, 1.2)
                second = Qt.lighter(second, 1.2)
                third = Qt.lighter(third, 1.2)
            }
            onCardExited: {
                first = '#55ffda'
                second = '#00bb92'
                third = '#00886a'
            }
        }

        MediaCard {
            cardWidth: mainWindow.width / 5.5
            cardHeight: mainWindow.height / 2.2
            cardColSpacing: cardHeight / 20
            first: '#55ffda'
            second: '#00bb92'
            third: '#00886a'
            cardRadius: mainRow.spacing / 3
            cardBorderColor: '#d0fff1'
            cardBorderWidth: 3
            cardOpacity: 0.8
            cardText: qsTr("Audio")
            cardIcon: "qrc:/icons/audio.png"
            cardTextFontSize: mainWindow.fontSize * 1.1
            cardTextFontFamily: "Arial"
            cardTextColor: '#f8ffff'
            cardIconWidth: cardWidth / 1.6
            cardIconHeight: cardHeight / 1.6

            onCardClicked: console.log("Audio card clicked")
            onCardEntred: {
                first = Qt.lighter(first, 1.2)
                second = Qt.lighter(second, 1.2)
                third = Qt.lighter(third, 1.2)
            }
            onCardExited: {
                first = '#55ffda'
                second = '#00bb92'
                third = '#00886a'
            }
        }

        MediaCard {
            cardWidth: mainWindow.width / 5.5
            cardHeight: mainWindow.height / 2.2
            cardColSpacing: cardHeight / 20
            first: '#55ffda'
            second: '#00bb92'
            third: '#00886a'
            cardRadius: mainRow.spacing / 3
            cardBorderColor: '#d0fff1'
            cardBorderWidth: 3
            cardOpacity: 0.8
            cardText: qsTr("Video")
            cardIcon: "qrc:/icons/video.png"
            cardTextFontSize: mainWindow.fontSize * 1.1
            cardTextFontFamily: "Arial"
            cardTextColor: '#f8ffff'
            cardIconWidth: cardWidth / 1.5
            cardIconHeight: cardHeight / 1.5

            onCardClicked: console.log("Radio card clicked")
            onCardEntred: {
                first = Qt.lighter(first, 1.2)
                second = Qt.lighter(second, 1.2)
                third = Qt.lighter(third, 1.2)
            }
            onCardExited: {
                first = '#55ffda'
                second = '#00bb92'
                third = '#00886a'
            }
        }
    }

    // ============================================ Pages ===============================================
    
}
