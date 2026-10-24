import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: finderWindowRoot
    width: 760
    height: 480
    radius: 12
    color: "#18222e"
    border.color: "#35ffffff"
    border.width: 1.2
    clip: true

    SystemInfo {
        id: sysInfo
    }

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
    property bool isMaximized: false
    property real normalX: 180
    property real normalY: 80
    property real normalWidth: 760
    property real normalHeight: 480
    property real originalScale: 1.0

    property string currentCategory: "Semua Berkas"
    property var fileItems: sysInfo.listFiles(currentCategory)

    function refreshFiles() {
        fileItems = sysInfo.listFiles(currentCategory);
    }

    // Genie Minimize & Restore Animation (Sucking into dock's Finder icon)
    ParallelAnimation {
        id: minimizeAnim
        NumberAnimation { target: finderWindowRoot; property: "scale"; to: 0.05; duration: 240; easing.type: Easing.InCubic }
        NumberAnimation { target: finderWindowRoot; property: "opacity"; to: 0.0; duration: 200 }
        NumberAnimation {
            target: finderWindowRoot; property: "x";
            to: finderWindowRoot.parent ? (finderWindowRoot.parent.width / 2 - 130) : 380;
            duration: 240; easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: finderWindowRoot; property: "y";
            to: finderWindowRoot.parent ? (finderWindowRoot.parent.height - 40) : 600;
            duration: 240; easing.type: Easing.InCubic
        }
        onFinished: {
            finderWindowRoot.visible = false;
            finderWindowRoot.isMinimized = true;
        }
    }

    ParallelAnimation {
        id: restoreAnim
        NumberAnimation { target: finderWindowRoot; property: "scale"; to: 1.0; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { target: finderWindowRoot; property: "opacity"; to: 1.0; duration: 200 }
        NumberAnimation { target: finderWindowRoot; property: "x"; to: finderWindowRoot.normalX; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { target: finderWindowRoot; property: "y"; to: finderWindowRoot.normalY; duration: 250; easing.type: Easing.OutCubic }
        onFinished: {
            finderWindowRoot.isMinimized = false;
        }
    }

    function genieMinimize() {
        if (!isMaximized) {
            normalX = x;
            normalY = y;
        }
        minimizeAnim.restart();
    }

    function genieRestore() {
        visible = true;
        restoreAnim.restart();
    }

    function toggleMaximize() {
        if (isMaximized) {
            // Restore normal
            x = normalX;
            y = normalY;
            width = normalWidth;
            height = normalHeight;
            isMaximized = false;
        } else {
            // Maximize
            normalX = x;
            normalY = y;
            normalWidth = width;
            normalHeight = height;
            x = 12;
            y = 36;
            width = parent ? parent.width - 24 : 1200;
            height = parent ? parent.height - 36 - 86 : 600;
            isMaximized = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // TITLEBAR / HEADER (macOS Traffic Lights + Controls + Search)
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
                    if (finderWindowRoot.isMaximized) {
                        finderWindowRoot.toggleMaximize();
                    }
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    let newX = finderWindowRoot.x + delta.x;
                    let newY = finderWindowRoot.y + delta.y;

                    // Clamping to screen workspace
                    let minX = -finderWindowRoot.width + 100;
                    let maxX = (finderWindowRoot.parent ? finderWindowRoot.parent.width : 1280) - 100;
                    let minY = 32;
                    let maxY = (finderWindowRoot.parent ? finderWindowRoot.parent.height : 760) - 60;

                    finderWindowRoot.x = Math.max(minX, Math.min(maxX, newX));
                    finderWindowRoot.y = Math.max(minY, Math.min(maxY, newY));
                }

                onDoubleClicked: finderWindowRoot.toggleMaximize()
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 14

                // Traffic Light Buttons (Red, Yellow, Green)
                Item {
                    id: trafficBox
                    width: 58
                    height: 16
                    property bool hovered: false

                    HoverHandler {
                        onHoveredChanged: trafficBox.hovered = hovered
                    }

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
                                visible: trafficBox.hovered
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: finderWindowRoot.closeRequested()
                            }
                        }

                        // Minimize (Yellow - Genie)
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
                                visible: trafficBox.hovered
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
                                visible: trafficBox.hovered
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: finderWindowRoot.toggleMaximize()
                            }
                        }
                    }
                }

                // Window Title
                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "📁 Finder — " + finderWindowRoot.currentCategory
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Quick Launch Native File Manager (PCManFM) Button
                Rectangle {
                    width: pcmanfmTxt.implicitWidth + 18
                    height: 26
                    radius: 6
                    color: pcmanfmMouse.containsMouse ? "#3a4d62" : "#283544"
                    border.color: "#30ffffff"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "↗"; color: "#a0e0ff"; font.pixelSize: 11; font.bold: true }
                        Text { id: pcmanfmTxt; text: "PCManFM"; color: "#ffffff"; font.pixelSize: 11; font.bold: true }
                    }

                    MouseArea {
                        id: pcmanfmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sysInfo.launchCommand("finder")
                    }

                    ToolTip.visible: pcmanfmMouse.containsMouse
                    ToolTip.text: "Buka di Pengelola Berkas Eksternal (PCManFM)"
                    ToolTip.delay: 300
                }

                // Search Box inside Finder
                Rectangle {
                    width: 160
                    height: 28
                    radius: 8
                    color: "#2a394a"
                    border.color: searchInput.activeFocus ? "#007aff" : "#40ffffff"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6
                        Text { text: "🔍"; font.pixelSize: 11; color: "#90a0b0" }
                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            font.pixelSize: 11
                            color: "#ffffff"
                            clip: true
                            Text {
                                anchors.fill: parent
                                text: "Cari di Berkas..."
                                font.pixelSize: 11
                                color: "#708090"
                                visible: !searchInput.text && !searchInput.activeFocus
                            }
                        }
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
                        id: sideRepeater
                        model: [
                            { name: "Semua Berkas", icon: "📁" },
                            { name: "Dokumen", icon: "📄" },
                            { name: "Unduhan", icon: "📥" },
                            { name: "Desktop", icon: "🖥️" },
                            { name: "Aplikasi", icon: "🚀" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            radius: 6
                            property bool isActive: finderWindowRoot.currentCategory === modelData.name
                            color: isActive ? "#007aff" : (sideMouse.containsMouse ? "#223142" : "transparent")

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Text { text: modelData.icon; font.pixelSize: 13 }
                                Text {
                                    text: modelData.name
                                    color: parent.parent.isActive ? "#ffffff" : "#c0d0e0"
                                    font.pixelSize: 12
                                    font.bold: parent.parent.isActive
                                }
                            }

                            MouseArea {
                                id: sideMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    finderWindowRoot.currentCategory = modelData.name;
                                    finderWindowRoot.refreshFiles();
                                }
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
                    cellWidth: 110
                    cellHeight: 115
                    clip: true
                    model: finderWindowRoot.fileItems

                    ScrollBar.vertical: ScrollBar { active: true }

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
                                text: modelData.icon ? modelData.icon : "📄"
                                font.pixelSize: 42
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: fileGrid.cellWidth - 16
                                text: modelData.name ? modelData.name : ""
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
                            onDoubleClicked: {
                                if (modelData.path) {
                                    sysInfo.openFile(modelData.path);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
