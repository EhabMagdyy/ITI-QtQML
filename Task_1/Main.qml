import QtQuick
import QtQuick.Controls
import QtMultimedia
import "MainScreenWidgets"
import "Pages"

pragma ComponentBehavior: Bound

ApplicationWindow{
    id: mainWindow
    width: 1278
    height: 726
    visible: true
    title: qsTr("Ferrari")

    // Control which screen is visible
    property bool splashDone: false

    // Splash screen
    Item{
        id: splashScreen
        anchors.fill: parent
        visible: !mainWindow.splashDone

        Behavior on opacity {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
        }

        Video{
            id: splashVideo
            anchors.fill: parent
            source: "qrc:/videos/splash.mp4"
            autoPlay: true
            loops: MediaPlayer.Once

            onPlaybackStateChanged:{
                if(playbackState === MediaPlayer.StoppedState){
                    mainWindow.splashDone = true
                }
            }
        }
    }

    // Main Screen
    Item{
        id: mainScreen
        anchors.fill: parent
        visible: mainWindow.splashDone

        Behavior on opacity {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
        }

        StackView {
            id: stackView
            anchors.fill: parent

            initialItem: Rectangle{
                id: background
                anchors.fill: parent
                color: '#bd130202'

                Column{
                    anchors.centerIn: parent
                    spacing: 20

                    Text{
                        text: "Ferrari Dashboard"
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 40
                        color: "white"
                    }
                    Row{
                        spacing: 40

                        // Date
                        Text{
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
                            font.pixelSize: 20
                            color: "white"
                        }
                        // Time
                        Text{
                            text: Qt.formatDateTime(new Date(), "hh:mm:ss AP")
                            font.pixelSize: 20
                            color: "white"
                        }
                    }
                    // Underline
                    Rectangle {
                        width: parent.width
                        height: 2
                        radius: 1
                        color: '#cbffffff'
                        opacity: 0.2
                    }

                    Rectangle {
                        width: parent.width
                        height: 15
                        color: "transparent"
                    }

                    Row{
                        spacing: 40

                        TempWidget {
                            id: tempWidget
                        }

                        HumidityWidget {
                            id: humWidget
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 15
                        color: "transparent"
                    }

                    GalleryWidget {
                        id: galleryWidget
                        stackView: stackView
                        galleryPage: galleryPage
                    }

                    Rectangle {
                        width: parent.width
                        height: 20
                        color: "transparent"
                    }

                    AboutWidget {
                        id: aboutWidget
                        aboutPopup: aboutPopup
                    }
                }
            }
        }
    }

    PopupPage {
        id: aboutPopup
    }

    Component {
        id: galleryPage
        Rectangle {
            color: "#ffffff"
            anchors.fill: parent

            Button {
                text: "Back"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10
                onClicked: stackView.pop()
            }

            Text {
                text: "Welcome to Gallery!"
                anchors.centerIn: parent
                font.pixelSize: 30
            }
        }
    }
}