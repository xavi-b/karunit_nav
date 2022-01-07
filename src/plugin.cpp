#include "plugin.h"

KU_Nav_PluginConnector::KU_Nav_PluginConnector(QObject* parent)
    : KU::PLUGIN::PluginConnector(parent)
{
    QFile file(":/karunit_nav/res/mapbox.json");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        const auto json         = QJsonDocument::fromJson(file.readAll()).object();
        this->mapboxAccessToken = json["access_token"].toString();
    }
}

void KU_Nav_PluginConnector::call(QString number)
{
    QVariantMap data;
    data["number"] = number;
    this->emitPluginChoiceSignal("dial", data);
}

void KU_Nav_PluginConnector::tell(QString const& instruction, QString const& distance)
{
    QVariantMap data;
    data["text"] = instruction + " " + distance;
    this->emitPluginChoiceSignal("tell", data);
}

QString KU_Nav_Plugin::name() const
{
    return "Nav";
}

QString KU_Nav_Plugin::id() const
{
    return "karunit_nav";
}

KU::PLUGIN::PluginVersion KU_Nav_Plugin::version() const
{
    return {1, 0, 0};
}

QString KU_Nav_Plugin::license() const
{
    return "LGPL";
}

QString KU_Nav_Plugin::icon() const
{
    return QString();
}

bool KU_Nav_Plugin::initialize()
{
    QIcon::setFallbackSearchPaths(QIcon::fallbackSearchPaths() << ":/karunit_nav/icons/FontAwesome");

    qmlRegisterSingletonInstance("KarunitPlugins", 1, 0, "KUPNavPluginConnector", this->pluginConnector);

    return true;
}

bool KU_Nav_Plugin::stop()
{
    return true;
}

bool KU_Nav_Plugin::loadSettings()
{
    return true;
}

bool KU_Nav_Plugin::saveSettings()
{
    return KU::Settings::instance()->status() == QSettings::NoError;
}

KU_Nav_PluginConnector* KU_Nav_Plugin::getPluginConnector()
{
    if (this->pluginConnector == nullptr)
        this->pluginConnector = new KU_Nav_PluginConnector;
    return qobject_cast<KU_Nav_PluginConnector*>(this->pluginConnector);
}
