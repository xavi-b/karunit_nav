#ifndef GEOWIDGET_H
#define GEOWIDGET_H

#include <QQuickWidget>
#include <QQuickItem>
#include <QQmlContext>

class GeoWidget : public QQuickWidget
{
    Q_OBJECT
public:
    GeoWidget(QQmlEngine* engine, QWidget* parent = nullptr);

signals:
    void log(QString const& log);

};

#endif // GEOWIDGET_H
