import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Shapes 1.11
import QtLocation 5.5
import QtPositioning 5.5

Page {
    property var position;
    property var startCoordinate;
    property var destinationCoordinate;
    property real deviationThreshold: 20.0; // meters
    //property real azimuthThreshold: 5.0; // degrees
    property bool driving: false;

    // movement infos
    property real timerInterval: 200;
    property real previousTime;
    property var calculatedPosition;
    property var previousPosition;
    property real speed;
    property real direction: 0;

    property int pathcounter: 0;
    property int segmentcounter: 0;
    property int last_segmentcounter: -1;

    onPositionChanged: {
        previousPosition = QtPositioning.coordinate(poiCurrent.coordinate.latitude, poiCurrent.coordinate.longitude);
        poiCurrent.coordinate = position;

        if(previousPosition && position) {
            var currentTime = new Date().getTime();

            speed = previousPosition.distanceTo(position) / (currentTime - previousTime);
            direction = previousPosition.azimuthTo(position);
        }

        previousTime = new Date().getTime();

        if(driving) {
            map.center = position;
            if(hasDeviated()) {
                console.log("driving && hasDeviated()");
                start();
            }
        } else {
            if(hasDeviated()) {
                console.log("!driving && hasDeviated()");
                start();
            }
        }
    }

    Timer {
        id: positionTimer
        interval: timerInterval;
        running: driving;
        repeat: true
        onTriggered: {
            // https://gerrit.automotivelinux.org/gerrit/gitweb?p=apps/ondemandnavi.git;a=blob;f=app/navigation.qml;hb=HEAD

            if (!routeModel.get(0))
                return;

            if(pathcounter <= routeModel.get(0).path.length - 1){
                // calculate distance
                var next_distance = calculatedPosition.distanceTo(routeModel.get(0).path[pathcounter]);

                // calculate direction
                var next_direction = calculatedPosition.azimuthTo(routeModel.get(0).path[pathcounter]);

                // calculate next cross distance
                var next_cross_distance = calculatedPosition.distanceTo(routeModel.get(0).segments[segmentcounter].path[0]);

                // map rotateAnimation cntrol
                var is_rotating = 0;
                var cur_direction = direction;

                // check is_rotating
                if(cur_direction > next_direction){
                    is_rotating = cur_direction - next_direction;
                }else{
                    is_rotating = next_direction - cur_direction;
                }

                if(is_rotating > 180){
                    is_rotating = 360 - is_rotating;
                }

                var car_moving_distance = 0;
                // rotation angle case
                if(is_rotating > 180){
                    // driving stop hard turn
                    car_moving_distance = 0;
                } else if(is_rotating > 90){
                    // driving stop normal turn
                    car_moving_distance = 0;
                } else if(is_rotating > 60){
                    // driving slow speed normal turn
                    car_moving_distance = (speed * timerInterval) * 0.3;
                } else if(is_rotating > 30){
                    // driving half speed soft turn
                    car_moving_distance = (speed * timerInterval) * 0.5;
                } else {
                    // driving nomal speed soft turn
                    car_moving_distance = speed * timerInterval;
                }

                direction = next_direction;

                // set next coordidnate
                if(next_distance < (car_moving_distance * 1.5))
                {
                    calculatedPosition = routeModel.get(0).path[pathcounter]
                    if(pathcounter < routeModel.get(0).path.length - 1){
                        pathcounter++
                    }
                    else
                    {
                        // Arrive at your destination
                        stopDriving();
                    }
                }else{
                    var coordinate = calculatedPosition.atDistanceAndAzimuth(car_moving_distance, next_direction);
                    calculatedPosition = QtPositioning.coordinate(coordinate.latitude, coordinate.longitude);
                }

                //map.center = calculatedPosition
                map.bearing = direction;

                // report a new instruction if current position matches with the head position of the segment
                if(segmentcounter <= routeModel.get(0).segments.length - 1){
                    if(next_cross_distance < 2){
                        if(segmentcounter < routeModel.get(0).segments.length - 1){
                            segmentcounter++
                        }
                    }else{
                        if(next_cross_distance <= 330 && last_segmentcounter != segmentcounter) {
                            last_segmentcounter = segmentcounter
                            var instruction = routeModel.get(0).segments[segmentcounter].maneuver.instructionText;
                            var distance = formatDistance(routeModel.get(0).segments[segmentcounter].maneuver.distanceToNextInstruction);
                            console.log("Instruction: " + instruction);
                            console.log("Distance: " +  distance);
                            tell(instruction, distance);
                        }
                    }
                }
            }
        }
    }

    function fitItems() {
        map.fitViewportToMapItems();
    }

    function start() {
        console.log("start()");
        startCoordinate = QtPositioning.coordinate(position.latitude, position.longitude);
        calculatedPosition = QtPositioning.coordinate(position.latitude, position.longitude);
        routeQuery.clearWaypoints();
        routeQuery.addWaypoint(startCoordinate);
        routeQuery.addWaypoint(destinationCoordinate);
        routeModel.update();
        pathcounter = 0
        segmentcounter = 0
    }

    function startDriving() {
        driving = true;
        map.zoomLevel = 20;
        map.tilt = 60;
    }

    function stopDriving() {
        driving = false;
        map.bearing = 0;
        map.tilt = 0;
    }

    function hasDeviated() {
        if(!driving) {
            if(!startCoordinate) {
                return false;
            }
            return Math.abs(startCoordinate.distanceTo(position)) > deviationThreshold;
        } else {
            if(!calculatedPosition) {
                return false;
            }
            return Math.abs(calculatedPosition.distanceTo(position)) > deviationThreshold;
        }
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
                    stopDriving();
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
                var totalTravelTime = routeModel.count == 0 ? 0 : routeModel.get(0).travelTime;
                var totalDistance = routeModel.count == 0 ? 0 : routeModel.get(0).distance;

                console.log("totalTravelTime: " + totalTravelTime);
                console.log("totalDistance: " + totalDistance);
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
            id: poiCalculated
            sourceItem: Shape {
                width: 14
                height: 20
                ShapePath {
                    fillColor: "#cccccc"
                    strokeWidth: 2
                    strokeColor: "white"
                    strokeStyle: ShapePath.SolidLine
                    joinStyle: ShapePath.RoundJoin
                    startX: 7; startY: 0
                    PathLine { x: 14; y: 20 }
                    PathLine { x: 0; y: 20 }
                    PathLine { x: 7; y: 0 }
                }
            }

            coordinate: calculatedPosition ? calculatedPosition : QtPositioning.coordinate();
            opacity: 1.0
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            visible: driving
        }

        MapQuickItem {
            id: poiEnd
            sourceItem: Rectangle { width: 14; height: 14; color: "#1ee425"; border.width: 2; border.color: "white";  radius: 7 }
            coordinate: destinationCoordinate ? destinationCoordinate : QtPositioning.coordinate();
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
            if(!driving) {
                stopDriving();
            } else {
                startDriving();
            }
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
