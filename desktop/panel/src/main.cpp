#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QDebug>
#include "appmodel.h"
#include "systeminfo.h"
#include "themeiconprovider.h"

int main(int argc, char *argv[])
{
    // Enable High DPI scaling
    QGuiApplication::setOrganizationName("TelagaOS");
    QGuiApplication::setApplicationName("telaga-panel");

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon::fromTheme("distributor-logo-debian"));

    QQmlApplicationEngine engine;

    // Register theme icon provider for image://theme/<icon-name>
    engine.addImageProvider(QStringLiteral("theme"), new ThemeIconProvider());

    // Register custom C++ types
    qmlRegisterType<AppModel>("Telaga.Desktop", 1, 0, "AppModel");
    qmlRegisterType<SystemInfo>("Telaga.Desktop", 1, 0, "SystemInfo");

    const QUrl url(QStringLiteral("qrc:/qml/MainPanel.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    qDebug() << "========================================";
    qDebug() << "   Telaga Desktop Environment (TDE)    ";
    qDebug() << "   Started successfully!                ";
    qDebug() << "========================================";

    return app.exec();
}
