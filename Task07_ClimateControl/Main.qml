import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Window {
    id: root
    width: 700
    height: 650
    visible: true
    title: "HVAC"
    color: "transparent"
    flags: Qt.Window

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: '#062429' }
            GradientStop { position: 0.5; color: '#052227' }
            GradientStop { position: 1.0; color: '#073036' }
        }
    }

    // Main
    Column {
        id: main
        anchors.fill: parent
        anchors.topMargin: parent.height * 0.1
        anchors.bottomMargin: parent.height * 0.1
        anchors.leftMargin: parent.width * 0.1
        anchors.rightMargin: parent.width * 0.1
        spacing: 20

        Text {
            text: "Climate Control"
            font.pixelSize: 24
            font.bold: true
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width * 0.8
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            opacity: 0.3
        }

        Rectangle {
            width: parent.width * 0.9
            height: 1
            color: "transparent"
        }

        Rectangle {
            id: mode
            width: parent.width * 0.9
            height: parent.height * 0.25
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: Gradient {
            orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: '#0d3f48' }
                GradientStop { position: 0.5; color: '#0c4048' }
                GradientStop { position: 1.0; color: '#0b414a' }
            }
            radius: parent.height * 0.04
            border.color: "white"
            border.width: 1

            Column {
                id: modeContent
                anchors.fill: parent
                spacing: 4

                Text {
                    text: "Mode"
                    font.pixelSize: parent.height * 0.12
                    font.bold: true
                    color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    opacity: 0.7
                }

                Row {
                    spacing: modeContent.width * 0.04
                    anchors.horizontalCenter: modeContent.horizontalCenter
                    anchors.top: modeContent.top
                    anchors.topMargin: modeContent.height * 0.25

                    ModeIcon {
                        iconSource: "qrc:/assets/icons/cool.png"
                        onClicked: {
                            console.log("Cool mode selected")
                        }
                    }
                    ModeIcon {
                        iconSource: "qrc:/assets/icons/fan.png"
                        onClicked: {
                            console.log("Fan mode selected")
                        }
                    }
                    ModeIcon {
                        iconSource: "qrc:/assets/icons/heat.png"
                        onClicked: {
                            console.log("Heat mode selected")
                        }
                    }
                    ModeIcon {
                        iconSource: "qrc:/assets/icons/auto.png"
                        onClicked: {
                            console.log("Auto mode selected")
                        }
                    }
                }
            }
        }

        Rectangle {
            id: controls
            width: parent.width * 0.9
            height: parent.height * 0.45
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: Gradient {
            orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: '#0d3f48' }
                GradientStop { position: 0.5; color: '#0c4048' }
                GradientStop { position: 1.0; color: '#0b414a' }
            }
            radius: parent.height * 0.04
            border.color: "white"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "Controls"
                    font.pixelSize: controlsContent.height * 0.015
                    font.bold: true; 
                    color: "white";
                    opacity: 0.7
                    Layout.leftMargin: 2
                    Layout.topMargin: 2
                }

                Item { Layout.fillHeight: true }

                ControlLabel {
                    iconSource: "qrc:/assets/icons/fan.png"
                    labelText: "Fan Speed"
                    percentage: fanSlider.value
                }
                ControlSlider {
                    id: fanSlider
                    value: 57
                    trackColorLeft: "#44cc88"
                    trackColorRight: "#2266aa"
                }

                ControlLabel {
                    iconSource: "qrc:/assets/icons/humidity.png"
                    labelText: "Humidity"
                    percentage: humSlider.value
                }
                ControlSlider {
                    id: humSlider
                    value: 45
                    trackColorLeft: "#2288ff"
                    trackColorRight: "#224488"
                }

                ControlLabel {
                    iconSource: "qrc:/assets/icons/air.png"
                    labelText: "Air Quality"
                    percentage: airSlider.value
                }
                ControlSlider {
                    id: airSlider
                    value: 75
                    trackColorLeft: "#cc66ff"
                    trackColorRight: "#442288"
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // Mode Icon Component
    component ModeIcon: Rectangle {
        id: modeIcon
        property string iconSource: ""
        signal clicked()

        width: modeContent.width * 0.16
        height: width
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: '#04171a' }
            GradientStop { position: 1.0; color: '#072a31' }
        }
        radius: height * 0.2
        border.color: '#1e6e7d'
        border.width: 1

        Image{
            anchors.centerIn: parent
            source: iconSource
            width: parent.width * 0.6
            height: parent.height * 0.6
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                parent.opacity = 0.75
            }
            onExited: {
                modeIcon.opacity = 1
            }
            onClicked: {
                modeIcon.clicked()
            }
        }
    }

    component ControlLabel: RowLayout {
        id: controlLabel
        property string iconSource: ""
        property string labelText: ""
        property int percentage: 0

        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12

        Row {
            spacing: 8
            Image {
                source: controlLabel.iconSource
                width: 20;
                height: 20
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: controlLabel.labelText
                font.pixelSize: 14
                font.bold: true
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item { Layout.fillWidth: true }

        Text {
            text: controlLabel.percentage + "%"
            font.pixelSize: 14
            font.bold: true
            color: "white"
        }
    }

    component ControlSlider: Item {
        id: controlSlider
        property color trackColorLeft: "#44cc88"
        property color trackColorRight: "#2266aa"
        property alias value: slider.value

        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: 28

        Slider {
            id: slider
            anchors.fill: parent
            from: 0;
            to: 100;
            stepSize: 1

            background: Item {
                implicitHeight: 28

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 6; radius: 3
                    color: Qt.rgba(1, 1, 1, 0.10)
                    border.color: Qt.rgba(1, 1, 1, 0.06); border.width: 1
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: slider.visualPosition * parent.width
                    height: 6; radius: 3
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: controlSlider.trackColorLeft  }
                        GradientStop { position: 1.0; color: controlSlider.trackColorRight }
                    }
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding  + slider.availableHeight / 2 - height / 2
                width: 28; height: 28; radius: 14
                color: Qt.rgba(0.85, 0.92, 1.0, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.80); border.width: 1
                scale: slider.pressed ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                Rectangle {
                    width: 10; height: 10; radius: 5
                    anchors.centerIn: parent
                    color: controlSlider.trackColorLeft
                    opacity: 0.75
                }
            }
        }
    }
}
