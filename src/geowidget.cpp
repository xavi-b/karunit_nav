#include "geowidget.h"

GeoWidget::GeoWidget(QWidget *parent)
    : QQuickWidget(parent)
{
    this->setResizeMode(QQuickWidget::SizeRootObjectToView);
    this->setSource(QUrl("qrc:/karunit_nav/qml/Main.qml"));

    connect(this->rootObject(), SIGNAL(call(QString)), this, SIGNAL(call(QString const&)));
}
