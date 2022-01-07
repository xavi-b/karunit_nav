#ifndef NAVPLUGIN_H
#define NAVPLUGIN_H

#include <QtPlugin>
#include <QIcon>
#include <QDebug>
#include <QDateTime>
#include <QFontDatabase>
#include <QQmlEngine>
#include <QFile>
#include <QJsonDocument>
#include "plugininterface.h"
#include "settings.h"

class KU_Nav_PluginConnector : public KU::PLUGIN::PluginConnector
{
    Q_OBJECT

    Q_PROPERTY(QString mapboxAccessToken MEMBER mapboxAccessToken CONSTANT)

public:
    KU_Nav_PluginConnector(QObject* parent = nullptr);
    Q_INVOKABLE void call(QString number);
    Q_INVOKABLE void tell(QString const& instruction, QString const& distance);

private:
    QString mapboxAccessToken;
};

class KU_Nav_Plugin : public QObject, public KU::PLUGIN::PluginInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "xavi-b.karunit.PluginInterface")
    Q_INTERFACES(KU::PLUGIN::PluginInterface)

public:
    virtual QString                   name() const override;
    virtual QString                   id() const override;
    virtual KU::PLUGIN::PluginVersion version() const override;
    virtual QString                   license() const override;
    virtual QString                   icon() const override;
    virtual bool                      initialize() override;
    virtual bool                      stop() override;

    virtual bool loadSettings() override;
    virtual bool saveSettings() override;

    virtual KU_Nav_PluginConnector* getPluginConnector() override;
};

#endif // NAVPLUGIN_H
