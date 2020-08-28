#ifndef GEOWIDGET_H
#define GEOWIDGET_H

#include <QQuickWidget>
#include <QQuickItem>
#include <QQmlContext>
#include <QJsonDocument>
#include <QJsonObject>

class GeoWidget : public QQuickWidget
{
    Q_OBJECT
public:
    GeoWidget(QWidget* parent = nullptr);

signals:
    void log(QString const& log);
    void call(QString const& phoneNumber);
    void tell(QString const& instruction, QString const& distance);

};

#endif // GEOWIDGET_H
