#include "geowidget.h"

GeoWidget::GeoWidget(QQmlEngine* engine, QWidget *parent)
    : QQuickWidget(engine, parent)
{
    this->setResizeMode(QQuickWidget::SizeRootObjectToView);
    this->setSource(QUrl("qrc:/qml/Main.qml"));
}
