import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: ccRoot
    width: 320
    height: ccCol.implicitHeight + 28
    radius: 18
    color: "#eb1a2330" // Frosted glass dark
    border.color: "#30ffffff"
    border.width: 1.2

    property alias sysInfo: sysInfoItem
    signal closeRequested()
    signal volumeChanged(real val)
    signal brightnessChanged(real val)

    SystemInfo {
        id: sysInfoItem
    }

    ColumnLayout {
        id: ccCol
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Top Row: Network & Bluetooth dual capsule
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // WiFi Tile
            Rectangle {
                id: wifiTile
                Layout.fillWidth: true
                height: 64
                radius: 14
                property bool wifiEnabled: sysInfoItem.wifiEnabled
                color: wifiEnabled ? "#007aff" : "#283444"

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: wifiTile.wifiEnabled ? "#ffffff" : "#3a4a5e"
                        Text {
                            anchors.centerIn: parent
                            text: "📶"
                            font.pixelSize: 16
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "Wi-Fi"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }
                        Text {
                            text: wifiTile.wifiEnabled ? "Terhubung" : "Mati"
                            color: wifiTile.wifiEnabled ? "#d0e4ff" : "#809bb3"
                            font.pixelSize: 11
                        }
                    }
                }

                MouseArea {
                    id: wifiMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sysInfoItem.setWifiEnabled(!sysInfoItem.wifiEnabled)
                }
            }

            // Bluetooth Tile
            Rectangle {
                id: btTile
                Layout.fillWidth: true
                height: 64
                radius: 14
                property bool btEnabled: sysInfoItem.bluetoothEnabled
                color: btEnabled ? "#007aff" : "#283444"

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: btTile.btEnabled ? "#ffffff" : "#3a4a5e"
                        Text {
                            anchors.centerIn: parent
                            text: "ᛒ"
                            font.pixelSize: 16
                            color: btTile.btEnabled ? "#007aff" : "#ffffff"
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "Bluetooth"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }
                        Text {
                            text: btTile.btEnabled ? "Aktif" : "Mati"
                            color: btTile.btEnabled ? "#d0e4ff" : "#809bb3"
                            font.pixelSize: 11
                        }
                    }
                }

                MouseArea {
                    id: btMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sysInfoItem.setBluetoothEnabled(!sysInfoItem.bluetoothEnabled)
                }
            }
        }

        // Display Brightness Slider Card
        Rectangle {
            Layout.fillWidth: true
            height: 58
            radius: 14
            color: "#222e3e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "☀️"; font.pixelSize: 12 }
                    Text {
                        text: "Kecerahan Layar"
                        color: "#a0b2c6"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(brightSlider.value * 100) + "%"
                        color: "#a0b2c6"
                        font.pixelSize: 11
                    }
                }

                Slider {
                    id: brightSlider
                    Layout.fillWidth: true
                    from: 0.1
                    to: 1.0
                    value: sysInfoItem.brightness / 100.0
                    onMoved: {
                        sysInfoItem.setBrightness(Math.round(value * 100))
                        ccRoot.brightnessChanged(value)
                    }
                }
            }
        }

        // Sound Volume Slider Card
        Rectangle {
            Layout.fillWidth: true
            height: 58
            radius: 14
            color: "#222e3e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "🔊"; font.pixelSize: 12 }
                    Text {
                        text: "Volume Suara"
                        color: "#a0b2c6"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(volSlider.value * 100) + "%"
                        color: "#a0b2c6"
                        font.pixelSize: 11
                    }
                }

                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0
                    value: sysInfoItem.volume / 100.0
                    onMoved: {
                        sysInfoItem.setVolume(Math.round(value * 100))
                        ccRoot.volumeChanged(value)
                    }
                }
            }
        }

        // Memory & Battery Stats Card
        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 14
            color: "#182432"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                Text { text: "🧠"; font.pixelSize: 14 }
                Text {
                    text: "RAM: " + sysInfoItem.ramText
                    color: "#90e0ef"
                    font.pixelSize: 12
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: sysInfoItem.hasBattery ? ((sysInfoItem.isCharging ? "⚡" : "🔋") + " " + sysInfoItem.batteryPercent + "%") : "🖥️ AC Power"
                    color: "#06d6a0"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }
    }
}
