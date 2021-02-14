#include "plugin.h"

QString KU_Nav_Plugin::name() const
{
    return "Nav";
}

QString KU_Nav_Plugin::id() const
{
    return "nav.gps";
}

KU::PLUGIN::PluginVersion KU_Nav_Plugin::version() const
{
    return { 1, 0, 0 };
}

QString KU_Nav_Plugin::license() const
{
    return "LGPL";
}

QIcon KU_Nav_Plugin::icon() const
{
    return QIcon();
}

bool KU_Nav_Plugin::initialize()
{
    QIcon::setFallbackSearchPaths(QIcon::fallbackSearchPaths() << ":/karunit_nav/icons/FontAwesome");
    return true;
}

bool KU_Nav_Plugin::stop()
{
    return true;
}

QWidget* KU_Nav_Plugin::createWidget()
{
    this->widget = new GeoWidget;
    connect(this->widget, &GeoWidget::log, this->getPluginConnector(), &KU::PLUGIN::PluginConnector::log);
    connect(this->widget, &GeoWidget::call, this, [&](QString number)
    {
        QVariantMap data;
        data["number"] = number;
        this->getPluginConnector()->emitPluginChoiceSignal("dial", data);
    });
    connect(this->widget, &GeoWidget::tell, this, [&](QString const& instruction, QString const& distance)
    {
        QVariantMap data;
        data["text"] = instruction + " " + distance;
        this->getPluginConnector()->emitPluginChoiceSignal("tell", data);
    });
    this->widget->loadPlaces();
    return this->widget;
}

QWidget* KU_Nav_Plugin::createSettingsWidget()
{
    return nullptr;
}

QWidget* KU_Nav_Plugin::createAboutWidget()
{
    return nullptr;
}

bool KU_Nav_Plugin::loadSettings()
{
    return true;
}

bool KU_Nav_Plugin::saveSettings() const
{
    this->widget->savePlaces();
    return KU::Settings::instance()->status() == QSettings::NoError;
}
