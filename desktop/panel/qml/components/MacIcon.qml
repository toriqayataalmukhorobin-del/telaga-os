import QtQuick
import QtQuick.Layouts

Item {
    id: macIconRoot
    width: 54
    height: 54

    property string appType: "finder" // finder, launchpad, safari, terminal, settings, trash

    // Drop shadow under squircle
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 3
        width: 50
        height: 50
        radius: 12
        color: "#40000000"
    }

    // Squircle Container (macOS Superellipse styling)
    Rectangle {
        id: squircle
        anchors.centerIn: parent
        width: 50
        height: 50
        radius: 12
        clip: true

        // 1. FINDER (Classic macOS Smiling Two-Tone Face)
        Item {
            anchors.fill: parent
            visible: macIconRoot.appType === "finder"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#48cae4" }
                    GradientStop { position: 1.0; color: "#0077b6" }
                }
            }

            // Left lighter half
            Rectangle {
                width: parent.width / 2
                height: parent.height
                color: "#20ffffff"
            }

            // Eye left
            Rectangle {
                x: 14; y: 16
                width: 5; height: 7
                radius: 3
                color: "#032845"
            }

            // Eye right
            Rectangle {
                x: 31; y: 16
                width: 5; height: 7
                radius: 3
                color: "#032845"
            }

            // Smile curve (Canvas or neat circle)
            Rectangle {
                x: 16; y: 24
                width: 18; height: 14
                radius: 9
                color: "transparent"
                border.color: "#032845"
                border.width: 3
                clip: true
                Rectangle {
                    width: 24; height: 10
                    color: "#0077b6"
                }
            }
        }

        // 2. LAUNCHPAD (macOS Space Gray with Cosmic Rocket)
        Item {
            anchors.fill: parent
            visible: macIconRoot.appType === "launchpad"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#3a4a5e" }
                    GradientStop { position: 1.0; color: "#1c2530" }
                }
            }

            // Star speckles
            Rectangle { x: 10; y: 12; width: 2; height: 2; radius: 1; color: "#ffffff" }
            Rectangle { x: 38; y: 15; width: 2; height: 2; radius: 1; color: "#90e0ef" }
            Rectangle { x: 34; y: 36; width: 2; height: 2; radius: 1; color: "#ffffff" }
            Rectangle { x: 12; y: 34; width: 3; height: 3; radius: 1.5; color: "#ffd166" }

            Text {
                anchors.centerIn: parent
                text: "🚀"
                font.pixelSize: 26
            }
        }

        // 3. SAFARI / BROWSER (Ocean Compass)
        Item {
            anchors.fill: parent
            visible: macIconRoot.appType === "safari"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00b4d8" }
                    GradientStop { position: 0.5; color: "#0077b6" }
                    GradientStop { position: 1.0; color: "#03045e" }
                }
            }

            // Dial ring
            Rectangle {
                anchors.centerIn: parent
                width: 36; height: 36
                radius: 18
                color: "transparent"
                border.color: "#80ffffff"
                border.width: 1.5
            }

            // Compass needle
            Rectangle {
                anchors.centerIn: parent
                width: 22; height: 4
                radius: 2
                rotation: -45
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#ef476f" }
                    GradientStop { position: 0.5; color: "#ffffff" }
                    GradientStop { position: 1.0; color: "#06d6a0" }
                }
            }
        }

        // 4. TERMINAL (macOS Dark Obsidian Box)
        Item {
            anchors.fill: parent
            visible: macIconRoot.appType === "terminal"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2d3748" }
                    GradientStop { position: 1.0; color: "#1a202c" }
                }
            }

            // Window top bar
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 10
                color: "#15ffffff"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    spacing: 3
                    Rectangle { width: 3; height: 3; radius: 1.5; color: "#ff5f56" }
                    Rectangle { width: 3; height: 3; radius: 1.5; color: "#ffbd2e" }
                    Rectangle { width: 3; height: 3; radius: 1.5; color: "#27c93f" }
                }
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 3
                text: ">_"
                font.bold: true
                font.pixelSize: 20
                color: "#00f5d4"
            }
        }

        // 5. SYSTEM SETTINGS (macOS Titanium Gears)
        Item {
            anchors.fill: parent
            visible: macIconRoot.appType === "settings"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#6c757d" }
                    GradientStop { position: 1.0; color: "#495057" }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "⚙️"
                font.pixelSize: 30
            }
        }

        // 6. TRASH (macOS Frosted Mesh Basket)
        Item {
            anchors.fill: parent
            visible: macIconRoot.appType === "trash"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4a5568" }
                    GradientStop { position: 1.0; color: "#2d3748" }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "🗑️"
                font.pixelSize: 28
            }
        }

        // 7. INSTALLER / WELCOME (macOS Disk Drive / Package Installer)
        Item {
            anchors.fill: parent
            visible: macIconRoot.appType === "installer" || macIconRoot.appType === "welcome"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f77f00" }
                    GradientStop { position: 1.0; color: "#d62828" }
                }
            }

            Text {
                anchors.centerIn: parent
                text: macIconRoot.appType === "installer" ? "💾" : "👋"
                font.pixelSize: 26
            }
        }

        // Glass sheen overlay on top
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#35ffffff" }
                GradientStop { position: 0.4; color: "#08ffffff" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }
}
