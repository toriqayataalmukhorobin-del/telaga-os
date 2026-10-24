import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: finderWindowRoot
    width: 720
    height: 460
    radius: 12
    color: "#18222e"
    border.color: "#35ffffff"
    border.width: 1.2
    clip: true

    // Window shadow
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: "#20000000"
        border.width: 3
        z: -1
    }

    signal closeRequested()
    signal minimizeRequested()

    property bool isMinimized: false
    property real originalX: 0
    property real originalY: 0
    property real originalScale: 1.0

    // Genie Minimize & Restore Animation
    ParallelAnimation {
        id: minimizeAnim
        NumberAnimation { target: finderWindowRoot; property: "scale"; to: 0.05; duration: 220; easing.type: Easing.InCubic }
        NumberAnimation { target: finderWindowRoot; property: "opacity"; to: 0.0; duration: 200 }
        NumberAnimation { target: finderWindowRoot; property: "y"; to: finderWindowRoot.parent ? finderWindowRoot.parent.height - 40 : 600; duration: 220; easing.type: Easing.InCubic }
        onFinished: {
            finderWindowRoot.visible = false;
            finderWindowRoot.isMinimized = true;
        }
    }

    ParallelAnimation {
        id: restoreAnim
        NumberAnimation { target: finderWindowRoot; property: "scale"; to: 1.0; duration: 240; easing.type: Easing.OutCubic }
        NumberAnimation { target: finderWindowRoot; property: "opacity"; to: 1.0; duration: 200 }
        NumberAnimation { target: finderWindowRoot; property: "y"; to: finderWindowRoot.originalY; duration: 240; easing.type: Easing.OutCubic }
        onFinished: {
            finderWindowRoot.isMinimized = false;
        }
    }

    function genieMinimize() {
        originalX = x;
        originalY = y;
        minimizeAnim.restart();
    }

    function genieRestore() {
        visible = true;
        restoreAnim.restart();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // TITLEBAR / HEADER (macOS Traffic Lights + Search)
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            height: 48
            color: "#1d2937"
            border.color: "#28ffffff"
            border.width: 1

            // Drag window handler
            MouseArea {
                id: dragArea
                anchors.fill: parent
                property point clickPos: "0,0"

                onPressed: (mouse) => {
                    clickPos = Qt.point(mouse.x, mouse.y)
                }

                onPositionChanged: (mouse) => {
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    finderWindowRoot.x += delta.x
                    finderWindowRoot.y += delta.y
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                // Traffic Light Buttons (Red, Yellow, Green)
                Item {
                    width: 56
                    height: 14

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        // Close (Red)
                        Rectangle {
                            width: 12; height: 12; radius: 6
                            color: "#ff5f56"
                            border.color: "#e0443e"; border.width: 0.5
                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: "#4d0000"
                                font.pixelSize: 11
                                font.bold: true
                                visible: trafficArea.containsMouse
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: finderWindowRoot.closeRequested()
                            }
                        }

                        // Minimize (Yellow)
                        Rectangle {
                            width: 12; height: 12; radius: 6
                            color: "#ffbd2e"
                            border.color: "#dea123"; border.width: 0.5
                            Text {
                                anchors.centerIn: parent
                                text: "–"
                                color: "#5e3e00"
                                font.pixelSize: 9
                                font.bold: true
                                visible: trafficArea.containsMouse
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: finderWindowRoot.genieMinimize()
                            }
                        }

                        // Maximize (Green)
                        Rectangle {
                            width: 12; height: 12; radius: 6
                            color: "#27c93f"
                            border.color: "#1aab29"; border.width: 0.5
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                color: "#004008"
                                font.pixelSize: 10
                                font.bold: true
                                visible: trafficArea.containsMouse
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (finderWindowRoot.width > 900) {
                                        finderWindowRoot.width = 720;
                                        finderWindowRoot.height = 460;
                                    } else {
                                        finderWindowRoot.width = 960;
                                        finderWindowRoot.height = 560;
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: trafficArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: finderWindowRoot.closeRequested()
                    }
                }

                // Window Title
                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "📁 Finder — Berkas Saya"
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Search Box inside Finder
                Rectangle {
                    width: 160
                    height: 28
                    radius: 8
                    color: "#2a394a"
                    border.color: "#40ffffff"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6
                        Text { text: "🔍"; font.pixelSize: 11; color: "#90a0b0" }
                        Text { text: "Cari di Berkas..."; font.pixelSize: 11; color: "#708090" }
                    }
                }
            }
        }

        // BODY: Sidebar + Content Area
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Left Sidebar (macOS Glassy Sidebar)
            Rectangle {
                Layout.preferredWidth: 190
                Layout.fillHeight: true
                color: "#16202c"
                border.color: "#20ffffff"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: "FAVORIT"
                        color: "#6c7a89"
                        font.pixelSize: 10
                        font.bold: true
                        Layout.bottomMargin: 4
                    }

                    Repeater {
                        model: [
                            { name: "Semua Berkas", icon: "📁", active: true },
                            { name: "Aplikasi", icon: "🚀", active: false },
                            { name: "Dokumen", icon: "📄", active: false },
                            { name: "Unduhan", icon: "📥", active: false },
                            { name: "Desktop", icon: "🖥️", active: false },
                            { name: "Telaga Cloud", icon: "☁️", active: false }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            radius: 6
                            color: modelData.active ? "#007aff" : (sideMouse.containsMouse ? "#223142" : "transparent")

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Text { text: modelData.icon; font.pixelSize: 13 }
                                Text {
                                    text: modelData.name
                                    color: modelData.active ? "#ffffff" : "#c0d0e0"
                                    font.pixelSize: 12
                                    font.bold: modelData.active
                                }
                            }

                            MouseArea {
                                id: sideMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // Main Content Area (macOS File Grid)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#131b24"

                GridView {
                    id: fileGrid
                    anchors.fill: parent
                    anchors.margins: 18
                    cellWidth: 105
                    cellHeight: 110
                    clip: true

                    model: [
                        { name: "Proyek Telaga", icon: "📁", isFolder: true },
                        { name: "Dokumen Penting", icon: "📁", isFolder: true },
                        { name: "Wallpaper 4K", icon: "📁", isFolder: true },
                        { name: "Laporan.pdf", icon: "📕", isFolder: false },
                        { name: "Musik Santai.mp3", icon: "🎵", isFolder: false },
                        { name: "Desain UI.fig", icon: "🎨", isFolder: false },
                        { name: "Script.sh", icon: "📜", isFolder: false }
                    ]

                    delegate: Rectangle {
                        width: fileGrid.cellWidth - 10
                        height: fileGrid.cellHeight - 10
                        radius: 8
                        color: fileMouse.containsMouse ? "#20ffffff" : "transparent"

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                font.pixelSize: 42
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: fileGrid.cellWidth - 16
                                text: modelData.name
                                color: "#ffffff"
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: fileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }
}
