#ifndef THEMEICONPROVIDER_H
#define THEMEICONPROVIDER_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QPixmap>
#include <QFile>
#include <QDir>
#include <QFileInfo>

class ThemeIconProvider : public QQuickImageProvider
{
public:
    ThemeIconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override
    {
        QSize actualSize = (requestedSize.isValid() && requestedSize.width() > 0) ? requestedSize : QSize(64, 64);
        if (size) *size = actualSize;

        // 1. Standard QIcon theme lookup
        if (QIcon::hasThemeIcon(id)) {
            QIcon icon = QIcon::fromTheme(id);
            if (!icon.isNull()) {
                QPixmap px = icon.pixmap(actualSize);
                if (!px.isNull()) return px;
            }
        }

        // 2. Direct absolute path if provided
        if (id.startsWith("/")) {
            if (QFile::exists(id)) {
                QPixmap pix(id);
                if (!pix.isNull()) return pix.scaled(actualSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
            }
        }

        // 3. Common pixmaps fallback locations
        const QStringList searchDirs = {
            "/usr/share/pixmaps",
            "/usr/share/icons/Papirus/48x48/apps",
            "/usr/share/icons/Papirus/64x64/apps",
            "/usr/share/icons/Papirus-Dark/48x48/apps",
            "/usr/share/icons/hicolor/48x48/apps",
            "/usr/share/icons/hicolor/64x64/apps",
            "/usr/share/icons/hicolor/scalable/apps",
            "/usr/share/icons/breeze/apps/48"
        };
        const QStringList extensions = { "", ".png", ".svg", ".xpm" };

        for (const QString &dir : searchDirs) {
            for (const QString &ext : extensions) {
                QString fullPath = dir + "/" + id + ext;
                if (QFile::exists(fullPath)) {
                    QPixmap pix(fullPath);
                    if (!pix.isNull()) {
                        return pix.scaled(actualSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
                    }
                }
            }
        }

        // 4. Fallback symbolic variation
        if (!id.endsWith("-symbolic")) {
            QString symbolicId = id + "-symbolic";
            if (QIcon::hasThemeIcon(symbolicId)) {
                QIcon icon = QIcon::fromTheme(symbolicId);
                if (!icon.isNull()) {
                    QPixmap px = icon.pixmap(actualSize);
                    if (!px.isNull()) return px;
                }
            }
        }

        // 5. Return null pixmap so Qt Quick sets Image.status = Image.Error
        return QPixmap();
    }
};

#endif // THEMEICONPROVIDER_H
