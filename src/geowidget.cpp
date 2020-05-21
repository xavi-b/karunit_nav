#include "geowidget.h"

GeoWidget::GeoWidget(QQmlEngine* engine, QWidget *parent)
    : QQuickWidget(engine, parent)
{
    this->setResizeMode(QQuickWidget::SizeRootObjectToView);
    this->setSource(QUrl("qrc:/karunit_nav/qml/Main.qml"));

    connect(this->rootObject(), SIGNAL(call(QString)), this, SIGNAL(call(QString const&)));
}
