import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: lpRoot
    anchors.fill: parent
    color: "#e60a121c" // Immersive blur overlay
    visible: opacity > 0
    opacity: 0.0

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    signal closeRequested()
    property alias appModel: appModelInstance

    AppModel {
        id: appModelInstance
    }

    function open() {
        opacity = 1.0;
        lpSearch.text = "";
        appModelInstance.filter("");
        lpSearch.forceActiveFocus();
    }

    function close() {
        opacity = 0.0;
        lpRoot.closeRequested();
    }

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: lpRoot.close()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 24

        // Top Search Bar (macOS Launchpad style)
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 320
            height: 36
            radius: 18
            color: "#30ffffff"
            border.color: lpSearch.activeFocus ? "#007aff" : "#40ffffff"
            border.width: 1.2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "🔍"
                    font.pixelSize: 13
                    color: "#c0d0e0"
                }

                TextInput {
                    id: lpSearch
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: "#ffffff"
                    clip: true
                    selectByMouse: true
                    verticalAlignment: TextInput.AlignVCenter

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Cari Aplikasi..."
                        color: "#90a0b0"
                        font.pixelSize: 13
                        visible: !lpSearch.text && !lpSearch.activeFocus
                    }

                    onTextChanged: {
                        appModelInstance.filter(text);
                    }

                    Keys.onEscapePressed: lpRoot.close()

                    Keys.onReturnPressed: {
                        if (appModelInstance.count > 0) {
                            appModelInstance.launch(0);
                            lpRoot.close();
                        }
                    }
                }
            }
        }

        // Apps Grid
        GridView {
            id: lpGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 120
            cellHeight: 120
            clip: true
            model: appModelInstance

            ScrollBar.vertical: ScrollBar { active: true }

            delegate: Item {
                width: lpGrid.cellWidth
                height: lpGrid.cellHeight

                Rectangle {
                    anchors.centerIn: parent
                    width: 104
                    height: 104
                    radius: 16
                    color: itemMouse.containsMouse ? "#20ffffff" : "transparent"
                    scale: itemMouse.pressed ? 0.92 : (itemMouse.containsMouse ? 1.08 : 1.0)

                    Behavior on scale { NumberAnimation { duration: 120 } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            width: 54
                            height: 54
                            source: model.icon.startsWith("file://") ? model.icon : ("image://theme/" + model.icon)
                            sourceSize.width: 64
                            sourceSize.height: 64
                            fillMode: Image.PreserveAspectFit

                            Text {
                                anchors.centerIn: parent
                                text: "📦"
                                font.pixelSize: 38
                                visible: parent.status === Image.Error || parent.status === Image.Null
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 96
                            text: model.name
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            appModelInstance.launch(index);
                            lpRoot.close();
                        }
                    }
                }
            }
        }
    }
}
