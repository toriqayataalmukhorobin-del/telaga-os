import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Telaga.Desktop 1.0
import "components"

ApplicationWindow {
    id: rootWindow
    visible: true
    width: 1280
    height: 760
    minimumWidth: 960
    minimumHeight: 640
    visibility: (typeof startFullscreen !== "undefined" && startFullscreen) ? Window.FullScreen : Window.AutomaticVisibility
    title: "Telaga OS - The Ultimate macOS PC Experience"
    color: "#081018"

    SystemInfo {
        id: sysInfo
    }

    // Dynamic Lake Wallpaper with Sonoma/Sequoia aura
    Rectangle {
        id: wallpaper
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#061524" }
            GradientStop { position: 0.35; color: "#0b2c48" }
            GradientStop { position: 0.65; color: "#074e68" }
            GradientStop { position: 0.85; color: "#037971" }
            GradientStop { position: 1.0; color: "#021c1e" }
        }

        // Ambient sunset aura reflection
        Rectangle {
            x: parent.width * 0.55
            y: parent.height * 0.15
            width: 500
            height: 350
            radius: 175
            color: "#18e05780"
        }

        // Vibrant cyan lake ripple
        Rectangle {
            x: parent.width * 0.15
            y: parent.height * 0.45
            width: 600
            height: 400
            radius: 200
            color: "#2000b4d8"
        }

        Text {
            anchors.centerIn: parent
            text: "TELAGA OS"
            font.pixelSize: 64
            font.letterSpacing: 20
            font.bold: true
            color: "#0cffffff"
        }

        // Dismiss open popups when clicking wallpaper
        MouseArea {
            anchors.fill: parent
            onClicked: {
                telagaMenuPopup.close();
                controlCenterPopup.close();
                spotlightPopup.close();
                widgetCenter.isOpen = false;
            }
        }
    }

    // INTERACTIVE MACOS FINDER WINDOW (With Genie Minimize/Restore)
    MacFinderWindow {
        id: finderWindow
        x: (parent.width - width) / 2
        y: 80
        visible: true
        z: 10

        onCloseRequested: {
            finderWindow.visible = false;
        }
    }

    // TOP MENU BAR (macOS Style)
    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 80

        onToggleTelagaMenu: {
            if (telagaMenuPopup.opened) telagaMenuPopup.close();
            else telagaMenuPopup.open();
        }

        onToggleSpotlight: {
            if (spotlightPopup.opened) {
                spotlightPopup.close();
            } else {
                spotlightPopup.open();
                spotlightItem.openAndFocus();
            }
        }

        onToggleControlCenter: {
            if (controlCenterPopup.opened) controlCenterPopup.close();
            else controlCenterPopup.open();
        }

        onToggleMissionControl: {
            missionControl.toggle();
        }

        onToggleWidgets: {
            widgetCenter.toggle();
        }

        onOpenFinderRequested: {
            if (finderWindow.isMinimized) finderWindow.genieRestore();
            else finderWindow.visible = true;
        }

        onOpenTerminalRequested: {
            spotlightItem.appModel.launchCommand("terminal");
        }

        onToggleFullscreenRequested: {
            rootWindow.visibility = (rootWindow.visibility === Window.FullScreen) ? Window.Windowed : Window.FullScreen;
        }

        onOpenShortcutsRequested: {
            shortcutsDialog.open();
        }

        onOpenAboutRequested: {
            aboutDialog.open();
        }
    }

    // TELAGA MENU POPUP (Apple Menu Equivalent)
    Popup {
        id: telagaMenuPopup
        x: 8
        y: topBar.height + 4
        padding: 0
        background: null
        z: 100
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        TelagaMenu {
            id: telagaMenu
            onCloseRequested: telagaMenuPopup.close()
            onOpenAboutRequested: aboutDialog.open()
        }
    }

    // CONTROL CENTER POPUP (macOS Style)
    Popup {
        id: controlCenterPopup
        x: rootWindow.width - 332
        y: topBar.height + 6
        padding: 0
        background: null
        z: 100
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
            NumberAnimation { property: "y"; from: topBar.height - 4; to: topBar.height + 6; duration: 150; easing.type: Easing.OutCubic }
        }

        ControlCenter {
            id: controlCenter
            onCloseRequested: controlCenterPopup.close()
            onVolumeChanged: function(val) { macHud.showVolume(val) }
            onBrightnessChanged: function(val) { macHud.showBrightness(val) }
        }
    }

    // SPOTLIGHT SEARCH MODAL (macOS Style)
    Popup {
        id: spotlightPopup
        x: (rootWindow.width - 640) / 2
        y: 140
        padding: 0
        background: null
        modal: true
        focus: true
        z: 110
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 160 }
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
        }

        Spotlight {
            id: spotlightItem
            onAppLaunched: spotlightPopup.close()
            onCloseRequested: spotlightPopup.close()
        }
    }

    // LAUNCHPAD OVERLAY (macOS Style Full-Screen App Grid)
    Launchpad {
        id: launchpadOverlay
        z: 120
    }

    // WIDGETS CENTER PANEL (Slides in from Right Edge)
    WidgetCenter {
        id: widgetCenter
        z: 125
    }

    // MISSION CONTROL OVERLAY (Exposé)
    MissionControl {
        id: missionControl
        z: 140
        onSelectWindow: function(winId) {
            if (winId === "finder") {
                if (finderWindow.isMinimized) finderWindow.genieRestore();
                else finderWindow.visible = true;
            } else if (winId === "terminal") {
                spotlightItem.appModel.launchCommand("terminal");
            }
        }
    }

    // MACOS FLOATING HUD (Volume & Brightness Display)
    MacHud {
        id: macHud
        z: 160
    }

    // BOTTOM DOCK (macOS Parabolic Wave Dock)
    MacDock {
        id: macDock
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 14
        z: 50

        onOpenFinder: {
            if (finderWindow.isMinimized) {
                finderWindow.genieRestore();
            } else if (!finderWindow.visible) {
                finderWindow.visible = true;
            } else {
                finderWindow.genieMinimize();
            }
        }

        onOpenLaunchpad: {
            launchpadOverlay.open();
        }

        onLaunchApp: function(cmd) {
            console.log("[Telaga Dock] Launching:", cmd);
            spotlightItem.appModel.launchCommand(cmd);
        }
    }

    // ABOUT TELAGA OS DIALOG
    Dialog {
        id: aboutDialog
        anchors.centerIn: parent
        width: 380
        height: 290
        title: ""
        modal: true
        standardButtons: Dialog.Ok

        background: Rectangle {
            radius: 16
            color: "#e6141e2a"
            border.color: "#40ffffff"
            border.width: 1.2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 64
                height: 64
                radius: 18
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00b4d8" }
                    GradientStop { position: 1.0; color: "#0077b6" }
                }
                Text {
                    anchors.centerIn: parent
                    text: "🌊"
                    font.pixelSize: 34
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Telaga OS"
                font.pixelSize: 22
                font.bold: true
                color: "#ffffff"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Versi 1.0 (The Ultimate Mac Experience)"
                font.pixelSize: 13
                color: "#90e0ef"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Debian 12 (Bookworm) • Native C++ & Qt6"
                font.pixelSize: 12
                color: "#c0d0e0"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#20ffffff"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Memori: " + sysInfo.ramText
                font.pixelSize: 12
                color: "#a0b0c0"
            }
        }
    }

    // SHORTCUTS REFERENCE DIALOG
    Dialog {
        id: shortcutsDialog
        anchors.centerIn: parent
        width: 440
        height: 380
        title: ""
        modal: true
        standardButtons: Dialog.Ok

        background: Rectangle {
            radius: 16
            color: "#e6141e2a"
            border.color: "#40ffffff"
            border.width: 1.2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "⌨️ Pintasan Keyboard Telaga OS"
                font.pixelSize: 17
                font.bold: true
                color: "#ffffff"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#20ffffff"
            }

            GridLayout {
                columns: 2
                columnSpacing: 20
                rowSpacing: 10
                Layout.fillWidth: true

                Text { text: "Ctrl + Space"; color: "#00f5d4"; font.bold: true; font.pixelSize: 13 }
                Text { text: "Pencarian Spotlight"; color: "#ffffff"; font.pixelSize: 13 }

                Text { text: "F3"; color: "#00f5d4"; font.bold: true; font.pixelSize: 13 }
                Text { text: "Mission Control (Exposé)"; color: "#ffffff"; font.pixelSize: 13 }

                Text { text: "Ctrl + Cmd + Q"; color: "#00f5d4"; font.bold: true; font.pixelSize: 13 }
                Text { text: "Kunci Layar (Lock Session)"; color: "#ffffff"; font.pixelSize: 13 }

                Text { text: "Tombol Kuning (–)"; color: "#00f5d4"; font.bold: true; font.pixelSize: 13 }
                Text { text: "Genie Minimize ke Dock"; color: "#ffffff"; font.pixelSize: 13 }

                Text { text: "Klik Logo Telaga (🌊)"; color: "#00f5d4"; font.bold: true; font.pixelSize: 13 }
                Text { text: "Menu Sistem Utama"; color: "#ffffff"; font.pixelSize: 13 }

                Text { text: "Klik Tanggal/Jam"; color: "#00f5d4"; font.bold: true; font.pixelSize: 13 }
                Text { text: "Bilah Widget & Catatan"; color: "#ffffff"; font.pixelSize: 13 }

                Text { text: "Klik Ikon 🎛️"; color: "#00f5d4"; font.bold: true; font.pixelSize: 13 }
                Text { text: "Pusat Kontrol (Volume, Layar, WiFi)"; color: "#ffffff"; font.pixelSize: 13 }
            }
        }
    }

    // Global Shortcuts
    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: {
            if (spotlightPopup.opened) spotlightPopup.close();
            else {
                spotlightPopup.open();
                spotlightItem.openAndFocus();
            }
        }
    }

    Shortcut {
        sequence: "F3"
        onActivated: missionControl.toggle()
    }

    Shortcut {
        sequence: "F11"
        onActivated: {
            rootWindow.visibility = (rootWindow.visibility === Window.FullScreen) ? Window.Windowed : Window.FullScreen;
        }
    }
}
