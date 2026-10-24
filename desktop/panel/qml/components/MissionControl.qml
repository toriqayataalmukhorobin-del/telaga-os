import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: mcRoot
    anchors.fill: parent
    color: "#cc060f18" // Immersive blur overlay
    visible: opacity > 0
    opacity: 0.0
    z: 150

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    signal closeRequested()
    signal selectWindow(string winId)

    function toggle() {
        if (opacity > 0) close();
        else open();
    }

    function open() {
        opacity = 1.0;
        mcRoot.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        mcRoot.closeRequested();
    }

    Keys.onEscapePressed: mcRoot.close()

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: mcRoot.close()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 36

        // TOP SPACES BAR (macOS Virtual Desktops Bar)
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            height: 82
            width: spacesRow.implicitWidth + 32
            radius: 16
            color: "#6014202d"
            border.color: "#30ffffff"
            border.width: 1

            Row {
                id: spacesRow
                anchors.centerIn: parent
                spacing: 16

                // Desktop 1 (Active)
                Rectangle {
                    width: 100
                    height: 58
                    radius: 8
                    color: "#007aff"
                    border.color: "#ffffff"
                    border.width: 2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        Text { text: "🖥️"; font.pixelSize: 18; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Desktop 1"; color: "#ffffff"; font.pixelSize: 11; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                // Desktop 2
                Rectangle {
                    width: 100
                    height: 58
                    radius: 8
                    color: "#223142"
                    border.color: "#30ffffff"
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        Text { text: "🖥️"; font.pixelSize: 18; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Desktop 2"; color: "#a0b0c0"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                // Add Space (+)
                Rectangle {
                    width: 44
                    height: 58
                    radius: 8
                    color: addMouse.containsMouse ? "#304255" : "#1a2532"
                    border.color: "#30ffffff"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: "#90e0ef"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // CENTER: SPREAD WINDOWS OVERVIEW (Exposé Layout)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            spacing: 36

            // Window 1: Finder
            Rectangle {
                width: 380
                height: 240
                radius: 12
                color: "#18222e"
                border.color: win1Mouse.containsMouse ? "#007aff" : "#40ffffff"
                border.width: win1Mouse.containsMouse ? 3 : 1.5
                scale: win1Mouse.containsMouse ? 1.05 : 1.0

                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Mini titlebar
                    RowLayout {
                        Layout.fillWidth: true
                        Row {
                            spacing: 5
                            Rectangle { width: 8; height: 8; radius: 4; color: "#ff5f56" }
                            Rectangle { width: 8; height: 8; radius: 4; color: "#ffbd2e" }
                            Rectangle { width: 8; height: 8; radius: 4; color: "#27c93f" }
                        }
                        Text { text: "📁 Finder"; color: "#ffffff"; font.pixelSize: 11; font.bold: true; Layout.leftMargin: 6 }
                        Item { Layout.fillWidth: true }
                    }

                    // Content preview
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: "#121b24"
                        Text {
                            anchors.centerIn: parent
                            text: "📁 📄 📥 🖥️"
                            font.pixelSize: 32
                        }
                    }
                }

                MouseArea {
                    id: win1Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mcRoot.selectWindow("finder");
                        mcRoot.close();
                    }
                }
            }

            // Window 2: Terminal
            Rectangle {
                width: 380
                height: 240
                radius: 12
                color: "#18202a"
                border.color: win2Mouse.containsMouse ? "#007aff" : "#40ffffff"
                border.width: win2Mouse.containsMouse ? 3 : 1.5
                scale: win2Mouse.containsMouse ? 1.05 : 1.0

                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Row {
                            spacing: 5
                            Rectangle { width: 8; height: 8; radius: 4; color: "#ff5f56" }
                            Rectangle { width: 8; height: 8; radius: 4; color: "#ffbd2e" }
                            Rectangle { width: 8; height: 8; radius: 4; color: "#27c93f" }
                        }
                        Text { text: "💻 Terminal — telaga@macbook"; color: "#ffffff"; font.pixelSize: 11; font.bold: true; Layout.leftMargin: 6 }
                        Item { Layout.fillWidth: true }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: "#0a1017"
                        Text {
                            anchors.centerIn: parent
                            text: "telaga-os:~$ neofetch"
                            font.family: "Monospace"
                            font.pixelSize: 14
                            color: "#00f5d4"
                        }
                    }
                }

                MouseArea {
                    id: win2Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mcRoot.selectWindow("terminal");
                        mcRoot.close();
                    }
                }
            }
        }
    }
}
