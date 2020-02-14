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

QSet<KU::PLUGIN::PluginInfo> KU_Nav_Plugin::dependencies() const
{
    return QSet<KU::PLUGIN::PluginInfo>();
}

QString KU_Nav_Plugin::license() const
{
    return "LGPL";
}

QIcon KU_Nav_Plugin::icon() const
{
    return QIcon();
}

bool KU_Nav_Plugin::initialize(const QSet<KU::PLUGIN::PluginInterface*>& plugins)
{
    return true;
}

bool KU_Nav_Plugin::stop()
{
    return true;
}

QWidget* KU_Nav_Plugin::createWidget()
{
    this->widget = new GeoWidget(&this->engine);
    connect(this->widget, &GeoWidget::log, this->getPluginConnector(), &KU::PLUGIN::PluginConnector::log);
    return this->widget;
}

QWidget* KU_Nav_Plugin::createSettingsWidget()
{
    return nullptr;
}

bool KU_Nav_Plugin::loadSettings()
{
    return true;
}

bool KU_Nav_Plugin::saveSettings() const
{
    return KU::Settings::instance()->status() == QSettings::NoError;
}