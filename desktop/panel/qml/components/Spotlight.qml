import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: spotlightRoot
    width: 640
    height: searchInput.text.length > 0 ? Math.min(480, 72 + resultsList.contentHeight) : 64
    radius: 16
    color: "#eb1a2330" // Frosted glass dark
    border.color: "#40ffffff"
    border.width: 1.2
    clip: true

    Behavior on height {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    property alias appModel: appModelInstance
    signal appLaunched()
    signal closeRequested()

    AppModel {
        id: appModelInstance
    }

    function openAndFocus() {
        searchInput.text = "";
        appModelInstance.filter("");
        searchInput.forceActiveFocus();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Search Input Header
        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 14

                Text {
                    text: "🔍"
                    font.pixelSize: 22
                    color: "#a0b2c6"
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    font.pixelSize: 19
                    color: "#ffffff"
                    clip: true
                    selectByMouse: true
                    verticalAlignment: TextInput.AlignVCenter

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Pencarian Spotlight (Spotlight Search)..."
                        color: "#708090"
                        font.pixelSize: 19
                        visible: !searchInput.text && !searchInput.activeFocus
                    }

                    onTextChanged: {
                        appModelInstance.filter(text);
                        resultsList.currentIndex = 0;
                    }

                    Keys.onEscapePressed: {
                        spotlightRoot.closeRequested();
                    }

                    Keys.onDownPressed: {
                        if (resultsList.currentIndex < resultsList.count - 1) {
                            resultsList.currentIndex++;
                        }
                    }

                    Keys.onUpPressed: {
                        if (resultsList.currentIndex > 0) {
                            resultsList.currentIndex--;
                        }
                    }

                    Keys.onReturnPressed: {
                        if (resultsList.count > 0 && resultsList.currentIndex >= 0) {
                            appModelInstance.launch(resultsList.currentIndex);
                            spotlightRoot.appLaunched();
                        }
                    }
                }

                // ESC hint badge
                Rectangle {
                    width: 38
                    height: 22
                    radius: 5
                    color: "#25ffffff"
                    Text {
                        anchors.centerIn: parent
                        text: "esc"
                        color: "#c0d0e0"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }
        }

        // Separator line when results are shown
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#20ffffff"
            visible: searchInput.text.length > 0
        }

        // Search Results List
        ListView {
            id: resultsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: appModelInstance
            visible: searchInput.text.length > 0
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                width: resultsList.width
                height: 52
                color: (resultsList.currentIndex === index || rowMouse.containsMouse) ? "#007aff" : "transparent"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 14

                    Image {
                        width: 32
                        height: 32
                        source: model.icon.startsWith("file://") ? model.icon : ("image://theme/" + model.icon)
                        sourceSize.width: 36
                        sourceSize.height: 36
                        fillMode: Image.PreserveAspectFit

                        Text {
                            anchors.centerIn: parent
                            text: "📦"
                            font.pixelSize: 22
                            visible: parent.status === Image.Error || parent.status === Image.Null
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: model.name
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: model.comment.length > 0 ? model.comment : model.exec
                            color: (resultsList.currentIndex === index || rowMouse.containsMouse) ? "#e0f0ff" : "#90a0b0"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: "Aplikasi"
                        color: (resultsList.currentIndex === index || rowMouse.containsMouse) ? "#d0e4ff" : "#708090"
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        appModelInstance.launch(index);
                        spotlightRoot.appLaunched();
                    }
                }
            }
        }
    }
}
