#ifndef THEMEICONPROVIDER_H
#define THEMEICONPROVIDER_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QPixmap>

class ThemeIconProvider : public QQuickImageProvider
{
public:
    ThemeIconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override
    {
        QSize actualSize = (requestedSize.isValid() && requestedSize.width() > 0) ? requestedSize : QSize(64, 64);
        if (size) *size = actualSize;

        QIcon icon = QIcon::fromTheme(id);
        if (icon.isNull()) {
            // Return empty transparent pixmap
            QPixmap empty(actualSize);
            empty.fill(Qt::transparent);
            return empty;
        }

        return icon.pixmap(actualSize);
    }
};

#endif // THEMEICONPROVIDER_H
