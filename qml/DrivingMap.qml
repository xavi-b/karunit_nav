import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.FreeVirtualKeyboard 1.0
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.15
import "qrc:/karunit_nav/qml/utils.js" as Utils

Map {
    id: map
    zoomLevel: defaultZoom

    property var currentIndexCoordinate;
    property var mapCenter;

    function focusOnPlace(place) {
        console.log("focusOnPlace");
        map.center = place.location.coordinate;
        map.zoomLevel = defaultZoom;

        currentIndexCoordinate = QtPositioning.coordinate(place.location.coordinate.latitude, place.location.coordinate.longitude);
        if (!place.detailsFetched) {
            place.getDetails();
        }
        currentPlace = place;
        routeQuery.clearWaypoints();
        routeQuery.addWaypoint(positionSource.position.coordinate);
        routeQuery.addWaypoint(currentIndexCoordinate);
        routeModel.update();
    }

    property var currentPlace: Place;
    property var totalTravelTime;
    property var totalDistance;

    RouteQuery {
        id: routeQuery
        travelModes: RouteQuery.CarTravel
        routeOptimizations: RouteQuery.FastestRoute
    }

    RouteModel {
        id: routeModel
        plugin: geoPlugin
        query: routeQuery
        autoUpdate: false
        onStatusChanged: {
            if(status == RouteModel.Error) {
                console.log("error: " + errorString);
            }
            if(status == RouteModel.Ready) {
                totalTravelTime = routeModel.count == 0 ? "" : Utils.formatTime(routeModel.get(0).travelTime);
                totalDistance = routeModel.count == 0 ? "" : Utils.formatDistance(routeModel.get(0).distance);
            }
        }
    }

    MapQuickItem {
        id: poiCurrent
        sourceItem: Rectangle { width: 14; height: 14; color: "#1e25e4"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
        opacity: 1.0
        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
        coordinate: positionSource.position.coordinate
    }

    MapQuickItem {
        id: poiSelected
        sourceItem: Rectangle { width: 14; height: 14; color: "red"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
        opacity: 1.0
        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
    }

    MapItemView {
        id: mapItemView
        model: searchPage.model
        //autoFitViewport: true
        delegate: MapQuickItem {
            id: point
            sourceItem: Rectangle {
                width: 30
                height: width
                color: "magenta"
                border.width: 2
                border.color: "white"
                smooth: true
                radius: width/2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        focusOnPlace(place);
                    }
                }
            }
            opacity: 1.0
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            coordinate: place.location.coordinate
        }
    }

    RoundButton {
        id: compassButton
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.bottom: centerOnPositionButton.top
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        font.family: "Font Awesome 5 Free"
        text: "\uf14e"
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        onClicked: {
            map.bearing = 0;
        }
    }

    RoundButton {
        id: centerOnPositionButton
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        font.family: "Font Awesome 5 Free"
        text: "\uf192"
        onClicked: {
            map.center = positionSource.position.coordinate;
        }
    }
}
