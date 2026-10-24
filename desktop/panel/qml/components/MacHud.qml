import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: hudRoot
    anchors.centerIn: parent
    width: 170
    height: 170
    radius: 26
    color: "#d9162230" // Frosted dark glass
    border.color: "#40ffffff"
    border.width: 1.2
    visible: opacity > 0
    opacity: 0.0
    z: 200

    property string iconText: "🔊"
    property string titleText: "Volume"
    property real level: 0.75

    Behavior on opacity {
        NumberAnimation { duration: 160 }
    }

    Timer {
        id: hideTimer
        interval: 1600
        onTriggered: hudRoot.opacity = 0.0
    }

    function showVolume(val) {
        iconText = val === 0 ? "🔇" : "🔊";
        titleText = "Volume Suara";
        level = val;
        opacity = 1.0;
        hideTimer.restart();
    }

    function showBrightness(val) {
        iconText = "☀️";
        titleText = "Kecerahan Layar";
        level = val;
        opacity = 1.0;
        hideTimer.restart();
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: hudRoot.iconText
            font.pixelSize: 52
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: hudRoot.titleText
            color: "#ffffff"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        // Stepped macOS Pill Indicator
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 3

            Repeater {
                model: 16
                Rectangle {
                    width: 6
                    height: 9
                    radius: 2
                    color: (index / 16.0) <= hudRoot.level ? "#ffffff" : "#30ffffff"
                }
            }
        }
    }
}
