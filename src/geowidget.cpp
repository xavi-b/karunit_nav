#include "geowidget.h"

GeoWidget::GeoWidget(QWidget *parent)
    : QQuickWidget(parent)
{
    this->setResizeMode(QQuickWidget::SizeRootObjectToView);
    this->setSource(QUrl("qrc:/karunit_nav/qml/Main.qml"));

    QFile file(":/karunit_nav/res/mapbox.json");
    if(file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        const auto json = QJsonDocument::fromJson(file.readAll()).object();
        this->rootObject()->setProperty("mapboxAccessToken", json["access_token"].toString());
    }

    connect(this->rootObject(), SIGNAL(call(QString)), this, SIGNAL(call(QString const&)));
}
