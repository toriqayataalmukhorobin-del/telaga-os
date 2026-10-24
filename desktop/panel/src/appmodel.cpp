#include "appmodel.h"
#include <QRegularExpression>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <QStandardPaths>
#include <QIcon>
#include <QDebug>
#include <algorithm>

AppModel::AppModel(QObject *parent)
    : QAbstractListModel(parent),
      m_currentCategory("All")
{
    reload();
}

int AppModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_filteredApps.size();
}

QVariant AppModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredApps.size())
        return QVariant();

    const AppItem &item = m_filteredApps.at(index.row());
    switch (role) {
    case NameRole:
        return item.name;
    case CommentRole:
        return item.comment;
    case ExecRole:
        return item.exec;
    case IconRole:
        return item.icon;
    case CategoryRole:
        return item.category;
    case TerminalRole:
        return item.terminal;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AppModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[CommentRole] = "comment";
    roles[ExecRole] = "exec";
    roles[IconRole] = "icon";
    roles[CategoryRole] = "category";
    roles[TerminalRole] = "terminal";
    return roles;
}

void AppModel::reload()
{
    beginResetModel();
    m_allApps.clear();
    scanApplications();

    std::sort(m_allApps.begin(), m_allApps.end(), [](const AppItem &a, const AppItem &b) {
        return a.name.toLower() < b.name.toLower();
    });

    m_filteredApps = m_allApps;
    endResetModel();
    emit countChanged();
}

void AppModel::scanApplications()
{
    QStringList appDirs = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
    if (!appDirs.contains("/usr/share/applications"))
        appDirs.append("/usr/share/applications");
    if (!appDirs.contains("/usr/local/share/applications"))
        appDirs.append("/usr/local/share/applications");
    if (!appDirs.contains("/var/lib/flatpak/exports/share/applications"))
        appDirs.append("/var/lib/flatpak/exports/share/applications");

    QSet<QString> processedFiles;

    for (const QString &dirPath : appDirs) {
        QDir dir(dirPath);
        if (!dir.exists()) continue;

        const QFileInfoList entries = dir.entryInfoList(QStringList() << "*.desktop", QDir::Files);
        for (const QFileInfo &fileInfo : entries) {
            if (processedFiles.contains(fileInfo.fileName()))
                continue;
            processedFiles.insert(fileInfo.fileName());

            QFile file(fileInfo.absoluteFilePath());
            if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
                continue;

            QTextStream in(&file);
            bool inDesktopEntry = false;
            AppItem item;
            bool noDisplay = false;

            while (!in.atEnd()) {
                QString line = in.readLine().trimmed();
                if (line.isEmpty() || line.startsWith("#")) continue;

                if (line.startsWith("[") && line.endsWith("]")) {
                    inDesktopEntry = (line == "[Desktop Entry]");
                    continue;
                }

                if (!inDesktopEntry) continue;

                int eqIdx = line.indexOf('=');
                if (eqIdx == -1) continue;

                QString key = line.left(eqIdx).trimmed();
                QString val = line.mid(eqIdx + 1).trimmed();

                if (key == "Type" && val != "Application") {
                    noDisplay = true;
                    break;
                }
                if ((key == "NoDisplay" || key == "Hidden") && (val.toLower() == "true" || val == "1")) {
                    noDisplay = true;
                    break;
                }
                if (key == "Name" && item.name.isEmpty()) {
                    item.name = val;
                } else if (key == "Comment" && item.comment.isEmpty()) {
                    item.comment = val;
                } else if (key == "Exec" && item.exec.isEmpty()) {
                    // Strip field codes like %f, %F, %u, %U, %d, etc.
                    QString cleanExec = val;
                    cleanExec.remove(QRegularExpression("%[fFuUdDnNickvm%]"));
                    cleanExec = cleanExec.simplified();
                    item.exec = cleanExec;
                } else if (key == "Icon" && item.icon.isEmpty()) {
                    item.icon = val;
                } else if (key == "Categories" && item.category.isEmpty()) {
                    item.category = val;
                } else if (key == "Terminal") {
                    item.terminal = (val.toLower() == "true" || val == "1");
                }
            }

            if (!noDisplay && !item.name.isEmpty() && !item.exec.isEmpty()) {
                item.icon = resolveIcon(item.icon);
                m_allApps.append(item);
            }
        }
    }
}

