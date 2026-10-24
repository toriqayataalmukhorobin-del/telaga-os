import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: menuRoot
    width: 240
    height: menuCol.implicitHeight + 16
    radius: 10
    color: "#e61e222d" // Frosted dark glass
    border.color: "#40ffffff"
    border.width: 1

    property alias sysInfo: sysInfoItem
    signal closeRequested()
    signal openAboutRequested()

    SystemInfo {
        id: sysInfoItem
    }

    ColumnLayout {
        id: menuCol
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2

        // About Telaga OS
        MenuItem {
            text: "Tentang Telaga OS"
            iconText: "🌊"
            onTriggered: {
                menuRoot.openAboutRequested();
                menuRoot.closeRequested();
            }
        }

        MenuSeparator {}

        // System Settings
        MenuItem {
            text: "Pengaturan Sistem..."
            iconText: "⚙️"
            onTriggered: {
                sysInfoItem.launchCommand("settings");
                menuRoot.closeRequested();
            }
        }

        // App Store / Software
        MenuItem {
            text: "Pusat Perangkat Lunak..."
            iconText: "🛍️"
            onTriggered: {
                sysInfoItem.launchCommand("software");
                menuRoot.closeRequested();
            }
        }

        // Terminal
        MenuItem {
            text: "Terminal..."
            iconText: "💻"
            onTriggered: {
                sysInfoItem.launchCommand("terminal");
                menuRoot.closeRequested();
            }
        }

        MenuSeparator {}

        // Sleep / Lock
        MenuItem {
            text: "Kunci Layar (Lock)"
            iconText: "🔒"
            shortcut: "⌃⌘Q"
            onTriggered: {
                sysInfoItem.lock();
                menuRoot.closeRequested();
            }
        }

        // Log Out
        MenuItem {
            text: "Keluar (Log Out " + sysInfoItem.username + ")..."
            iconText: "🚪"
            shortcut: "⇧⌘Q"
            onTriggered: {
                sysInfoItem.logout();
                menuRoot.closeRequested();
            }
        }

        MenuSeparator {}

        // Restart
        MenuItem {
            text: "Mulai Ulang (Restart)..."
            iconText: "🔄"
            onTriggered: {
                sysInfoItem.reboot();
                menuRoot.closeRequested();
            }
        }

        // Shut Down
        MenuItem {
            text: "Matikan Daya (Shut Down)..."
            iconText: "⏻"
            isDestructive: true
            onTriggered: {
                sysInfoItem.powerOff();
                menuRoot.closeRequested();
            }
        }
    }

    component MenuItem: Rectangle {
        property string text: ""
        property string iconText: ""
        property string shortcut: ""
        property bool isDestructive: false
        signal triggered()

        Layout.fillWidth: true
        height: 28
        radius: 6
        color: mouseItem.containsMouse ? (isDestructive ? "#e63946" : "#007aff") : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: iconText
                font.pixelSize: 13
            }

            Text {
                Layout.fillWidth: true
                text: parent.parent.text
                color: "#ffffff"
                font.pixelSize: 12
                font.weight: Font.Normal
                elide: Text.ElideRight
            }

            Text {
                text: shortcut
                color: "#80ffffff"
                font.pixelSize: 11
                visible: shortcut.length > 0
            }
        }

        MouseArea {
            id: mouseItem
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.triggered()
        }
    }

    component MenuSeparator: Rectangle {
        Layout.fillWidth: true
        height: 1
        color: "#20ffffff"
        Layout.topMargin: 3
        Layout.bottomMargin: 3
    }
}
