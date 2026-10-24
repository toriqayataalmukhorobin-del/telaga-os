#ifndef APPMODEL_H
#define APPMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QList>

struct AppItem {
    QString name;
    QString comment;
    QString exec;
    QString icon;
    QString category;
    bool terminal = false;
};

class AppModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum AppRoles {
        NameRole = Qt::UserRole + 1,
        CommentRole,
        ExecRole,
        IconRole,
        CategoryRole,
        TerminalRole
    };

    explicit AppModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_filteredApps.size(); }

    Q_INVOKABLE void filter(const QString &query, const QString &category = "All");
    Q_INVOKABLE void launch(int index);
    Q_INVOKABLE void reload();

signals:
    void countChanged();

private:
    void scanApplications();
    QString resolveIcon(const QString &iconName) const;

    QList<AppItem> m_allApps;
    QList<AppItem> m_filteredApps;
    QString m_currentQuery;
    QString m_currentCategory;
};

#endif // APPMODEL_H
