import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.FreeVirtualKeyboard 1.0
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import "qrc:/karunit_nav/qml/utils.js" as Utils

Map {
    id: map
    zoomLevel: defaultZoom

    property var currentIndexCoordinate;
    property var mapCenter;

    function focusOnPlace(place) {
        console.log("focusOnPlace");
        map.center = place.location.coordinate;
        //map.zoomLevel = defaultZoom;

        currentIndexCoordinate = QtPositioning.coordinate(place.location.coordinate.latitude, place.location.coordinate.longitude);
        if (!place.detailsFetched) {
            place.getDetails();
        }
    }

    Behavior on center {
        CoordinateAnimation {
            duration: driver.timerInterval
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on bearing {
        RotationAnimation {
            id: rot_anim
            direction: RotationAnimation.Shortest
            easing.type: Easing.Linear
            duration: driver.timerInterval
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

        coordinate: driver.calculatedCoordinate ? driver.calculatedCoordinate : QtPositioning.coordinate();
        opacity: 1.0
        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
        visible: driver.driving
    }

    MapQuickItem {
        id: poiEnd
        sourceItem: Rectangle { width: 14; height: 14; color: "#1ee425"; border.width: 2; border.color: "white";  radius: 7 }
        coordinate: driver.destinationCoordinate ? driver.destinationCoordinate : QtPositioning.coordinate();
        opacity: 1.0
        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
    }

    MapItemView {
        model: driver.routeModel
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

    MapItemView {
        id: mapItemView
        model: searchPage.model
        //autoFitViewport: true
        delegate: MapQuickItem {
            id: point
            sourceItem: Rectangle {
                width: 30
                height: width
                color: {
                    if(category === "Favorites") {
                        return "yellow";
                    } else if(category === "Recents") {
                        return "cyan";
                    } else {
                        return "magenta";
                    }
                }
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
        id: driveButton
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.bottom: compassButton.top
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        icon.name: driver.driving ? "fa-stop-circle" : "fa-start-circle"
        onClicked: {
            driver.updateDriving();
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

        icon.name: "fa-compass"
        icon.height: height
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

        icon.name: "fa-dot-circle"
        onClicked: {
            map.center = positionSource.position.coordinate;
        }
    }
}