QString AppModel::resolveIcon(const QString &iconName) const
{
    if (iconName.isEmpty()) {
        return "application-x-executable";
    }

    if (iconName.startsWith("/")) {
        if (QFile::exists(iconName)) {
            return "file://" + iconName;
        }
    }

    if (QIcon::hasThemeIcon(iconName)) {
        return iconName;
    }

    // Try common pixmaps folder
    QString pixmapPath = "/usr/share/pixmaps/" + iconName;
    if (!pixmapPath.endsWith(".png") && !pixmapPath.endsWith(".svg")) {
        if (QFile::exists(pixmapPath + ".png")) return "file://" + pixmapPath + ".png";
        if (QFile::exists(pixmapPath + ".svg")) return "file://" + pixmapPath + ".svg";
    } else if (QFile::exists(pixmapPath)) {
        return "file://" + pixmapPath;
    }

    return iconName;
}

void AppModel::filter(const QString &query, const QString &category)
{
    beginResetModel();
    m_currentQuery = query.trimmed().toLower();
    m_currentCategory = category;

    m_filteredApps.clear();

    for (const AppItem &item : m_allApps) {
        bool matchesQuery = m_currentQuery.isEmpty() ||
                            item.name.toLower().contains(m_currentQuery) ||
                            item.comment.toLower().contains(m_currentQuery) ||
                            item.exec.toLower().contains(m_currentQuery);

        bool matchesCat = (m_currentCategory == "All") ||
                          item.category.contains(m_currentCategory, Qt::CaseInsensitive);

        if (matchesQuery && matchesCat) {
            m_filteredApps.append(item);
        }
    }

    endResetModel();
    emit countChanged();
}

void AppModel::launch(int index)
{
    if (index < 0 || index >= m_filteredApps.size())
        return;

    const AppItem &item = m_filteredApps.at(index);
    qDebug() << "[Telaga Launcher] Launching:" << item.name << "->" << item.exec;

    QString execCommand = item.exec;
    if (item.terminal) {
        execCommand = QString("alacritty -e %1 2>/dev/null || x-terminal-emulator -e %1 2>/dev/null || xterm -e %1").arg(execCommand);
    }

    QProcess::startDetached("/bin/sh", QStringList() << "-c" << execCommand);
}

void AppModel::launchCommand(const QString &command)
{
    if (command.isEmpty()) return;

    qDebug() << "[Telaga AppModel] Launching command:" << command;

    if (command == "settings") {
        QString cmd = "/usr/bin/telaga-welcome --settings 2>/dev/null || xfce4-settings-manager 2>/dev/null || arandr 2>/dev/null || pavucontrol 2>/dev/null || lxappearance 2>/dev/null || openbox --reconfigure";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "telaga-installer" || command == "installer") {
        QString cmd = "pkexec /usr/bin/telaga-installer 2>/dev/null || alacritty -e sudo /usr/bin/telaga-installer 2>/dev/null || /usr/bin/telaga-installer 2>/dev/null";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "telaga-welcome" || command == "welcome") {
        QString cmd = "/usr/bin/telaga-welcome 2>/dev/null || alacritty -e /usr/bin/telaga-welcome 2>/dev/null";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "terminal" || command == "x-terminal-emulator") {
        QString cmd = "alacritty 2>/dev/null || x-terminal-emulator 2>/dev/null || xterm";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "safari" || command == "browser" || command == "x-www-browser") {
        QString cmd = "x-www-browser 2>/dev/null || firefox-esr 2>/dev/null || firefox 2>/dev/null || chromium 2>/dev/null || google-chrome";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "finder") {
        QString cmd = "pcmanfm 2>/dev/null || nautilus 2>/dev/null || thunar 2>/dev/null || xdg-open ~";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    if (command == "trash") {
        QString cmd = "pcmanfm ~/.local/share/Trash/files 2>/dev/null || xdg-open ~/.local/share/Trash 2>/dev/null || xdg-open ~";
        QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
        return;
    }

    // Default: execute via shell
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << command);
}
