import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0

Rectangle {
    id: dockRoot
    height: 68
    width: dockContent.width + 36
    radius: 20
    color: "#b0121d28" // Frosted glass dark
    border.color: "#40ffffff"
    border.width: 1.2

    signal openLaunchpad()
    signal launchApp(string cmd)
    signal openFinder()

    property real mouseXPos: -9999
    property bool isMouseInside: false
    property string activeTooltip: ""
    property real tooltipX: 0

    // Soft outer shadow & reflection
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: "#18ffffff"
        border.width: 2
        z: -1
    }

    // Floating Tooltip above active icon
    Rectangle {
        id: tooltipPill
        visible: dockRoot.isMouseInside && dockRoot.activeTooltip.length > 0
        x: dockRoot.tooltipX - width / 2
        y: -36
        height: 24
        width: tooltipText.implicitWidth + 18
        radius: 6
        color: "#e61a222e"
        border.color: "#30ffffff"
        border.width: 1
        z: 100

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: dockRoot.activeTooltip
            color: "#ffffff"
            font.pixelSize: 11
            font.weight: Font.Medium
        }
    }

    // Row containing apps and trash
    Row {
        id: dockContent
        anchors.centerIn: parent
        spacing: 12

        // Pinned Core macOS Apps
        Repeater {
            id: appRepeater
            model: [
                { name: "Finder", type: "finder", cmd: "finder", isRunning: true },
                { name: "Launchpad", type: "launchpad", cmd: "launchpad", isRunning: false },
                { name: "Safari", type: "safari", cmd: "x-www-browser", isRunning: true },
                { name: "Terminal", type: "terminal", cmd: "x-terminal-emulator", isRunning: true },
                { name: "Pasang Telaga OS", type: "installer", cmd: "telaga-installer", isRunning: false },
                { name: "Pengaturan Sistem", type: "settings", cmd: "settings", isRunning: false }
            ]

            Item {
                id: iconContainer
                width: 54
                height: 54

                property real iconCenterX: dockContent.x + x + width / 2
                property real dist: Math.abs(dockRoot.mouseXPos - iconCenterX)

                // Parabolic continuous wave scale calculation
                property real dynamicScale: {
                    if (!dockRoot.isMouseInside || dist > 130) return 1.0;
                    return 1.0 + 0.52 * Math.cos((Math.PI * dist) / 260);
                }

                property real dynamicYOffset: (dynamicScale - 1.0) * -34

                function bounce() {
                    iconGraphic.triggerBounce();
                }

                MacIcon {
                    id: iconGraphic
                    anchors.centerIn: parent
                    appType: modelData.type
                    scale: iconContainer.dynamicScale
                    y: iconContainer.dynamicYOffset

                    Behavior on scale {
                        enabled: !dockRoot.isMouseInside
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                    Behavior on y {
                        enabled: !dockRoot.isMouseInside
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }

                    // Iconic macOS App Bouncing Animation on click
                    SequentialAnimation {
                        id: bounceAnim
                        loops: 2
                        NumberAnimation { target: iconGraphic; property: "y"; to: -24; duration: 140; easing.type: Easing.OutQuad }
                        NumberAnimation { target: iconGraphic; property: "y"; to: 0; duration: 140; easing.type: Easing.InQuad }
                    }

                    function triggerBounce() {
                        bounceAnim.restart();
                    }
                }

                // Running App Dot Indicator (macOS style)
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -4
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4
                    height: 4
                    radius: 2
                    color: modelData.isRunning ? "#00f5d4" : "transparent"
                }

                Component.onCompleted: {
                    if (modelData.type === "finder") {
                        dockRoot.openFinder.connect(iconGraphic.triggerBounce);
                    }
                }
            }
        }

        // Dock Separator
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 40
            color: "#30ffffff"
        }

        // Trash Basket
        Item {
            id: trashContainer
            width: 54
            height: 54

            property real iconCenterX: dockContent.x + x + width / 2
            property real dist: Math.abs(dockRoot.mouseXPos - iconCenterX)

            property real dynamicScale: {
                if (!dockRoot.isMouseInside || dist > 130) return 1.0;
                return 1.0 + 0.52 * Math.cos((Math.PI * dist) / 260);
            }

            property real dynamicYOffset: (dynamicScale - 1.0) * -34

            MacIcon {
                id: trashGraphic
                anchors.centerIn: parent
                appType: "trash"
                scale: trashContainer.dynamicScale
                y: trashContainer.dynamicYOffset

                Behavior on scale {
                    enabled: !dockRoot.isMouseInside
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
                Behavior on y {
                    enabled: !dockRoot.isMouseInside
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
            }
        }
    }

    // Unified Mouse Tracker across whole Dock
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPositionChanged: (mouse) => {
            dockRoot.isMouseInside = true;
            dockRoot.mouseXPos = mouse.x;

            // Determine which icon is closest for tooltip
            let closestIndex = -1;
            let minDist = 9999;
            for (let i = 0; i < appRepeater.count; ++i) {
                let item = appRepeater.itemAt(i);
                if (item) {
                    let d = Math.abs(mouse.x - item.iconCenterX);
                    if (d < minDist && d < 36) {
                        minDist = d;
                        closestIndex = i;
                    }
                }
            }

            if (closestIndex >= 0) {
                let model = appRepeater.model[closestIndex];
                dockRoot.activeTooltip = model.name;
                dockRoot.tooltipX = appRepeater.itemAt(closestIndex).iconCenterX;
            } else if (Math.abs(mouse.x - trashContainer.iconCenterX) < 36) {
                dockRoot.activeTooltip = "Keranjang Sampah";
                dockRoot.tooltipX = trashContainer.iconCenterX;
            } else {
                dockRoot.activeTooltip = "";
            }
        }

        onExited: {
            dockRoot.isMouseInside = false;
            dockRoot.mouseXPos = -9999;
            dockRoot.activeTooltip = "";
        }

        onClicked: (mouse) => {
            // Find clicked item
            for (let i = 0; i < appRepeater.count; ++i) {
                let item = appRepeater.itemAt(i);
                if (item && Math.abs(mouse.x - item.iconCenterX) < 28) {
                    item.bounce();
                    let model = appRepeater.model[i];
                    if (model.type === "finder") {
                        dockRoot.openFinder();
                    } else if (model.type === "launchpad") {
                        dockRoot.openLaunchpad();
                    } else {
                        dockRoot.launchApp(model.cmd);
                    }
                    return;
                }
            }
            if (Math.abs(mouse.x - trashContainer.iconCenterX) < 28) {
                dockRoot.launchApp("trash");
            }
        }
    }
}
