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
    property bool splashDone: true

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
            autoPlay: false
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

    AboutPopupPage {
        id: aboutPopup
    }

    Component {
        id: galleryPage
        
        Rectangle {
            id: galleryPagerect
            anchors.fill: parent
            color: "#bd130202"

            property var ferrariData: [
                {
                    title: "Ferrari Amalfi",
                    color: "Deep Green Metallic",
                    year: 2024,
                    price: "$1,200,000",
                    desc: "A limited-production grand tourer inspired by the Amalfi Coast, blending elegant Italian design with Ferrari's high-performance V12 heritage."
                },
                {
                    title: "Ferrari F80",
                    color: "Rosso Corsa Red",
                    year: 2025,
                    price: "$3,500,000",
                    desc: "Ferrari's next-generation hypercar successor to LaFerrari, combining cutting-edge aerodynamics with hybrid technology and extreme track performance."
                },
                {
                    title: "Ferrari 12Cilindri Spider",
                    color: "Giallo Modena Grey",
                    year: 2024,
                    price: "$520,000",
                    desc: "An open-top V12 grand tourer celebrating Ferrari's legendary 12-cylinder lineage with breathtaking performance and luxury cruising comfort."
                },
                {
                    title: "Ferrari 12Cilindri",
                    color: "Dark Red Metallic",
                    year: 2024,
                    price: "$560,000",
                    desc: "Front-engine V12 coupe built as a modern tribute to Ferrari's classic grand tourers, delivering extreme performance with refined comfort."
                },
                {
                    title: "Ferrari Purosangue",
                    color: "Nero Daytona Black",
                    year: 2024,
                    price: "$410,000",
                    desc: "Ferrari's first four-door performance SUV, featuring a naturally aspirated V12 and blending supercar DNA with everyday usability."
                },
                {
                    title: "Ferrari SF90 XX Spider",
                    color: "Bianco Avus White",
                    year: 2024,
                    price: "$1,300,000",
                    desc: "An extreme open-top evolution of the SF90, track-focused yet road-legal, featuring advanced aerodynamics and over 1,000 horsepower."
                },
                {
                    title: "Ferrari SF90 XX Stradale",
                    color: "Rosso Fuoco",
                    year: 2024,
                    price: "$1,250,000",
                    desc: "The most radical road-going SF90 ever built, combining Formula 1-derived hybrid power with aggressive aero for ultimate performance."
                },
                {
                    title: "Ferrari 296 GTB",
                    color: "Rosso Imola",
                    year: 2023,
                    price: "$322,000",
                    desc: "A mid-engine V6 hybrid supercar delivering razor-sharp handling, blistering acceleration, and Ferrari's modern design language."
                },
                {
                    title: "Ferrari 296 GTS",
                    color: "Argento Nürburgring Silver",
                    year: 2023,
                    price: "$355,000",
                    desc: "The open-top version of the 296 GTB, offering electrified performance with the added thrill of open-air driving."
                }
            ]

            // Back Button
            Rectangle {
                width: 46
                height: 46
                radius: 23
                color: "#e8fffb00"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20

                Text {
                    text: "<"
                    anchors.centerIn: parent
                    font.pixelSize: 28
                    color: "white"
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.pop()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Title
            Text {
                text: "Ferrari Gallery"
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 50
                font.pixelSize: 30
                font.family: "Arial"
                color: "white"
                font.bold: true
            }

            Flickable {
                anchors {
                    top: parent.top
                    topMargin: 100
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                contentWidth: grid.width
                contentHeight: grid.height
                clip: true

                // Center the content when it's smaller than the viewport
                leftMargin: Math.max(0, (width - grid.width) / 2)
                topMargin: Math.max(0, (height - grid.height) / 2)
                
                Grid {
                    id: grid
                    columns: 3
                    spacing: 18
                    padding: 20

                    Repeater {
                        model: galleryPagerect.ferrariData.length
                        Rectangle {
                            id: imgContainer
                            required property int index
                            property int myIdx: index
                            width: 300
                            height: 220
                            radius: 25
                            color: "#1c1c1e"
                            border.color: '#c2c2c2'
                            border.width: 3
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 3
                                source: "qrc:/images/" + (imgContainer.myIdx + 1) + ".png"
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    imagePopup.imageIndex = imgContainer.myIdx
                                    imagePopup.titleText = galleryPagerect.ferrariData[imgContainer.myIdx].title
                                    imagePopup.description = galleryPagerect.ferrariData[imgContainer.myIdx].desc
                                    imagePopup.color = galleryPagerect.ferrariData[imgContainer.myIdx].color
                                    imagePopup.price = galleryPagerect.ferrariData[imgContainer.myIdx].price
                                    imagePopup.year = galleryPagerect.ferrariData[imgContainer.myIdx].year
                                    imagePopup.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ImagePopupPage {
        id: imagePopup
    }
    
}
