import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: wcRoot
    width: 320
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.topMargin: 36
    anchors.bottomMargin: 14
    anchors.right: parent.right
    anchors.rightMargin: isOpen ? 12 : -340
    radius: 20
    color: "#e6121b27" // Frosted glass dark
    border.color: "#30ffffff"
    border.width: 1.2
    z: 130

    property bool isOpen: false

    Behavior on anchors.rightMargin {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    signal closeRequested()

    function toggle() {
        isOpen = !isOpen;
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 14
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width
            spacing: 14

            // HEADER
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Widget Telaga"
                    color: "#ffffff"
                    font.pixelSize: 15
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"
                    color: "#80ffffff"
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wcRoot.isOpen = false
                    }
                }
            }

            // 1. WEATHER WIDGET (macOS Cupertino / Jakarta Weather Card)
            Rectangle {
                Layout.fillWidth: true
                height: 110
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0077b6" }
                    GradientStop { position: 1.0; color: "#0096c7" }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Jakarta • Telaga"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: "☀️"; font.pixelSize: 22 }
                    }

                    Text {
                        text: "28°"
                        color: "#ffffff"
                        font.pixelSize: 32
                        font.bold: true
                    }

                    RowLayout {
                        Text { text: "Cerah Berawan"; color: "#e0f2fe"; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: "Maks: 32° • Min: 24°"; color: "#bae6fd"; font.pixelSize: 11 }
                    }
                }
            }

            // 2. CALENDAR MINI WIDGET
            Rectangle {
                Layout.fillWidth: true
                height: 140
                radius: 16
                color: "#1e2938"
                border.color: "#25ffffff"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: Qt.formatDateTime(new Date(), "MMMM yyyy")
                            color: "#ff5f56"
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Text { text: "🗓️"; font.pixelSize: 13 }
                    }

                    // Days of week
                    Row {
                        Layout.fillWidth: true
                        spacing: 22
                        Repeater {
                            model: ["M", "S", "S", "R", "K", "J", "S"]
                            Text { text: modelData; color: "#708090"; font.pixelSize: 11 }
                        }
                    }

                    // Dates Grid Sample
                    Row {
                        Layout.fillWidth: true
                        spacing: 16
                        Repeater {
                            model: [21, 22, 23, 24, 25, 26, 27]
                            Rectangle {
                                width: 22; height: 22; radius: 11
                                color: modelData === 24 ? "#ff5f56" : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: modelData === 24 ? "#ffffff" : "#c0d0e0"
                                    font.pixelSize: 11
                                    font.bold: modelData === 24
                                }
                            }
                        }
                    }
                }
            }

            // 3. QUICK NOTES WIDGET
            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 16
                color: "#fffa65"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: "📝 Catatan Cepat"
                        color: "#6b5e00"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Telaga OS: Rasakan kemewahan macOS di laptop/PC apa pun."
                        color: "#2d2800"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
