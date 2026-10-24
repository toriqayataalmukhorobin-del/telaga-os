import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: launcherRoot
    width: 620
    height: 520
    radius: 18
    color: "#e60a1622" // Dark lake water blue with transparency
    border.color: "#3300d2d3"
    border.width: 1

    property alias appModel: appModelInstance
    signal appLaunched()

    AppModel {
        id: appModelInstance
    }

    SystemInfo {
        id: sysInfo
    }

    // Shadow / glow effect
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: "#1a00d2d3"
        border.width: 2
        z: -1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        // Top Header: Branding + Search Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Telaga Logo badge
            Rectangle {
                width: 42
                height: 42
                radius: 12
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00b4d8" }
                    GradientStop { position: 1.0; color: "#0077b6" }
                }

                Text {
                    anchors.centerIn: parent
                    text: "🌊"
                    font.pixelSize: 22
                }
            }

            // Search Bar Input
            Rectangle {
                Layout.fillWidth: true
                height: 42
                radius: 12
                color: "#20ffffff"
                border.color: searchInput.activeFocus ? "#00b4d8" : "#30ffffff"
                border.width: 1.5

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "🔍"
                        font.pixelSize: 15
                        color: "#a0b2c6"
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.pixelSize: 14
                        font.bold: false
                        color: "#f0f8ff"
                        clip: true
                        selectByMouse: true

                        Text {
                            anchors.fill: parent
                            text: "Cari aplikasi (contoh: Terminal, Browser, File)..."
                            color: "#708090"
                            font.pixelSize: 14
                            visible: !searchInput.text && !searchInput.activeFocus
                        }

                        onTextChanged: {
                            appModelInstance.filter(text, categoryFilter.currentCategory);
                        }
                    }

                    // Clear button
                    Text {
                        text: "✕"
                        color: "#80ffffff"
                        font.pixelSize: 13
                        visible: searchInput.text.length > 0
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchInput.text = "";
                                appModelInstance.filter("", categoryFilter.currentCategory);
                            }
                        }
                    }
                }
            }
        }

        // Category Filter Pills
        Row {
            id: categoryFilter
            property string currentCategory: "All"
            spacing: 8

            readonly property var categories: ["All", "Network", "Development", "System", "Utility", "AudioVideo"]
            readonly property var labels: ["Semua", "Internet", "Dev", "Sistem", "Utilitas", "Media"]

            Repeater {
                model: categoryFilter.categories.length
                Rectangle {
                    width: catText.implicitWidth + 20
                    height: 28
                    radius: 14
                    color: categoryFilter.currentCategory === categoryFilter.categories[index] ? "#00b4d8" : "#1a2a3a"
                    border.color: categoryFilter.currentCategory === categoryFilter.categories[index] ? "#90e0ef" : "#2a3a4a"
                    border.width: 1

                    Text {
                        id: catText
                        anchors.centerIn: parent
                        text: categoryFilter.labels[index]
                        color: categoryFilter.currentCategory === categoryFilter.categories[index] ? "#03111e" : "#c0d0e0"
                        font.pixelSize: 12
                        font.bold: categoryFilter.currentCategory === categoryFilter.categories[index]
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            categoryFilter.currentCategory = categoryFilter.categories[index];
                            appModelInstance.filter(searchInput.text, categoryFilter.currentCategory);
                        }
                    }
                }
            }
        }

        // Apps Grid
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            GridView {
                id: appsGrid
                anchors.fill: parent
                cellWidth: parent.width / 4
                cellHeight: 96
                clip: true
                model: appModelInstance

                ScrollBar.vertical: ScrollBar {
                    active: true
                }

                delegate: Item {
                    width: appsGrid.cellWidth
                    height: appsGrid.cellHeight

                    Rectangle {
                        id: appCard
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 12
                        color: mouseArea.containsMouse ? "#2a3d52" : "transparent"
                        border.color: mouseArea.containsMouse ? "#48cae4" : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            // App Icon
                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                width: 40
                                height: 40
                                source: model.icon.startsWith("file://") ? model.icon : ("image://theme/" + model.icon)
                                sourceSize.width: 48
                                sourceSize.height: 48
                                fillMode: Image.PreserveAspectFit

                                // Fallback icon if theme or path fails
                                Text {
                                    anchors.centerIn: parent
                                    text: "📦"
                                    font.pixelSize: 26
                                    visible: parent.status === Image.Error || parent.status === Image.Null
                                }
                            }

                            // App Name
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: appsGrid.cellWidth - 16
                                text: model.name
                                color: "#f0f8ff"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appModelInstance.launch(index);
                                launcherRoot.appLaunched();
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    text: "Tidak ada aplikasi ditemukan"
                    color: "#708090"
                    font.pixelSize: 14
                    visible: appsGrid.count === 0
                }
            }
        }

        // Bottom Footer: User Status + Power Actions
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 12
            color: "#14202c"
            border.color: "#243342"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                // User Info
                RowLayout {
                    spacing: 8
                    Text {
                        text: "👤"
                        font.pixelSize: 16
                    }
                    Text {
                        text: sysInfo.username + "@" + sysInfo.hostname
                        color: "#90e0ef"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Item { Layout.fillWidth: true }

                // Quick Power Buttons
                RowLayout {
                    spacing: 6

                    // Lock button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: lockMouse.containsMouse ? "#2c3e50" : "transparent"
                        Text { anchors.centerIn: parent; text: "🔒"; font.pixelSize: 14 }
                        MouseArea {
                            id: lockMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sysInfo.lock()
                        }
                    }

                    // Reboot button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: rebMouse.containsMouse ? "#2c3e50" : "transparent"
                        Text { anchors.centerIn: parent; text: "🔄"; font.pixelSize: 14 }
                        MouseArea {
                            id: rebMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sysInfo.reboot()
                        }
                    }

                    // Power off button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: offMouse.containsMouse ? "#e63946" : "transparent"
                        Text { anchors.centerIn: parent; text: "⏻"; font.pixelSize: 14; color: "#f0f8ff" }
                        MouseArea {
                            id: offMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sysInfo.powerOff()
                        }
                    }
                }
            }
        }
    }
}
