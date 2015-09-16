#ifndef NOTES_HPP
#define NOTES_HPP

#include <QObject>
#include <QMap>
#include <QDir>
#include <QFileInfo>
#include <QSettings>

#include <bb/cascades/GroupDataModel>

class Notes : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bb::cascades::GroupDataModel* model READ model CONSTANT);
    Q_PROPERTY(bool hasNotes READ hasNotes NOTIFY hasNotesChanged);

public:
    Notes(QObject* parent);
    virtual ~Notes() {}

    bb::cascades::GroupDataModel* model() const {
        return m_model;
    }

    bool hasNotes() const
    {
        return m_hasNotes;
    }

    Q_INVOKABLE QString createNote();
    Q_INVOKABLE QString readNote(const QString& noteId);
    Q_INVOKABLE void deleteNote(const QString& noteId);
    Q_INVOKABLE void saveNote(const QString& noteId, const QString& text);
    Q_INVOKABLE QDateTime noteDateTime(const QString& noteId);

    Q_INVOKABLE void setFilter(const QString& filter);

signals:
    void hasNotesChanged(bool);

private:
    void updateModel();
    QDir notesFolder();
    QString getSubject(const QFileInfo& info);
    QString getDisplayDate(const QFileInfo& info);

    bb::cascades::GroupDataModel* m_model;
    bool m_hasNotes;
    QString m_filter;
    QSettings m_settings;
};

#endif
