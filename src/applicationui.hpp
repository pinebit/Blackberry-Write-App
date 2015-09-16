#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <QVariant>
#include <QSettings>

namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}

class QTranslator;

class ApplicationUI : public QObject
{
    Q_OBJECT

public:
    ApplicationUI();
    virtual ~ApplicationUI() {}

    Q_INVOKABLE QVariant getSetting(const QString& key, const QVariant& defaultValue);
    Q_INVOKABLE void setSetting(const QString& key, const QVariant& value);
    Q_INVOKABLE void copyText(const QString& text);

private slots:
    void onSystemLanguageChanged();

private:
    QSettings* m_settings;
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
};

#endif
