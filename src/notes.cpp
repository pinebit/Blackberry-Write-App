#include <QTextStream>

#include "notes.hpp"

using namespace bb::cascades;

static const char* NotesDirName = "notes";

Notes::Notes(QObject* parent) :
        QObject(parent), m_model(new GroupDataModel(this))
{
    m_model->setGrouping(ItemGrouping::None);
    m_model->setSortingKeys(QStringList() << "date");
    m_model->setSortedAscending(false);

    m_filter = QString();
    updateModel();
}

QString Notes::createNote()
{
    return QString::number(QDateTime::currentDateTime().toMSecsSinceEpoch());
}

QString Notes::readNote(const QString& noteId)
{
    QDir dir = notesFolder();
    QString filepath = dir.filePath(noteId);

    QFile file(filepath);
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        qWarning() << "Failed to read note: " << noteId;
        return "";
    }

    QTextStream in(&file);
    return in.readAll();
}

void Notes::deleteNote(const QString& noteId)
{
    QDir dir = notesFolder();
    dir.remove(noteId);

    m_settings.remove(noteId);

    updateModel();
}

void Notes::saveNote(const QString& noteId, const QString& text)
{
    QDir dir = notesFolder();
    QString filepath = dir.filePath(noteId);

    if (text.trimmed().isEmpty()) {
        deleteNote(noteId);
        return;
    }

    QFile file(filepath);
    if (!file.open(QFile::WriteOnly | QFile::Text)) {
        qWarning() << "Failed to write note: " << noteId;
        return;
    }

    QTextStream out(&file);
    out << text;
    file.close();

    QFileInfo info(filepath);
    QString subject = getSubject(info);
    m_settings.setValue(noteId.toAscii(), subject);

    updateModel();
}

QDateTime Notes::noteDateTime(const QString& noteId)
{
    QDir dir = notesFolder();
    QString filepath = dir.filePath(noteId);
    QFileInfo info(filepath);
    if (info.exists()) {
        return info.lastModified();
    }

    bool ok;
    qint64 msecs = noteId.toLongLong(&ok, 10);
    return QDateTime::fromMSecsSinceEpoch(msecs);
}

void Notes::updateModel()
{
    QDir dir = notesFolder();
    QFileInfoList fileList = dir.entryInfoList(QDir::Files);
    QFileInfo file;

    m_model->clear();
    m_hasNotes = false;

    foreach (file, fileList){
        m_hasNotes = true;

        QString filename = file.fileName();
        QString subject = m_settings.value(filename.toAscii()).toString();
        if (!m_filter.isEmpty() && !subject.contains(m_filter, Qt::CaseInsensitive))
        {
            continue;
        }

        QVariantMap map;
        map["noteId"] = filename;
        map["subject"] = subject;
        map["date"] = file.lastModified();
        map["displayDate"] = getDisplayDate(file);

        m_model->insert(map);
    }

    emit hasNotesChanged(m_hasNotes);
}

QDir Notes::notesFolder()
{
    QDir dir = QDir::home();
    if (!dir.cd(NotesDirName)) {
        if (!dir.mkdir(NotesDirName) || !dir.cd(NotesDirName)) {
            qWarning() << "Failed to create notes directory: " << NotesDirName;
        }
    }

    return dir;
}

QString Notes::getSubject(const QFileInfo& info)
{
    QFile file(info.absoluteFilePath());

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open note file: " << info.absoluteFilePath();
        return "";
    }

    QTextStream in(&file);
    QString subject = "";

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (!line.isEmpty()) {
            subject = line;
            break;
        }
    }

    file.close();
    return subject;
}

QString Notes::getDisplayDate(const QFileInfo& info)
{
    QDateTime date = info.lastModified();
    int diff = date.daysTo(QDateTime::currentDateTime());

    if (diff <= 1) {
        return date.toString("h:mm AP");
    }

    if (diff < 7) {
        int dayOfWeek = date.date().dayOfWeek();
        switch (dayOfWeek) {
            case 1:
                return "Monday";
            case 2:
                return "Tuesday";
            case 3:
                return "Wednesday";
            case 4:
                return "Thursday";
            case 5:
                return "Friday";
            case 6:
                return "Saturday";
            case 7:
                return "Sunday";

        }
    }

    return date.toString("MMM d, yyyy");
}

void Notes::setFilter(const QString& filter)
{
    if (m_filter != filter)
    {
        m_filter = filter;
        updateModel();
    }
}
