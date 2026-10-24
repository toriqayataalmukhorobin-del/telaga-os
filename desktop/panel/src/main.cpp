#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QCommandLineParser>
#include <QDebug>
#include "appmodel.h"
#include "systeminfo.h"
#include "themeiconprovider.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setOrganizationName("TelagaOS");
    QGuiApplication::setOrganizationDomain("telaga-os.org");
    QGuiApplication::setApplicationName("telaga-panel");
    QGuiApplication::setApplicationVersion("1.0.0");

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon::fromTheme("distributor-logo-debian"));

    // Set best available icon theme (Papirus-Dark for Telaga OS, with graceful fallbacks)
    QString currentTheme = QIcon::themeName();
    if (currentTheme.isEmpty() || currentTheme == "hicolor") {
        const QStringList themeCandidates = { "Papirus-Dark", "Papirus", "breeze-dark", "breeze", "Adwaita" };
        for (const QString &theme : themeCandidates) {
            if (QDir("/usr/share/icons/" + theme).exists()) {
                QIcon::setThemeName(theme);
                break;
            }
        }
    }

    // Command Line Options
    QCommandLineParser parser;
    parser.setApplicationDescription("Telaga OS Native Desktop Environment Shell");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption fullscreenOption(QStringList() << "f" << "fullscreen", "Start in fullscreen desktop mode.");
    QCommandLineOption windowedOption(QStringList() << "w" << "windowed", "Force start in windowed preview mode (1280x760).");
    parser.addOption(fullscreenOption);
    parser.addOption(windowedOption);

    parser.process(app);

    bool isFullscreen = parser.isSet(fullscreenOption);
    if (!isFullscreen && !parser.isSet(windowedOption)) {
        // Auto-detect: if run inside telaga-session, default to fullscreen
        if (qEnvironmentVariableIsSet("TELAGA_SESSION") || qEnvironmentVariable("DESKTOP_SESSION") == "telaga") {
            isFullscreen = true;
        }
    }

    QQmlApplicationEngine engine;

    // Register theme icon provider for image://theme/<icon-name>
    engine.addImageProvider(QStringLiteral("theme"), new ThemeIconProvider());

    // Register custom C++ types
    qmlRegisterType<AppModel>("Telaga.Desktop", 1, 0, "AppModel");
    qmlRegisterType<SystemInfo>("Telaga.Desktop", 1, 0, "SystemInfo");

    // Context properties
    engine.rootContext()->setContextProperty("startFullscreen", isFullscreen);

    const QUrl url(QStringLiteral("qrc:/qml/MainPanel.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    qDebug() << "========================================";
    qDebug() << "   Telaga Desktop Environment (TDE)    ";
    qDebug() << "   Mode: " << (isFullscreen ? "Fullscreen Desktop" : "Windowed Preview");
    qDebug() << "   Started successfully!                ";
    qDebug() << "========================================";

    return app.exec();
}
