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

    signal openFinderRequested()
    signal openTerminalRequested()
    signal toggleFullscreenRequested()
    signal openShortcutsRequested()
    signal openAboutRequested()

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
            Row {
                spacing: 2

                // 1. BERKAS (File)
                Rectangle {
                    width: fileTxt.implicitWidth + 14
                    height: 22
                    radius: 5
                    color: fileMouse.containsMouse || fileMenu.opened ? "#25ffffff" : "transparent"

                    Text {
                        id: fileTxt
                        anchors.centerIn: parent
                        text: "Berkas"
                        color: "#e0e8f0"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: fileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: fileMenu.open()
                    }

                    Menu {
                        id: fileMenu
                        y: parent.height + 4
                        MenuItem {
                            text: "📁 Jendela Finder Baru"
                            onTriggered: topBarRoot.openFinderRequested()
                        }
                        MenuItem {
                            text: "💻 Terminal Baru"
                            onTriggered: topBarRoot.openTerminalRequested()
                        }
                        MenuSeparator {}
                        MenuItem {
                            text: "🔒 Kunci Layar"
                            onTriggered: sysInfoItem.lock()
                        }
                    }
                }

                // 2. SUNTING (Edit)
                Rectangle {
                    width: editTxt.implicitWidth + 14
                    height: 22
                    radius: 5
                    color: editMouse.containsMouse || editMenu.opened ? "#25ffffff" : "transparent"

                    Text {
                        id: editTxt
                        anchors.centerIn: parent
                        text: "Sunting"
                        color: "#e0e8f0"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: editMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: editMenu.open()
                    }

                    Menu {
                        id: editMenu
                        y: parent.height + 4
                        MenuItem { text: "✂️ Potong (Cut)"; enabled: false }
                        MenuItem { text: "📋 Salin (Copy)"; enabled: false }
                        MenuItem { text: "📄 Tempel (Paste)"; enabled: false }
                        MenuSeparator {}
                        MenuItem { text: "🔍 Cari (Spotlight)..."; onTriggered: topBarRoot.toggleSpotlight() }
                    }
                }

                // 3. TAMPILAN (View)
                Rectangle {
                    width: viewTxt.implicitWidth + 14
                    height: 22
                    radius: 5
                    color: viewMouse.containsMouse || viewMenu.opened ? "#25ffffff" : "transparent"

                    Text {
                        id: viewTxt
                        anchors.centerIn: parent
                        text: "Tampilan"
                        color: "#e0e8f0"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: viewMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: viewMenu.open()
                    }

                    Menu {
                        id: viewMenu
                        y: parent.height + 4
                        MenuItem {
                            text: "🖥️ Beralih Layar Penuh (Full Screen)"
                            onTriggered: topBarRoot.toggleFullscreenRequested()
                        }
                        MenuItem {
                            text: "⊞ Mission Control (F3)"
                            onTriggered: topBarRoot.toggleMissionControl()
                        }
                        MenuItem {
                            text: "🗓️ Bilah Widget"
                            onTriggered: topBarRoot.toggleWidgets()
                        }
                    }
                }

                // 4. JENDELA (Window)
                Rectangle {
                    width: winTxt.implicitWidth + 14
                    height: 22
                    radius: 5
                    color: winMouse.containsMouse || winMenu.opened ? "#25ffffff" : "transparent"

                    Text {
                        id: winTxt
                        anchors.centerIn: parent
                        text: "Jendela"
                        color: "#e0e8f0"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: winMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: winMenu.open()
                    }

                    Menu {
                        id: winMenu
                        y: parent.height + 4
                        MenuItem {
                            text: "📁 Finder"
                            onTriggered: topBarRoot.openFinderRequested()
                        }
                        MenuItem {
                            text: "💻 Terminal"
                            onTriggered: topBarRoot.openTerminalRequested()
                        }
                        MenuItem {
                            text: "🌐 Peramban Web (Safari)"
                            onTriggered: sysInfoItem.launchCommand("safari")
                        }
                    }
                }

                // 5. BANTUAN (Help)
                Rectangle {
                    width: helpTxt.implicitWidth + 14
                    height: 22
                    radius: 5
                    color: helpMouse.containsMouse || helpMenu.opened ? "#25ffffff" : "transparent"

                    Text {
                        id: helpTxt
                        anchors.centerIn: parent
                        text: "Bantuan"
                        color: "#e0e8f0"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: helpMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: helpMenu.open()
                    }

                    Menu {
                        id: helpMenu
                        y: parent.height + 4
                        MenuItem {
                            text: "⌨️ Pintasan Keyboard (Shortcuts)"
                            onTriggered: topBarRoot.openShortcutsRequested()
                        }
                        MenuItem {
                            text: "ℹ️ Tentang Telaga OS"
                            onTriggered: topBarRoot.openAboutRequested()
                        }
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
                text: sysInfoItem.wifiEnabled ? "📶" : "🚫"
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

                ToolTip.visible: spotMouse.containsMouse
                ToolTip.text: "Pencarian Spotlight (Ctrl+Space)"
                ToolTip.delay: 200
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

                ToolTip.visible: ccMouse.containsMouse
                ToolTip.text: "Pusat Kontrol (Control Center)"
                ToolTip.delay: 200
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
