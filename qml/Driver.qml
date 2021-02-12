import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import "qrc:/karunit_nav/qml/utils.js" as Utils

Timer {
    property var startCoordinate;
    property var currentCoordinate;
    property var previousCoordinate;
    property var endCoordinate;
    property real deviationThreshold: 20.0; // meters
    //property real azimuthThreshold: 5.0; // degrees
    property bool driving: false;

    // movement infos
    property real timerInterval: 200;
    property real previousTime;
    property var calculatedCoordinate;
    property real speed;
    property real direction: 0;

    property int pathcounter: 0;
    property int segmentcounter: 0;
    property int last_segmentcounter: -1;

    property var totalTravelTime;
    property var totalDistance;

    interval: timerInterval;
    running: driving;
    repeat: true
    onTriggered: {
        // https://gerrit.automotivelinux.org/gerrit/gitweb?p=apps/ondemandnavi.git;a=blob;f=app/navigation.qml;hb=HEAD

        if (!routeModel.get(0))
            return;

        if(pathcounter <= routeModel.get(0).path.length - 1){
            // calculate distance
            var next_distance = calculatedCoordinate.distanceTo(routeModel.get(0).path[pathcounter]);

            // calculate direction
            var next_direction = calculatedCoordinate.azimuthTo(routeModel.get(0).path[pathcounter]);

            // calculate next cross distance
            var next_cross_distance = calculatedCoordinate.distanceTo(routeModel.get(0).segments[segmentcounter].path[0]);

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
                calculatedCoordinate = routeModel.get(0).path[pathcounter]
                if(pathcounter < routeModel.get(0).path.length - 1){
                    pathcounter++
                }
                else
                {
                    // Arrive at your destination
                    stopDriving();
                }
            }else{
                var coordinate = calculatedCoordinate.atDistanceAndAzimuth(car_moving_distance, next_direction);
                calculatedCoordinate = QtPositioning.coordinate(coordinate.latitude, coordinate.longitude);
            }

            //map.center = calculatedPosition
            map.bearing = direction;
            map.center = calculatedCoordinate;

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
                        var distance = Utils.formatDistance(routeModel.get(0).segments[segmentcounter].maneuver.distanceToNextInstruction);
                        console.log("Instruction: " + instruction);
                        console.log("Distance: " +  distance);
                        tell(instruction, distance);
                    }
                }
            }
        }
    }


    function start(destinationCoordinate) {
        if(destinationCoordinate) {
            endCoordinate = destinationCoordinate;
        }
        console.log("start()");
        //map.fitViewportToMapItems();
        startCoordinate = QtPositioning.coordinate(positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude);
        previousCoordinate = QtPositioning.coordinate();
        calculatedCoordinate = QtPositioning.coordinate(positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude);
        routeQuery.clearWaypoints();
        routeQuery.addWaypoint(startCoordinate);
        routeQuery.addWaypoint(endCoordinate);
        routeModel.update();
        pathcounter = 0
        segmentcounter = 0
    }

    function update() {
        console.log("update");
        //console.log(currentCoordinate);
        //console.log(previousCoordinate);
        if(currentCoordinate) {
            previousCoordinate = QtPositioning.coordinate(currentCoordinate.latitude, currentCoordinate.longitude);
        }
        currentCoordinate = QtPositioning.coordinate(positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude);

        if(previousCoordinate && currentCoordinate) {
            var currentTime = new Date().getTime();

            speed = previousCoordinate.distanceTo(currentCoordinate) / (currentTime - previousTime);
            direction = previousCoordinate.azimuthTo(currentCoordinate);
        }

        previousTime = new Date().getTime();

        if(driving) {
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

    function updateDriving() {
        if(driving) {
            stopDriving();
        } else {
            startDriving();
        }
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
            return Math.abs(startCoordinate.distanceTo(positionSource.position.coordinate)) > deviationThreshold;
        } else {
            if(!calculatedCoordinate) {
                return false;
            }
            return Math.abs(calculatedCoordinate.distanceTo(positionSource.position.coordinate)) > deviationThreshold;
        }
    }

    property RouteQuery routeQuery: RouteQuery {
        travelModes: RouteQuery.CarTravel
        routeOptimizations: RouteQuery.FastestRoute
    }

    property RouteModel routeModel: RouteModel {
        plugin: geoPlugin
        query: routeQuery
        autoUpdate: false
        onStatusChanged: {
            if(status == RouteModel.Error) {
                console.log("error: " + errorString);
            }
            if(status == RouteModel.Ready) {
                totalTravelTime = routeModel.count == 0 ? 0 : routeModel.get(0).travelTime;
                totalDistance = routeModel.count == 0 ? 0 : routeModel.get(0).distance;

                console.log("totalTravelTime: " + totalTravelTime);
                console.log("totalDistance: " + totalDistance);
            }
        }
    }
}
