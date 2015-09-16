#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/system/Clipboard>
#include <bb/device/DisplayInfo>

#include "applicationui.hpp"
#include "notes.hpp"

using namespace bb::cascades;
using namespace bb::device;

ApplicationUI::ApplicationUI() :
        QObject(),
        m_settings(new QSettings(this))
{
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);

    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
    Q_ASSERT(res);
    Q_UNUSED(res);

    onSystemLanguageChanged();

    QmlDocument *qml = QmlDocument::create("asset:///Main.qml").parent(this);
    qml->setContextProperty("_app", this);
    qml->setContextProperty("_notes", new Notes(this));

    DisplayInfo display;
    int width = display.pixelSize().width();
    int height = display.pixelSize().height();

    QDeclarativePropertyMap* displayProperties = new QDeclarativePropertyMap;
    displayProperties->insert("width", QVariant(width));
    displayProperties->insert("height", QVariant(height));

    qml->setContextProperty("DisplayInfo", displayProperties);

    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    QString locale_string = QLocale().name();
    QString file_name = QString("Write_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}

QVariant ApplicationUI::getSetting(const QString& key, const QVariant& defaultValue)
{
    m_settings->sync();
    QVariant temp = m_settings->value(key);
    if (temp.isNull())
    {
        return defaultValue;
    }

    return temp;
}

void ApplicationUI::setSetting(const QString& key, const QVariant& value)
{
    m_settings->setValue(key, value);
    m_settings->sync();
}

void ApplicationUI::copyText(const QString& text)
{
    bb::system::Clipboard clipboard;
    clipboard.clear();
    clipboard.insert("text/plain", text.toUtf8());
}
