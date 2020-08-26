import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14
import QtPositioning 5.14

Page {
    property var position;
    property var startCoordinate;
    property var destinationCoordinate;
    property real deviationThreshold: 20.0 // meters
    property real azimuthThreshold: 5.0 // degrees
    property bool driving: false

    onPositionChanged: {
        poiCurrent.coordinate = position;
        if(driving) {
            map.center = position;
        } else {
            if(hasDeviated()) {
                console.log("!driving && hasDeviated()");
                start();
            }
        }
    }

    function start() {
        console.log("start()");
        startCoordinate = QtPositioning.coordinate(position.latitude, position.longitude, position.altitude);
        routeQuery.clearWaypoints();
        console.log(JSON.stringify(startCoordinate));
        console.log(JSON.stringify(destinationCoordinate));
        routeQuery.addWaypoint(startCoordinate);
        routeQuery.addWaypoint(destinationCoordinate);
        routeModel.update();
        map.fitViewportToMapItems();
    }

    function hasDeviated() {
        if(!driving) {
            if(!startCoordinate) {
                return false;
            }
            return Math.abs(startCoordinate.distanceTo(position)) > deviationThreshold;
        } else {
            //TODO
            return false;
        }
    }

    function formatTime(sec)
    {
        var value = sec
        var seconds = value % 60
        value /= 60
        value = (value > 1) ? Math.round(value) : 0
        var minutes = value % 60
        value /= 60
        value = (value > 1) ? Math.round(value) : 0
        var hours = value
        if (hours > 0) value = hours + "h:"+ minutes + "m"
        else value = minutes + "min"
        return value
    }

    function formatDistance(meters)
    {
        var dist = Math.round(meters)
        if (dist > 1000 ){
            if (dist > 100000){
                dist = Math.round(dist / 1000)
            }
            else{
                dist = Math.round(dist / 100)
                dist = dist / 10
            }
            dist = dist + " km"
        }
        else{
            dist = dist + " m"
        }
        return dist
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
                    mainStackView.pop(StackView.Immediate);
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
        plugin: geoPlugin
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

                if (routeModel.count > 0) {
                    /*for (var i = 0; i < routeModel.get(0).segments.length; i++) {
                        routeInfoModel.append({
                            "instruction": routeModel.get(0).segments[i].maneuver.instructionText,
                             "distance": Helper.formatDistance(routeModel.get(0).segments[i].maneuver.distanceToNextInstruction)
                        });
                    }*/
                }
            }
        }
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: defaultZoom

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
            coordinate: destinationCoordinate
            opacity: 1.0
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
        }
    }

    RoundButton {
        id: driveButton
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.bottom: centerOnPositionButton.top
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        font.family: "Font Awesome 5 Free"
        text: driving ? "\uf057" : "\uf144"
        onClicked: {
            driving = !driving;
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

        font.family: "Font Awesome 5 Free"
        text: "\uf192"
        onClicked: {
            map.center = position;
        }
    }
}
