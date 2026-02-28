import QtQuick
import QtQuick.Controls
import QtMultimedia
import "Widgets"
import "Pages"

pragma ComponentBehavior: Bound

ApplicationWindow{
    id: mainWindow
    width: 1280
    height: 960
    visible: true
    background: Rectangle {
        color: '#ecf02729'
    }
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
                        font.pixelSize: 44
                        color: "white"
                        font.bold: true
                        font.family: "Arial"
                    }
                    Row{
                        spacing: 40
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Date
                        Text{
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
                            font.pixelSize: 20
                            color: "#e8fffb00"
                        }
                        // Time
                        Text{
                            id: timeText
                            text: Qt.formatDateTime(new Date(), "hh:mm:ss AP")
                            font.pixelSize: 20
                            color: "#e8fffb00"

                            Timer{
                                interval: 1000; 
                                running: true; 
                                repeat: true
                                onTriggered: timeText.text = Qt.formatDateTime(new Date(), "hh:mm:ss AP")
                            }
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
                        height: 35
                        color: "transparent"
                    }

                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 40

                        HumidityWidget {
                            id: humWidget
                        }

                        TempWidget {
                            id: tempWidget
                        }

                        WindWidget{
                            id: windWidget
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 25
                        color: "transparent"
                    }

                    GalleryWidget {
                        id: galleryWidget
                        stackView: stackView
                        galleryPage: galleryPage
                    }

                    Rectangle {
                        width: parent.width
                        height: 35
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

    AboutPopupPage {
        id: aboutPopup
    }

    Component {
        id: galleryPage
        GalleryPage {
            id: galleryPagerect
            imagePopup: imagePopup
            stackView: stackView
        }
    }

    ImagePopupPage {
        id: imagePopup
    }
    
}
