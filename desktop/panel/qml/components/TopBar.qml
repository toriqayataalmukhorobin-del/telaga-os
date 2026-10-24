import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: topBarRoot
    height: 30
    color: "#d9121922" // Frosted glass top bar
    border.color: "#20ffffff"
    border.width: 1

    signal toggleTelagaMenu()
    signal toggleSpotlight()
    signal toggleControlCenter()
    signal toggleMissionControl()
    signal toggleWidgets()

    property alias sysInfo: sysInfoItem

    SystemInfo {
        id: sysInfoItem
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 0

        // LEFT: Apple/Telaga Logo + App Menus
        RowLayout {
            spacing: 2

            // Logo Telaga 🌊 (Apple icon equivalent)
            Rectangle {
                width: 28
                height: 22
                radius: 5
                color: logoMouse.containsMouse ? "#20ffffff" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "🌊"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: logoMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: topBarRoot.toggleTelagaMenu()
                }
            }

            // Current App Name (Bold)
            Text {
                text: " Telaga OS "
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
            }

            // Standard macOS App Menus
            Repeater {
                model: ["Berkas", "Sunting", "Tampilan", "Jendela", "Bantuan"]
                Rectangle {
                    width: menuText.implicitWidth + 14
                    height: 22
                    radius: 5
                    color: itemMouse.containsMouse ? "#25ffffff" : "transparent"

                    Text {
                        id: menuText
                        anchors.centerIn: parent
                        text: modelData
                        color: "#e0e8f0"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // SPACER
        Item {
            Layout.fillWidth: true
        }

        // RIGHT: System Tray & Status Controls
        RowLayout {
            spacing: 8

            // RAM Pill
            Rectangle {
                height: 20
                width: ramTxt.implicitWidth + 14
                radius: 10
                color: "#20ffffff"

                Text {
                    id: ramTxt
                    anchors.centerIn: parent
                    text: "🧠 " + sysInfoItem.ramUsagePercent + "%"
                    color: "#a0e0ff"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            // Battery (if available)
            Text {
                text: sysInfoItem.hasBattery ? (sysInfoItem.isCharging ? "⚡" : "🔋") + sysInfoItem.batteryPercent + "%" : ""
                color: "#e0e8f0"
                font.pixelSize: 12
                visible: sysInfoItem.hasBattery
            }

            // WiFi icon
            Text {
                text: "📶"
                font.pixelSize: 12
            }

            // Mission Control Trigger Icon 🔲
            Rectangle {
                width: 26
                height: 22
                radius: 5
                color: mcMouse.containsMouse ? "#25ffffff" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "⊞"
                    font.pixelSize: 13
                    color: "#ffffff"
                }

                MouseArea {
                    id: mcMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: topBarRoot.toggleMissionControl()
                }

                ToolTip.visible: mcMouse.containsMouse
                ToolTip.text: "Mission Control (F3)"
                ToolTip.delay: 200
            }

            // Spotlight Search Trigger Icon 🔍
            Rectangle {
                width: 26
                height: 22
                radius: 5
                color: spotMouse.containsMouse ? "#25ffffff" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "🔍"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: spotMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: topBarRoot.toggleSpotlight()
                }
            }

            // Control Center Trigger Icon 🎛️
            Rectangle {
                width: 26
                height: 22
                radius: 5
                color: ccMouse.containsMouse ? "#25ffffff" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "🎛️"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: ccMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: topBarRoot.toggleControlCenter()
                }
            }

            // Clock & Date (Clickable to open Widgets Center)
            Rectangle {
                height: 22
                width: clockText.implicitWidth + 10
                radius: 5
                color: dateMouse.containsMouse ? "#20ffffff" : "transparent"

                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(new Date(), "ddd d MMM  hh:mm")
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        clockText.text = Qt.formatDateTime(new Date(), "ddd d MMM  hh:mm");
                    }
                }

                MouseArea {
                    id: dateMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: topBarRoot.toggleWidgets()
                }

                ToolTip.visible: dateMouse.containsMouse
                ToolTip.text: "Pusat Widget"
                ToolTip.delay: 300
            }
        }
    }
}
