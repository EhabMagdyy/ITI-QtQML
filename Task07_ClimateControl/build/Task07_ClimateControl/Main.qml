import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Window {
    id: root
    width: 450
    height: 500
    visible: true
    title: "Climate Control"
    color: "transparent"
    flags: Qt.Window

    // Background
    Rectangle {
        id: bg
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: '#221751' }
            GradientStop { position: 0.5; color: '#1d194b' }
            GradientStop { position: 1.0; color: '#341572' }
        }
    }

    // Main layout

}
