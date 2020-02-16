import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14

Page {
    property var position;
    property var destinationPosition;

    onPositionChanged: {
        map.center = src.position.coordinate;
        poiCurrent.coordinate = src.position.coordinate;
    }

    function start() {
        routeQuery.clearWaypoints();
        routeQuery.addWaypoint(position);
        routeQuery.addWaypoint(destinationPosition);
        routeModel.update();
        map.fitViewportToMapItems();
    }

    header: ToolBar {
        contentHeight: goBackButton.implicitHeight

        ToolButton {
            anchors.left: parent.left
            id: goBackButton
            text: "\u25C0"
            visible: mainStackView.depth > 1
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (mainStackView.depth > 1) {
                    mainStackView.pop(StackView.Immediate)
                }
            }
        }
    }

    RouteQuery {
        id: routeQuery
        travelModes: RouteQuery.CarTravel
        routeOptimizations: RouteQuery.FastestRoute
    }

    RouteModel {
        id: routeModel
        plugin: mapPlugin
        query: routeQuery
        autoUpdate: false
        onStatusChanged: {
            if(status == RouteModel.Error) {
                console.log("error: " + errorString);
            }
            if(status == RouteModel.Ready) {
                var totalTravelTime = routeModel.count == 0 ? "" : formatTime(routeModel.get(0).travelTime);
                var totalDistance = routeModel.count == 0 ? "" : formatDistance(routeModel.get(0).distance);

                console.log("totalTravelTime: " + totalTravelTime);
                console.log("totalDistance: " + totalDistance);
            }
        }
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin { name: "osm" }
        zoomLevel: 20

        MapItemView {
            model: routeModel
            autoFitViewport: true
            delegate: MapRoute {
                id: route
                route: routeData
                line.color: "#95d5fc"
                line.width: 5
                smooth: true
                opacity: 0.8
            }
        }

        MapQuickItem {
            id: poiCurrent
            sourceItem: Rectangle { width: 14; height: 14; color: "#1e25e4"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
            opacity: 1.0
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
        }

        MapQuickItem {
            id: poiEnd
            sourceItem: Rectangle { width: 14; height: 14; color: "#1ee425"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
            coordinate: endCoordinates
            opacity: 1.0
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
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

        text: "C"
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        onClicked: {
            //TODO
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

        text: "X"
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        onClicked: {
            map.center = position;
        }
    }
}
